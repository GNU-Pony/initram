KERNEL_SOURCE = $$(cd ../live-medium/linux-*/ ; pwd)
KERNEL_MIRROR = https://ftp.kernel.org/pub/linux

BUSYBOX_VERSION = 1.20.2

KLIBC_VERSION_MASTER = 2.0
KLIBC_VERSION = $(KLIBC_VERSION_MASTER).2
KLIBC = klibc-$(KLIBC_VERSION)


all: verify-is-root clean-fs system cpiolist


verify-is-root:
	[ $$UID = 0 ]

cpiolist:
	find $$(pwd)/fs | ./cpiolist.py $$(pwd)/fs > cpiolist


.PHONY: clean
clean:
	yes | rm -r fs cpiolist *-*/ *-*.tar* LVM2.* || exit 0

.PHONY: clean-fs
clean-fs:
	yes | rm -r fs || exit 0


system: filesystem devices bin-lib fs/init
bin-lib: host-libraries host-binaries klibc busybox busybox-links


filesystem:
	mkdir -p fs/bin
	mkdir -p fs/lib
	mkdir -p fs/proc
	mkdir -p fs/new-root
	mkdir -p fs/dev
	ln -s / fs/usr
	ln -s / fs/local
	ln -s /bin fs/bin

devices:
	mknod --mode=0600 fs/dev/console c 5 1
	mknod --mode=0666 fs/dev/null c 1 3
	mknod --mode=0666 fs/dev/zero c 1 5
	mknod --mode=0666 fs/dev/urandom c 1 9

# steal library files from the current OS
host-libraries:
	for lib in \
	    ld-linux.so.2 \
	    libc.so.6 \
	    libdl.so.2 \
	    libhistory.so.5.0 \
	    libncurses.so.5 \
	    libreadline.so.6.2 \
	; do \
	    cp $$(realpath "/lib/$$lib") "fs/lib/$$lib"; \
	done

# steal binary files from the current OS
host-binaries:
	for bin in \
	    bash \
	    cat \
	    mknod \
	    mount \
	; do \
	    cp "$$(which "$$bin")" "fs/bin/$$bin"; \
	done
	ln -s /bin/bash "fs/bin/sh"


#glibc:
#	wget "http://ftp.gnu.org/gnu/libc/glibc-2.16.0.tar.xz"
#	tar --xz --get < glibc-2.16.0.tar.xz
#	mkdir -p glibc-build
#	cd glibc-build && \
#	../glibc-2.16.0/configure --prefix="" \
#	        --libdir="/lib" \
#	        --libexecdir="/lib" && \
#	make && \
#	make install_root="$$(cd ../glibc-fs ; pwd)" install && \
#	cd ..
#	mkdir -p glibc-fs
#	cp -r glibc-fs/{bin,lib,sbin} fs



klibc: $(KLIBC) $(KLIBC)/linux
	mkdir .tmp
	cp -r /usr/include/{linux,asm{,-generic}} .tmp
	cp -r "$(KLIBC)/linux/include/"* .tmp
	cp -r .tmp/* "$(KLIBC)/linux/include"
	rm -r .tmp
	export INITRAMFS=$$(pwd)/initramfs && \
	export SCRIPTS=$$INITRAMFS/scripts && \
	mkdir -p $$INITRAMFS && \
	make -C "$(KLIBC)" SUBDIRS=utils
	cp "$(KLIBC)/usr/kinit/fstype/static/fstype" fs/bin
	cp "$(KLIBC)/usr/kinit/run-init/static/run-init" fs/bin

$(KLIBC).tar.xz:
	wget '$(KERNEL_MIRROR)/libs/klibc/$(KLIBC_VERSION_MASTER)/$(KLIBC).tar.xz'

$(KLIBC): $(KLIBC).tar.xz
	tar --xz --get < "$(KLIBC).tar.xz"

$(KLIBC)/linux:
	ln -s "$(KERNEL_SOURCE)" "$(KLIBC)/linux"


busybox:
	wget "http://www.busybox.net/downloads/busybox-$(BUSYBOX_VERSION).tar.bz2"
	tar --bzip2 --get < "busybox-$(BUSYBOX_VERSION).tar.bz2"
	cp busybox.config "busybox-$(BUSYBOX_VERSION)/.config"
	cd "busybox-$(BUSYBOX_VERSION)" && \
	patch -Np1 < "../glibc-2.16.patch" && \
	make menuconfig && \
	make && \
	cd ..
	cp "busybox-$(BUSYBOX_VERSION)/busybox" fs/"bin"

busybox-links: fs/bin/init

fs/bin/%:
	ln -s busybox "$@"

# [ [[ ash awk basname cat chgrp chmod own chroot clear cp cttyhack cur dd df
# dirname dmesg du echo egrep env expr false free getopt grep halt head hexdump
# ifconfig install ip ipaddr iplink iproute iprule iptunnel kbd_mode kill
# killall less ln loadfont loadkmap losetup ls md5sum mkdir mkfifo mknod mktemp
# mv nc netstat nslookup openvt passwd pgrep pidof ping ping6 poweroff printf
# ps pwd readlink reboot rm rmdir rout sed seq setfont sh sha1sum sha256sum
# sha512sum sleep sort stat strings tac tail telnet test tftp touch true umount
# uname uniq uptime bi wc wget yes


fs/init: 
	cp init fs
	chmod 755 fs/init
	chown 'root:root' fs/init
