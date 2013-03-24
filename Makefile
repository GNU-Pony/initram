LIVE_MEDIUM = ../live-medium

KERNEL_SOURCE = $$(cd $(LIVE_MEDIUM)/linux-*/ ; pwd)
KERNEL_MIRROR = https://ftp.kernel.org/pub/linux

BUSYBOX_VERSION = 1.20.2

KLIBC_VERSION_MASTER = 2.0
KLIBC_VERSION = $(KLIBC_VERSION_MASTER).2
KLIBC = klibc-$(KLIBC_VERSION)

# first select is used, gnu required cpio and bsd required libarchive
KERNEL_CPIO = n
GNU_CPIO_OLD = n
GNU_CPIO = n
BSD_CPIO_OLD = n
BSD_CPIO = y

root=0


all: verify-is-root prepare clean-fs system lnfix hooks initcpio
system: filesystem devices bin-lib fs/config fs/init
bin-lib: packages fs-cleanup ld-linux strip upx


verify-is-root:
	[ $$UID = 0 ]

prepare:
	ln -sf "$(LIVE_MEDIUM)"/confs confs
	ln -sf "$(LIVE_MEDIUM)"/patches patches

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
	find $$(pwd)/fs | ./cpiolist.py $$(pwd)/fs > cpiolist


.PHONY: clean
clean:
	yes | rm -r fs cpiolist initramfs-linux *-*/ *-*.tar.* {readline,bash}??-??? || true

.PHONY: clean-fs
clean-fs:
	yes | rm -r fs || true


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
	touch fs/etc/initrd-release
	ln -sf /proc/self/mount fs/etc/mtab

devices:
#	mknod --mode=0600 fs/dev/console c 5 1
#	mknod --mode=0666 fs/dev/null c 1 3
#	mknod --mode=0666 fs/dev/zero c 1 5
#	mknod --mode=0666 fs/dev/urandom c 1 9

fs/init:
	cp init fs/init
	chmod 755 fs/init
	chown '$(root):$(root)' fs/init

fs/config:
	cp config fs/config
	chmod 644 fs/config
	chown '$(root):$(root)' fs/config

hooks:
	cp {keymap,udev} fs/hooks

ld-linux:
	root=fs && \
	ldversion="$$(echo $$root/lib/ld-*.so | sed -e 's|^'"$$root"'/lib/ld-||' -e 's|\.so$$||')" && \
	ldmajor="$$(echo $$ldversion | cut -d . -f 1)" && \
	arch="$$(grep -P '^ARCH( =|=)' < $(LIVE_MEDIUM)/config.mk)" && \
	arch="$$(echo $$arch | sed -e 's_ __g' -e 's/_/-/g' | cut -d = -f 2)" && \
	ln -sf ld-$$ldversion.so $$root/lib/ld-linux-$$arch.so.$$ldmajor

lnfix:
	d="$$(pwd)/fs"; \
	find fs | while read f; do if [ -L "$$f" ]; then \
	    if [ "$$(readlink "$$f")" = "$$(realpath "$$f")" ]; then \
	        p="$$(readlink "$$f" | sed -e "s#^$$d/#/#g")" && \
	        rm "$$f" && ln -sf "$$p" "$$f"; \
	    fi; \
	fi; done


# TODO: cannot get klibc to compile...
klibc: $(KLIBC) $(KLIBC)/linux
	export INITRAMFS=$(shell pwd)/initramfs && \
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
	ln -sf "$(KERNEL_SOURCE)" "$(KLIBC)/linux"


DEVICE=
DEVICELESS=y
MNT=$(shell pwd)/fs
include $(LIVE_MEDIUM)/versions.mk
include $(LIVE_MEDIUM)/pkgs/util-linux.mk
packages: util-linux-bin-clean
util-linux-bin-clean:
	rm fs/usr/bin/*
include $(LIVE_MEDIUM)/pkgs/glibc.mk
packages: glibc-bin-clean
glibc-bin-clean:
	rm fs/usr/bin/*
include $(LIVE_MEDIUM)/pkgs/systemd.mk


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
	    busybox.config > $(BUSYBOX)/.config
	cd "$(BUSYBOX)" && \
	patch -Np1 < ../glibc-2.16.patch && \
	make menuconfig && \
	make && \
	cd ..
	cp $(BUSYBOX)/busybox fs/sbin
	fs/sbin/busybox --install -s fs/sbin


fs-cleanup:
	rm fs/usr/sbin/udevd || true
	mv fs/usr/lib/systemd/systemd-udevd fs/usr/sbin/udevd || true
	rm -r fs/{var,etc/pam.d} || true
	rm -r fs{/usr,}/{lib/pkgconfig,include,share,man,info} || true
	rm -r fs/etc/{binfmt.d,dbus-1,modules-load.d,sysctl.d,systemd,tmpfiles.d,xdg} || true
	rm -r fs{/usr,}/lib/{binfmt.d,girepository-*,modules-load.d,python*,security,locale} || true
	rm -r fs{/usr,}/lib/{sysctl.d,systemd,tmpfiles.d,*.a,*.la,terminfo,lib.*,gconv,audit} || true
	rm -r fs{/usr,}/lib/{getconf,*.o,pt_chown,libcind*,libdl*,libmemusage.*,libnsl*} || true
	rm -r fs{/usr,}/lib/lib{systemd*,udev,gudev-*,nss_*,B*,S*,anl*,cprogile,m,resolve*,util*}.* || true
	rm -r fs{/usr,}/sbin/{*ctl,kernel-install,systemd*} || true
	rm -r fs{/usr,}/etc/{gai.conf,nscd.conf,locale.gen,rpc} || true
	rm fs/usr/{bin,libexec,lib64}
	mv fs/usr/lib/* fs/lib
	mv fs/usr/sbin/* fs/sbin
	rm -r fs/usr
	ln -sf . fs/usr

strip:
	find fs | xargs strip -s fs || true

upx:
	find fs | xargs upx --best fs || true

