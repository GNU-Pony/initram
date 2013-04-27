.PHONY: initcpio
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


.PHONY: cpiolist
cpiolist:
	find $$(pwd)/fs | tools/cpiolist.py $$(pwd)/fs > cpiolist

