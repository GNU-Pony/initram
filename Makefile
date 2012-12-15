all: makedirs makelinks

makedirs:
	mkdir -p fs/"dev"
	mkdir -p fs/"proc"
	mkdir -p fs/"run"
	mkdir -p fs/"sys"
	mkdir -p fs/"tmp"
	mkdir -p fs/"etc"
	mkdir -p fs/"usr/bin"
	mkdir -p fs/"usr/lib"
	mkdir -p fs/"usr/local"

makelinks:
	if [ -e fs/"bin" ]; then  $(RM) fs/"bin";  fi
	if [ -e fs/"lib" ]; then  $(RM) fs/"lib";  fi
	if [ -e fs/"sbin" ]; then  $(RM) fs/"sbin";  fi
	if [ -e fs/"usr/local/bin" ]; then  $(RM) fs/"usr/local/bin";  fi
	if [ -e fs/"usr/local/lib" ]; then  $(RM) fs/"usr/local/lib";  fi
	if [ -e fs/"usr/local/sbin" ]; then  $(RM) fs/"usr/local/sbin";  fi
	ln -s "sbin" fs/"bin"
	ln -s "usr/bin" fs/"bin"
	ln -s "usr/lib" fs/"lib"
	ln -s "usr/bin" fs/"sbin"
	ln -s "usr/bin" fs/"usr/local/bin"
	ln -s "usr/lib" fs/"usr/local/lib"
	ln -s "usr/bin" fs/"usr/local/sbin"

