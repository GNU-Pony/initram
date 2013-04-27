BUSYBOX_VERSION = 1.20.2

include mkfiles/auxiliary.mk
include mkfiles/trim.mk
include mkfiles/clean.mk
include mkfiles/sources.mk
include mkfiles/initramfs.mk


all: verify-is-root clean-fs system lnfix hooks initcpio
system: filesystem packages fs-cleanup trim init-script


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
	-ln -sf sbin fs/bin
	-ln -sf sbin fs/usr/bin
	-ln -sf lib fs/usr/libexec
	-ln -sf lib fs/libexec
	-ln -sf lib fs/usr/lib64
	-ln -sf lib fs/lib64
	touch fs/etc/fstab
	ln -sf /proc/self/mount fs/etc/mtab

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

