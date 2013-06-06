.PHONY: trim
trim: strip upx


.PHONY: strip
strip:
	-find fs | xargs strip -s


.PHONY: upx
upx:
	-find fs | xargs upx --best

