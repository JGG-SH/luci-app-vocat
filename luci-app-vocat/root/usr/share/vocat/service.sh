#!/bin/sh

set -eu

action="${1:-}"

json_escape() {
	printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

run_action() {
	case "$action" in
		start)
			[ -x /opt/vocat/bin/vocat ] || {
				printf '%s\n' "VoCat core is not installed"
				return 1
			}
			uci set vocat.main.enabled='1'
			uci commit vocat
			/etc/init.d/vocat enable
			/etc/init.d/vocat start
			;;
		stop)
			uci set vocat.main.enabled='0'
			uci commit vocat
			/etc/init.d/vocat stop || true
			/etc/init.d/vocat disable
			;;
		restart)
			/etc/init.d/vocat restart
			;;
		*)
			printf '{"ok":false,"message":"Unsupported service action"}\n'
			exit 1
			;;
	esac
}

output="$(run_action 2>&1)" || {
	printf '{"ok":false,"message":"%s"}\n' "$(json_escape "$output")"
	exit 1
}

printf '{"ok":true,"message":"%s"}\n' "$(json_escape "$output")"
