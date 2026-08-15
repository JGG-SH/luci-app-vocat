#!/bin/sh

BIN="/opt/vocat/bin/vocat"
VERSION_FILE="/opt/vocat/bin/version"
ARCH_FILE="/opt/vocat/bin/arch"

json_escape() {
	printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g; s/\t/\\t/g'
}

running=0
pid=""
version="$(cat "$VERSION_FILE" 2>/dev/null || true)"
arch="$(cat "$ARCH_FILE" 2>/dev/null || true)"
[ -n "$version" ] || version="unknown"
[ -n "$arch" ] || arch="unknown"

rss_kb=0
cpu=0

# 进程匹配：/opt/vocat/bin/vocat 或其 serve 子命令
for p in /proc/[0-9]*; do
	p="${p#/proc/}"
	cmd="$({ tr '\0' ' ' < "/proc/$p/cmdline"; } 2>/dev/null || true)"
	case "$cmd" in
		*"/opt/vocat/bin/vocat"*)
			running=1
			pid="$p"
			;;
	esac
done

if [ "$running" = "1" ]; then
	rss_kb="$(awk '/^VmRSS:/ {print $2; exit}' "/proc/$pid/status" 2>/dev/null || true)"
	[ -n "$rss_kb" ] || rss_kb=0
fi

enabled="$(uci -q get vocat.main.enabled 2>/dev/null || echo 0)"
installed=0
[ -x "$BIN" ] && installed=1

printf '{"ok":true,"running":%d,"enabled":%d,"installed":%d,"pid":"%s","version":"%s","arch":"%s","rss_kb":%d}\n' \
	"$running" "$enabled" "$installed" "$pid" \
	"$(json_escape "$version")" "$(json_escape "$arch")" "$rss_kb"
