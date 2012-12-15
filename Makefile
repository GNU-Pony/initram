all: dirs linkdirs linkfiles touches cpiolist


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


cpiolist:
	find $$(pwd)/fs | ./cpiolist.py $$(pwd)/fs > cpiolist

