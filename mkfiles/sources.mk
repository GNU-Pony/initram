init-script: fs/init_functions fs/init fs/etc/init_head


fs/init: src/init
	cp "$<" "$@"
	chmod 755 "$@"
	chown '$(root):$(root)' "$@"


fs/init_functions: src/init_functions
	cp "$<" "$@"
	chmod 644 "$@"
	chown '$(root):$(root)' "$@"

fs/etc/init_head: src/init_head
	mkdir -p fs/etc
	cp "$<" "$@"
	chmod 644 "$@"
	chown '$(root):$(root)' "$@"


hooks: $(foreach HOOK, $(HOOKS), fs/hooks/$(HOOK))
fs/hooks/%: src/hooks/%
	cp "$<" "$@"

