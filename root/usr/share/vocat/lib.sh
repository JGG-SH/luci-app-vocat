#!/bin/sh

json_escape() {
	printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g; s/\t/\\t/g; s/\r//g; :a; N; $!ba; s/\n/\\n/g'
}

uci_get() {
	local key="$1"
	local default="$2"
	local value

	value="$(uci -q get "vocat.main.$key" 2>/dev/null || true)"
	[ -n "$value" ] && printf '%s' "$value" || printf '%s' "$default"
}
