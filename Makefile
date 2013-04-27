BUSYBOX_VERSION = 1.20.2

include mkfiles/auxiliary.mk


all: verify-is-root clean-fs system lnfix hooks initcpio
system: filesystem devices bin-lib fs/init_functions fs/init
bin-lib: packages fs-cleanup util-linux-rebin strip upx


verify-is-root:
	[ $$UID = 0 ]

initcpio:
	export LANG=C && \
	if [ "$(KERNEL_CPIO)" = y ]; then \
	    make -B cpiolist && \
	    "$(KERNEL_SOURCE)"/usr/gen_init_cpio cpiolist > initramfs-linux; \
	elif [ "$(GNU_CPIO_OLD)" = y ]; then \
	    cd fs && (find . -print0 | \
	    cpio --create --owner 0:0 --null --format oldc > ../initramfs-linux); \
	elif [ "$(GNU_CPIO)" = y ]; then \
	    cd fs && (find . -print0 | \
	    cpio --create --owner 0:0 --null --format newc > ../initramfs-linux); \
	elif [ "$(BSD_CPIO_OLD)" = y ]; then \
	    cd fs && (find . -print0 | \
	    bsdcpio --create --owner 0:0 --null --format oldc > ../initramfs-linux); \
	elif [ "$(BSD_CPIO)" = y ]; then \
	    cd fs && (find . -print0 | \
	    bsdcpio --create --owner 0:0 --null --format newc > ../initramfs-linux); \
	else \
	    echo -e '\e[01;31mNo cpio creator is specified!\e[00m'; \
	    exit 1; \
	fi

cpiolist:
	find $$(pwd)/fs | tools/cpiolist.py $$(pwd)/fs > cpiolist


filesystem:
	mkdir -p fs/new_root
	mkdir -p fs/sbin
	mkdir -p fs/lib
	mkdir -p fs/hooks
	mkdir -p fs/etc
	mkdir -p fs/proc
	mkdir -p fs/dev
	mkdir -p fs/sys
	mkdir -p fs/run
	mkdir -p fs/tmp
	mkdir -p fs/usr/sbin
	mkdir -p fs/usr/lib
	ln -sf sbin fs/bin || true
	ln -sf sbin fs/usr/bin || true
	ln -sf lib fs/usr/libexec || true
	ln -sf lib fs/libexec || true
	ln -sf lib fs/usr/lib64 || true
	ln -sf lib fs/lib64 || true
	touch fs/etc/fstab
	ln -sf /proc/self/mount fs/etc/mtab

devices:
#	mknod --mode=0600 fs/dev/console c 5 1
#	mknod --mode=0666 fs/dev/null c 1 3
#	mknod --mode=0666 fs/dev/zero c 1 5
#	mknod --mode=0666 fs/dev/urandom c 1 9

fs/init:
	cp src/init fs/init
	chmod 755 fs/init
	chown '$(root):$(root)' fs/init

fs/init_functions:
	cp src/init_functions fs/init_functions
	chmod 644 fs/init_functions
	chown '$(root):$(root)' fs/init_functions

hooks:
	cp src/udev fs/hooks

lnfix:
	d="$$(pwd)/fs"; \
	find fs | while read f; do if [ -L "$$f" ]; then \
	    if [ "$$(readlink "$$f")" = "$$(realpath "$$f")" ]; then \
	        p="$$(readlink "$$f" | sed -e "s#^$$d/#/#g")" && \
	        rm "$$f" && ln -sf "$$p" "$$f"; \
	    fi; \
	fi; done



DEVICE=
DEVICELESS=y
MNT=$(shell pwd)/fs
include $(LIVE_MEDIUM)/versions.mk
include $(LIVE_MEDIUM)/pkgs/util-linux.mk
packages: util-linux-unbin
util-linux-unbin:
	for f in  swapon setarch login kill blockdev su getopt mountpoint cal hwclock  \
	          findfs readprofile rev fsck.minix flock blkid wall rtcwake pivot_root \
	          logger scriptreplay fsck dmesg hexdump switch_root script sulogin mesg \
	          mkswap ipcs mount fdformat more ionice mkfs.minix chrt eject setsid \
	          fdisk ipcrm losetup umount swapoff \
	;do  rm fs/usr/sbin/"$${f}" 2> /dev/null || \
	     rm fs/usr/bin/"$${f}" 2> /dev/null || \
	     rm fs/sbin/"$${f}" 2> /dev/null || \
	     rm fs/bin/"$${f}" 2> /dev/null || exit 1\
	; done
	for f in  fsck.minix blkid fsck switch_root \
	;do mv fs/{usr/,}{s,}bin/"$${f}" fs/_"$${f}" || true; done
util-linux-rebin:
	for f in  fsck.minix blkid fsck switch_root \
	;do mv fs/_"$${f}" fs/sbin/"$${f}" || true; done
include $(LIVE_MEDIUM)/pkgs/glibc.mk
include $(LIVE_MEDIUM)/pkgs/systemd.mk
packages: systemd-mvbin
systemd-mvbin:
	(rm fs/usr/sbin/udevd && mv fs/usr/lib/systemd/systemd-udevd fs/usr/sbin/udevd) || \
	(rm fs/usr/bin/udevd && mv fs/usr/lib/systemd/systemd-udevd fs/usr/bin/udevd) || \
	(rm fs/sbin/udevd && mv fs/lib/systemd/systemd-udevd fs/sbin/udevd) || \
	(rm fs/bin/udevd && mv fs/lib/systemd/systemd-udevd fs/bin/udevd)
include $(LIVE_MEDIUM)/pkgs/kmod.mk
include $(LIVE_MEDIUM)/pkgs/zlib.mk
include $(LIVE_MEDIUM)/pkgs/acl.mk
include $(LIVE_MEDIUM)/pkgs/attr.mk
include $(LIVE_MEDIUM)/pkgs/device-mapper.mk
include $(LIVE_MEDIUM)/pkgs/e2fsprogs.mk


## Do busybox last!

# GPL
BUSYBOX = busybox-$(BUSYBOX_VERSION)
packages: busybox
busybox:
	[ -f "$(BUSYBOX).tar.bz2" ] || \
	wget "http://www.busybox.net/downloads/$(BUSYBOX).tar.bz2"
	[ -d "$(BUSYBOX)" ] || \
	tar --bzip2 --get < "$(BUSYBOX).tar.bz2"
	flags="-Os -pipe -fno-strict-aliasing" && \
	sed 's|^\(CONFIG_EXTRA_CFLAGS\)=.*|\1="'"$${flags}"'"|' \
	    busybox-etc/busybox.config > $(BUSYBOX)/.config
	cd "$(BUSYBOX)" && \
	patch -Np1 < ../busybox-etc/glibc-2.16.patch && \
	make menuconfig && \
	make && \
	cd ..
	cp $(BUSYBOX)/busybox fs/sbin
	fs/sbin/busybox --install -s fs/sbin


include mkfiles/trim.mk
include mkfiles/clean.mk

