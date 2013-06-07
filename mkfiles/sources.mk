init-script: fs/init_functions fs/init fs/init_head


fs/init: src/init
	cp "$<" "$@"
	chmod 755 "$@"
	chown '$(root):$(root)' "$@"


fs/init_%: src/init_%
	cp "$<" "$@"
	chmod 644 "$@"
	chown '$(root):$(root)' "$@"


hooks: fs/hooks
fs/hooks: src/udev
	cp "$<" "$@"

