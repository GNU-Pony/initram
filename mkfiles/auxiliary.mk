# GNU/Pony live-medium directory
LIVE_MEDIUM = $(shell cd ../live-medium ; pwd)

# Kernel source
KERNEL_SOURCE = $(shell cd $(LIVE_MEDIUM)/linux-*/ ; pwd)

# Kernel mirror
KERNEL_MIRROR = https://ftp.kernel.org/pub/linux


# first select is used, gnu required cpio and bsd required libarchive
KERNEL_CPIO = n
GNU_CPIO_OLD = n
GNU_CPIO = n
BSD_CPIO_OLD = n
BSD_CPIO = y


# Root user and group ID
root=0


# Check that the user is root
.PHONY: verify-is-root
verify-is-root:
	[ $$UID = 0 ]

