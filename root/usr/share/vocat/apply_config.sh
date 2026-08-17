#!/bin/sh

# 应用配置：把 UCI 里的 port 等写到 VoCat 环境变量文件
# VoCat 通过 VOCAT_ADDR 指定监听地址端口，其余走内置 SQLite

set -eu

json_escape() {
	printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

host="$(uci -q get vocat.main.host 2>/dev/null || echo '0.0.0.0')"
port="$(uci -q get vocat.main.port 2>/dev/null || echo '7575')"
data_path="$(uci -q get vocat.main.data_path 2>/dev/null || echo '/opt/vocat/data')"

mkdir -p /etc/vocat

# 保留已有的 VOCAT_* 自定义项，仅覆盖 ADDR 与 DATABASE_PATH
if [ -r /etc/vocat/env ]; then
	sed -i '/^VOCAT_ADDR=/d; /^VOCAT_DATABASE_PATH=/d' /etc/vocat/env
else
	: > /etc/vocat/env
fi

printf 'VOCAT_ADDR=%s:%s\n' "$host" "$port" >> /etc/vocat/env
printf 'VOCAT_DATABASE_PATH=%s/vocat.db\n' "$data_path" >> /etc/vocat/env

printf '{"ok":true,"message":"配置已应用 (host=%s port=%s)"}\n' \
	"$(json_escape "$host")" "$(json_escape "$port")"
