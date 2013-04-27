.PHONY: strip
strip:
	-find fs | xargs strip -s fs


.PHONY: upx
upx:
	-find fs | xargs upx --best fs

