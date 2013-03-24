LIVE_MEDIUM = ../live-medium

KERNEL_SOURCE = $$(cd ../live-medium/linux-*/ ; pwd)
KERNEL_MIRROR = https://ftp.kernel.org/pub/linux

BUSYBOX_VERSION = 1.20.2
GLIBC_VERSION = 2.17
NCURSES_VERSION = 5.9
READLINE_VERSION = 6.2.4
SYSTEMD_VERSION = 198


KLIBC_VERSION_MASTER = 2.0
KLIBC_VERSION = $(KLIBC_VERSION_MASTER).2
KLIBC = klibc-$(KLIBC_VERSION)

root=0


all: verify-is-root clean-fs system cpiolist
system: filesystem devices bin-lib fs/config fs/init
bin-lib: host-libraries klibc busybox fs-cleanup


verify-is-root:
	[ $$UID = 0 ]

cpiolist:
	find $$(pwd)/fs | ./cpiolist.py $$(pwd)/fs > cpiolist


.PHONY: clean
clean:
	yes | rm -r fs cpiolist *-*/ *-*.tar.* || true

.PHONY: clean-fs
clean-fs:
	yes | rm -r fs || true


filesystem:
	mkdir -p fs/sbin
	mkdir -p fs/lib
	mkdir -p fs/hooks
	mkdir -p fs/etc
	mkdir -p fs/proc
	mkdir -p fs/dev
	mkdir -p fs/sys
	mkdir -p fs/run
	ln -sf . fs/usr
	ln -sf . fs/local
	ln -sf sbin fs/bin

devices:
	mknod --mode=0600 fs/dev/console c 5 1
	mknod --mode=0666 fs/dev/null c 1 3
	mknod --mode=0666 fs/dev/zero c 1 5
	mknod --mode=0666 fs/dev/urandom c 1 9

fs/%:
	cp init fs/"$*"
	chmod 755 fs/"$*"
	chown '$(root):$(root)' fs/"$*"

# steal library files from the current OS
host-libraries:
	for lib in \
	    ld-linux.so.2 \
	    libc.so.6 \
	    libdl.so.2 \
	    libhistory.so.6.2 \
	    libncurses.so.5 \
	    libreadline.so.6.2 \
	; do \
	    cp $$(realpath "/lib/$$lib") "fs/lib/$$lib"; \
	done


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


# GPL
BUSYBOX = busybox-$(BUSYBOX_VERSION)
busybox:
	[ -f "$(BUSYBOX).tar.bz2" ] || \
	wget "http://www.busybox.net/downloads/$(BUSYBOX).tar.bz2"
	[ -d "$(BUSYBOX)" ] || \
	tar --bzip2 --get < "$(BUSYBOX).tar.bz2"
	flags="-Os -pipe -fno-strict-aliasing" && \
	sed 's|^\(CONFIG_EXTRA_CFLAGS\)=.*|\1="'"$${flags}"'"|' \
	    busybox.config > $(BUSYBOX)/.config
	cd "$(BUSYBOX)" && \
	patch -Np1 < ../glibc-2.16.patch && \
	make menuconfig && \
	make && \
	cd ..
	cp $(BUSYBOX)/busybox fs/sbin
	fs/sbin/busybox --install -s fs/sbin

include $(LIVE_MEDIUM)/pkgs/ncurses.mk
include $(LIVE_MEDIUM)/pkgs/readline.mk
include $(LIVE_MEDIUM)/pkgs/systemd.mk

fs-cleanup:
	rm -r fs/{var,usr/{include,share}} || true
	rm -r fs/usr/lib/pkgconfig || true
	rm -r fs/bin/{captoinfo,clear,info{cmp,tocap},ncursesw5-config,rest,tabs,tic,toe,tput,tset} || true
	rm -r fs/etc/{binfmt.d,dbus-1,module-load.d,sysctl.d,systemd,tmpfiles.d,xdg} || true

