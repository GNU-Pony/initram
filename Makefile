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
system: filesystem devices bin-lib fs/init_functions fs/init
bin-lib: packages fs-cleanup util-linux-rebin strip upx


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
	find $$(pwd)/fs | tools/cpiolist.py $$(pwd)/fs > cpiolist


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

fs/init_functions:
	cp init_functions fs/init_functions
	chmod 644 fs/init_functions
	chown '$(root):$(root)' fs/init_functions

hooks:
	cp udev fs/hooks

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
	    busybox.config > $(BUSYBOX)/.config
	cd "$(BUSYBOX)" && \
	patch -Np1 < ../glibc-2.16.patch && \
	make menuconfig && \
	make && \
	cd ..
	cp $(BUSYBOX)/busybox fs/sbin
	fs/sbin/busybox --install -s fs/sbin


fs-cleanup:
#merge
	-rm fs/usr/{bin,libexec,lib64}
	-rm fs/usr/sbin/ldconfig # symlink to fs/sbin/ldconfig
	-rm fs/sbin/udevadm # symlink to fs/usr/sbin/udevadm
	-mv fs/usr/sbin/* fs/sbin
	-mv fs/usr/lib/* fs/lib
	-rmdir fs/usr/{sbin,lib}
	-mv fs/usr/* fs
	-rmdir fs/usr
	ln -sf . fs/usr
	ln -sf . fs/local
#unwanted categories
	-rm -r fs/{var,include,{share,lib}/pkgconfig}
	-rm -r fs/share/{info,man,doc,*-doc,*-completion}
	-rm -r fs/{share/{locale,i18n,licenses},lib/locale}
	-rm -r fs/lib/*.{a,la,o}
	-rm -r fs/sbin/mkfs*
#unwanted stuff
	-rm -r fs/etc/{binfmt.d,dbus-1,modules-load.d,sysctl.d,systemd,tmpfiles.d,xdg}
	-rm -r fs/lib/{binfmt.d,girepository-*,modules-load.d,python*,security,locale}
	-rm -r fs/lib/{sysctl.d,systemd,tmpfiles.d,terminfo,lib.*,gconv,audit}
	-rm -r fs/lib/{getconf,pt_chown,libcind*,libmemusage.*,libnsl*}
	-rm -r fs/lib/lib{systemd*,gudev-*,nss_*,B*,S*,anl*,cprogile,m,resolve*,util*}.*
	-rm -r fs/sbin/{*ctl,kernel-install,systemd*,locale*,mklost+found,uuid*}
	-rm -r fs/etc/{gai.conf,nscd.conf,locale.gen,rpc,pam.d}
	-rm -r fs/sbin/{addpart,agetty,attr,badblocks,cfdisk,chacl,chattr,chcpu,chfn,setterm}
	-rm -r fs/sbin/{chsh,col,colcrt,colrm,column,compile_et,ctrlaltdel,cytune,debug*}
	-rm -r fs/sbin/{delpart,dmeventd,dmsetup,dumpe2fs,e2*,e4*,fallocate,filefrag,findmnt}
	-rm -r fs/sbin/{fsfreeze,fstrim,gencat,getconf,getent,getfacl,getfattr,i386,iconv*}
	-rm -r fs/sbin/{{ins,dep,ls,rm}mod,ld*,linux*,logsave,ls{attr,blk,cpu,locks},makedb}
	-rm -r fs/lib/lib{thread_db,ss,resolv,pcprofile,m-*,crypt*,cidn*}.so*
	-rm -r fs/lib/{e2initrd_helper,depmod.d,modprobe.d,lib{resolv,thread_db}-*}
	-rm -r fs/sbin/{catchsegv,ipcmk,isosize,look,mcookie,memusage*,mk_cmds,mk*fs,mtrace}
	-rm -r fs/sbin/{nscd,partx,pcprofiledump,pg,pldd,prlimit,raw,readprofile,renice}
	-rm -r fs/sbin/{resize*,rpcgen,setfa{cl,ttr},sfdisk,sln,sotruss,sprof,swaplabel}
	-rm -r fs/sbin/{tailf,taskset,tune2fs,tunelp,tzselect,ul,unshare,utmpdump,vigr,vipw}
	-rm -r fs/sbin/{whereis,wipefs,write,x86_64,xtrace,zdump,zic,rename,newgrp,namei}
	-rm -r fs/{share,etc/{*fs.conf,depmod.d,modprobe.d,udev}}

strip:
	-find fs | xargs strip -s fs

upx:
	-find fs | xargs upx --best fs

