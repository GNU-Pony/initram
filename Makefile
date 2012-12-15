BUSYBOX_VERSION = 1.20.2


all: dirs linkdirs linkfiles touches busybox cpiolist


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



cpiolist:
	find $$(pwd)/fs | ./cpiolist.py $$(pwd)/fs > cpiolist

