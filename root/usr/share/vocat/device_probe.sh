#!/bin/sh

# 驱动完整性检查：针对 EC20/EC25 系列模组
# 检查项：
#   1. USB 串口驱动 kmod-usb-serial-option 是否已加载
#   2. QMI 驱动 kmod-usb-net-qmi-wwan 是否已加载
#   3. /dev 下是否有 ttyUSB* 设备节点
#   4. USB 设备树上是否存在 Quectel 模组（VID 2c7c）

json_escape() {
	printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g; s/\t/\\t/g'
}

option_loaded=0
qmi_loaded=0
tty_list=""
quectel_found=0

# 1. 串口驱动
if lsmod 2>/dev/null | grep -q '^usb_serial' || lsmod 2>/dev/null | grep -q '^option'; then
	option_loaded=1
fi

# 2. QMI 驱动
if lsmod 2>/dev/null | grep -q 'qmi_wwan'; then
	qmi_loaded=1
fi

# 3. ttyUSB 节点
tty_list="$(ls /dev/ttyUSB* 2>/dev/null | tr '\n' ' ' || true)"
tty_list="${tty_list% }"

# 4. Quectel 模组
if lsusb 2>/dev/null | grep -qi '2c7c' || \
   [ -d /sys/bus/usb/devices ] && find /sys/bus/usb/devices -name idVendor 2>/dev/null | \
   while read f; do grep -q '2c7c' "$f" 2>/dev/null && { echo yes; break; }; done | grep -q yes; then
	quectel_found=1
fi

printf '{"ok":true,"usb_serial_driver":%d,"qmi_driver":%d,"quectel_found":%d,"ttys":"%s"}\n' \
	"$option_loaded" "$qmi_loaded" "$quectel_found" "$(json_escape "$tty_list")"
