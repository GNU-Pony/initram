BUSYBOX_VERSION = 1.20.2
KMOD_VERSION = 12


all: dirs linkdirs linkfiles touches programs removestuff cpiolist


programs: busybox kmod util-linux popt glibc \
	  zlib libgpg-error e2fsprogs attr acl \
	  cryptsetup device-mapper libgcrypt


dirs:
	mkdir -p fs/"dev"
	mkdir -p fs/"proc"
	mkdir -p fs/"run"
	mkdir -p fs/"sys"
	mkdir -p fs/"tmp"
	mkdir -p fs/"etc/udev"
	mkdir -p fs/"new_root"
	mkdir -p fs/"usr/bin"
	mkdir -p fs/"usr/lib"
	mkdir -p fs/"usr/local"

	chmod 700 fs/"new_root"


linkdirs:
	if [ -e fs/"bin" ]; then  $(RM) fs/"bin";  fi
	if [ -e fs/"lib" ]; then  $(RM) fs/"lib";  fi
	if [ -e fs/"sbin" ]; then  $(RM) fs/"sbin";  fi
	if [ -e fs/"usr/sbin" ]; then  $(RM) fs/"usr/sbin";  fi
	if [ -e fs/"usr/local/bin" ]; then  $(RM) fs/"usr/local/bin";  fi
	if [ -e fs/"usr/local/lib" ]; then  $(RM) fs/"usr/local/lib";  fi
	if [ -e fs/"usr/local/sbin" ]; then  $(RM) fs/"usr/local/sbin";  fi

	ln -s "usr/bin" fs/"bin"
	ln -s "usr/lib" fs/"lib"
	ln -s "usr/bin" fs/"sbin"
	ln -s "bin" fs/"usr/sbin"
	ln -s "../bin" fs/"usr/local/bin"
	ln -s "../lib" fs/"usr/local/lib"
	ln -s "../bin" fs/"usr/local/sbin"


linkfiles:
	if [ -e fs/"etc/mtab" ]; then  $(RM) fs/"etc/mtab";  fi

	ln -s "/proc/self/mounts" fs/"etc/mtab"


touches:
	touch fs/"etc/udev/udev.conf"
	touch fs/"etc/fstab"
	touch fs/"etc/initrd-release"


busybox:
	wget "http://www.busybox.net/downloads/busybox-$(BUSYBOX_VERSION).tar.bz2"
	tar --bzip2 --get < "busybox-$(BUSYBOX_VERSION).tar.bz2"
	cp busybox.config "busybox-$(BUSYBOX_VERSION)/.config"
	cd "busybox-$(BUSYBOX_VERSION)" && \
	patch -Np1 < "../glibc-2.16.patch" && \
	make menuconfig && \
	make && \
	cd ..

	cp "busybox-$(BUSYBOX_VERSION)/busybox" fs/"usr/bin"
	ln -s busybox fs/"usr/bin/["
	ln -s busybox fs/"usr/bin/[["
	ln -s busybox fs/"usr/bin/ash"
	ln -s busybox fs/"usr/bin/awk"
	ln -s busybox fs/"usr/bin/basename"
	ln -s busybox fs/"usr/bin/cat"
	ln -s busybox fs/"usr/bin/chgrp"
	ln -s busybox fs/"usr/bin/chmod"
	ln -s busybox fs/"usr/bin/chown"
	ln -s busybox fs/"usr/bin/chroot"
	ln -s busybox fs/"usr/bin/clear"
	ln -s busybox fs/"usr/bin/cp"
	ln -s busybox fs/"usr/bin/cttyhack"
	ln -s busybox fs/"usr/bin/cut"
	ln -s busybox fs/"usr/bin/dd"
	ln -s busybox fs/"usr/bin/df"
	ln -s busybox fs/"usr/bin/dirname"
	ln -s busybox fs/"usr/bin/dmesg"
	ln -s busybox fs/"usr/bin/du"
	ln -s busybox fs/"usr/bin/echo"
	ln -s busybox fs/"usr/bin/egrep"
	ln -s busybox fs/"usr/bin/env"
	ln -s busybox fs/"usr/bin/expr"
	ln -s busybox fs/"usr/bin/false"
	ln -s busybox fs/"usr/bin/free"
	ln -s busybox fs/"usr/bin/getopt"
	ln -s busybox fs/"usr/bin/grep"
	ln -s busybox fs/"usr/bin/halt"
	ln -s busybox fs/"usr/bin/head"
	ln -s busybox fs/"usr/bin/hexdump"
	ln -s busybox fs/"usr/bin/ifconfig"
	ln -s busybox fs/"usr/bin/init"
	ln -s busybox fs/"usr/bin/install"
	ln -s busybox fs/"usr/bin/ip"
	ln -s busybox fs/"usr/bin/ipaddr"
	ln -s busybox fs/"usr/bin/iplink"
	ln -s busybox fs/"usr/bin/iproute"
	ln -s busybox fs/"usr/bin/iprule"
	ln -s busybox fs/"usr/bin/iptunnel"
	ln -s busybox fs/"usr/bin/kbd_mode"
	ln -s busybox fs/"usr/bin/kill"
	ln -s busybox fs/"usr/bin/killall"
	ln -s busybox fs/"usr/bin/less"
	ln -s busybox fs/"usr/bin/ln"
	ln -s busybox fs/"usr/bin/loadfont"
	ln -s busybox fs/"usr/bin/loadkmap"
	ln -s busybox fs/"usr/bin/losetup"
	ln -s busybox fs/"usr/bin/ls"
	ln -s busybox fs/"usr/bin/md5sum"
	ln -s busybox fs/"usr/bin/mkdir"
	ln -s busybox fs/"usr/bin/mkfifo"
	ln -s busybox fs/"usr/bin/mknod"
	ln -s busybox fs/"usr/bin/mktemp"
	ln -s busybox fs/"usr/bin/mv"
	ln -s busybox fs/"usr/bin/nc"
	ln -s busybox fs/"usr/bin/netstat"
	ln -s busybox fs/"usr/bin/nslookup"
	ln -s busybox fs/"usr/bin/openvt"
	ln -s busybox fs/"usr/bin/passwd"
	ln -s busybox fs/"usr/bin/pgrep"
	ln -s busybox fs/"usr/bin/pidof"
	ln -s busybox fs/"usr/bin/ping"
	ln -s busybox fs/"usr/bin/ping6"
	ln -s busybox fs/"usr/bin/poweroff"
	ln -s busybox fs/"usr/bin/printf"
	ln -s busybox fs/"usr/bin/ps"
	ln -s busybox fs/"usr/bin/pwd"
	ln -s busybox fs/"usr/bin/readlink"
	ln -s busybox fs/"usr/bin/reboot"
	ln -s busybox fs/"usr/bin/rm"
	ln -s busybox fs/"usr/bin/rmdir"
	ln -s busybox fs/"usr/bin/route"
	ln -s busybox fs/"usr/bin/sed"
	ln -s busybox fs/"usr/bin/seq"
	ln -s busybox fs/"usr/bin/setfont"
	ln -s busybox fs/"usr/bin/sh"
	ln -s busybox fs/"usr/bin/sha1sum"
	ln -s busybox fs/"usr/bin/sha256sum"
	ln -s busybox fs/"usr/bin/sha512sum"
	ln -s busybox fs/"usr/bin/sleep"
	ln -s busybox fs/"usr/bin/sort"
	ln -s busybox fs/"usr/bin/stat"
	ln -s busybox fs/"usr/bin/strings"
	ln -s busybox fs/"usr/bin/tac"
	ln -s busybox fs/"usr/bin/tail"
	ln -s busybox fs/"usr/bin/telnet"
	ln -s busybox fs/"usr/bin/test"
	ln -s busybox fs/"usr/bin/tftp"
	ln -s busybox fs/"usr/bin/time"
	ln -s busybox fs/"usr/bin/touch"
	ln -s busybox fs/"usr/bin/true"
	ln -s busybox fs/"usr/bin/umount"
	ln -s busybox fs/"usr/bin/uname"
	ln -s busybox fs/"usr/bin/uniq"
	ln -s busybox fs/"usr/bin/uptime"
	ln -s busybox fs/"usr/bin/vi"
	ln -s busybox fs/"usr/bin/wc"
	ln -s busybox fs/"usr/bin/wget"
	ln -s busybox fs/"usr/bin/yes"


kmod:
	wget "ftp://ftp.kernel.org/pub/linux/utils/kernel/kmod/kmod-$(KMOD_VERSION).tar.xz"
	tar --xz --get < "kmod-$(KMOD_VERSION).tar.xz"
	cd "kmod-$(KMOD_VERSION)" && \
	./configure --sysconfdir=/etc --with-zlib && \
	make && \
	make DESTDIR="$$(cd ../fs ; pwd)" install && \
	cd ..

	ln -s kmod fs/"usr/bin/depmod"
	ln -s kmod fs/"usr/bin/insmod"
	ln -s kmod fs/"usr/bin/lsmod"
	ln -s kmod fs/"usr/bin/modinfo"
	ln -s kmod fs/"usr/bin/modprobe"
	ln -s kmod fs/"usr/bin/rmmod"


util-linux:
	cp $$(which fsck.ext4) fs/"usr/bin"
	cp $$(which fsck) fs/"usr/bin"
	cp $$(which blkid) fs/"usr/bin"
	cp $$(which mount) fs/"usr/bin"
	cp $$(which switch_root) fs/"usr/bin"

	ln -s fsck.ext4 fs/"usr/bin/fsck.ext2"
	ln -s fsck.ext4 fs/"usr/bin/fsck.ext3"

	cp "/usr/lib/libblkid.so.1.1.0" fs/"usr/lib"
	cp "/usr/lib/libmount.so.1.1.0" fs/"usr/lib"
	cp "/usr/lib/libuuid.so.1.3.0" fs/"usr/lib"

	ln -s libblkid.so.1.1.0 fs/"usr/lib/libblkid.so.1"
	ln -s libmount.so.1.1.0 fs/"usr/lib/libmount.so.1"
	ln -s libuuid.so.1.3.0 fs/"usr/lib/libuuid.so.1"


popt:
	wget 'http://rpm5.org/files/popt/popt-1.16.tar.gz'
	tar --gzip --get < popt-1.16.tar.gz
	cd popt-1.16 && \
	./configure --prefix=/usr && \
	make && \
	make DESTDIR="$$(cd ../fs ; pwd)" install && \
	cd ..


glibc:
	wget 'http://ftp.gnu.org/gnu/libc/glibc-2.16.0.tar.xz'
	tar --xz --get < glibc-2.16.0.tar.xz
	cd glibc-2.16.0 && \
	mkdir -p glibc-build && \
	cd glibc-build && \
	../configure \
	        --prefix=/usr \
	        --libdir=/usr/lib \
	        --libexecdir=/usr/libexec \
	        --with-headers=/usr/include \
	        --enable-add-ons=nptl,libidn \
	        --enable-obsolete-rpc \
	        --enable-kernel=2.6.32 \
	        --enable-bind-now \
	        --disable-profile \
	        --enable-stackguard-randomization \
	        --enable-multi-arch && \
	make && \
	make install_root="$$(cd ../../fs ; pwd)" install && \
	cd ../..


zlib:
	wget 'http://zlib.net/current/zlib-1.2.7.tar.gz'
	tar --gzip --get < zlib-1.2.7.tar.gz
	cd zlib-1.2.7 && \
	./configure --prefix=/usr && \
	make && \
	make DESTDIR="$$(cd ../fs ; pwd)" install && \
	cd ..


libgpg-error:
	wget 'ftp://ftp.gnupg.org/gcrypt/libgpg-error/libgpg-error-1.10.tar.bz2'
	tar --bzip2 --get < libgpg-error-1.10.tar.bz2
	cd libgpg-error-1.10 && \
	./configure --prefix=/usr && \
	make && \
	make DESTDIR="$$(cd ../fs ; pwd)"/ install && \
	cd ..


e2fsprogs:
	wget 'http://downloads.sourceforge.net/sourceforge/e2fsprogs/e2fsprogs-1.42.6.tar.gz'
	tar --gzip --get < e2fsprogs-1.42.6.tar.gz
	cd e2fsprogs-1.42.6 && \
	./configure --prefix=/usr --with-root-prefix= --libdir=/usr/lib \
	            --enable-elf-shlibs --disable-fsck --disable-uuidd \
	            --disable-libuuid --disable-libblkid && \
	make && \
	make DESTDIR="$$(cd ../fs ; pwd)" install install-libs && \
	cd ..


attr:
	wget 'http://download.savannah.gnu.org/releases/attr/attr-2.4.46.src.tar.gz'
	tar --gzip --get < attr-2.4.46.src.tar.gz
	cd attr-2.4.46 && \
	export INSTALL_USER=root INSTALL_GROUP=root && \
	./configure --prefix=/usr --libdir=/usr/lib --libexecdir=/usr/lib && \
	make && \
	make DIST_ROOT="$$(cd ../fs ; pwd)" install install-lib install-dev && \
	cd ..


acl:
	wget 'http://download.savannah.gnu.org/releases/acl/acl-2.2.51.src.tar.gz'
	tar --gzip --get < acl-2.2.51.src.tar.gz
	cd acl-2.2.51 && \
	export INSTALL_USER=root INSTALL_GROUP=root && \
	./configure --prefix=/usr --libdir=/usr/lib --libexecdir=/usr/lib && \
	make && \
	make DIST_ROOT="$$(cd ../fs ; pwd)" install install-lib install-dev && \
	cd ..


cryptsetup:
	wget 'http://cryptsetup.googlecode.com/files/cryptsetup-1.5.1.tar.bz2'
	tar --bzip2 --get < cryptsetup-1.5.1.tar.bz2
	cd cryptsetup-1.5.1 && \
	./configure --prefix=/usr --disable-static --enable-cryptsetup-reencrypt && \
	make && \
	make DESTDIR="$$(cd ../fs ; pwd)" install && \
	cd ..


device-mapper:
	wget 'ftp://sources.redhat.com/pub/lvm2/LVM2.2.02.98.tgz'
	mv LVM2.2.02.98.tgz LVM2.2.02.98.tar.gz
	tar --gzip --get < LVM2.2.02.98.tar.gz
	cd LVM2.2.02.98 && \
	unset LDFLAGS && \
	./configure --prefix=/usr \
	            --sysconfdir=/etc \
	            --localstatedir=/var \
	            --with-udev-prefix=/usr \
	            --with-systemdsystemunitdir=/usr/lib/systemd/system \
	            --with-default-pid-dir=/run \
	            --with-default-dm-run-dir=/run \
	            --with-default-run-dir=/run/lvm \
	            --enable-pkgconfig \
	            --enable-readline \
	            --enable-dmeventd \
	            --enable-cmdlib \
	            --enable-applib \
	            --enable-udev_sync \
	            --enable-udev_rules \
	            --with-default-locking-dir=/run/lock/lvm \
	            --enable-lvmetad && \
	make && \
	make DESTDIR="$$(cd ../fs ; pwd)" install_device-mapper && \
	cd ..


libgcrypt:
	wget 'ftp://ftp.gnupg.org/gcrypt/libgcrypt/libgcrypt-1.5.0.tar.bz2'
	tar --bzip2 --get < libgcrypt-1.5.0.tar.bz2
	cd libgcrypt-1.5.0 && \
	./configure --prefix=/usr --disable-static --disable-padlock-support && \
	make && \
	make DESTDIR="$$(cd ../fs ; pwd)" install && \
	cd ..


removestuff:
	rm -r fs/usr/include
	rm -r fs/usr/share


cpiolist:
	find $$(pwd)/fs | ./cpiolist.py $$(pwd)/fs > cpiolist


.PHONY: clean
clean:
	rm -r fs cpiolist *-*/ *-*.tar* LVM2.*

