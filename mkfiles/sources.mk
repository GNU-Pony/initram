init-script: fs/init_functions fs/init


fs/init: src/init
	cp "$<" "$@"
	chmod 755 "$@"
	chown '$(root):$(root)' "$@"


fs/init_functions: src/init_functions
	cp "$<" "$@"
	chmod 644 "$@"
	chown '$(root):$(root)' "$@"


hooks: fs/hooks
fs/hooks: src/udev
	cp "$<" "$@"

