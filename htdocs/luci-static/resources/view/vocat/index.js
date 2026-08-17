'use strict';
'require view';
'require form';
'require fs';
'require ui';
'require poll';

function parseJson(text) {
	try {
		return JSON.parse(text || '{}');
	} catch (e) {
		return { ok: false, message: text || e.message };
	}
}

function notifyResult(text, okMsg, errMsg) {
	var result = parseJson(text);
	if (result.ok === false)
		ui.addNotification(null, E('p', {}, result.message || errMsg), 'danger');
	else
		ui.addNotification(null, E('p', {}, result.message || okMsg), 'info');
}

function runScript(path, args, okMsg, errMsg) {
	return fs.exec_direct(path, args || []).then(function(text) {
		notifyResult(text, okMsg, errMsg);
		window.setTimeout(function() { location.reload(); }, 900);
	}).catch(function(e) {
		ui.addNotification(null, E('p', {}, e.message || String(e)), 'danger');
	});
}

return view.extend({
	load: function() {
		return Promise.all([
			L.resolveDefault(fs.exec_direct('/usr/share/vocat/status.sh', [])),
			L.resolveDefault(fs.exec_direct('/usr/share/vocat/device_probe.sh', []))
		]);
	},

	render: function(data) {
		var status = parseJson(data[0]);
		var probe = parseJson(data[1]);

		var m, s, o;

		// ---- 状态视图 ----
		s = m = new form.Map('vocat', _('VoCat'), _('VoCat 蜂窝模组与 VoWiFi 控制面板'));

		s = m.section(form.NamedSection, 'main', 'vocat', _('服务状态'));

		var statusTxt = _('未运行');
		var statusCls = 'cbi-section-descr';
		if (status.running === 1)
			statusTxt = _('运行中');

		s = m.section(form.NamedSection, 'main', 'vocat');
		s.tab('status', _('状态'));
		s.tab('settings', _('设置'));

		var o1 = s.taboption('status', form.DummyValue, '_status', _('服务状态'));
		o1.rawhtml = true;
		o1.default = '<strong>' + statusTxt + '</strong>' +
			(status.installed === 1 ? '' : ' <span style="color:red">(' + _('核心未安装') + ')</span>');

		if (status.running === 1) {
			o1 = s.taboption('status', form.DummyValue, '_pid', _('进程 PID'));
			o1.default = status.pid || '-';

			var mem = status.rss_kb ? (parseInt(status.rss_kb) / 1024).toFixed(1) + ' MB' : '-';
			o1 = s.taboption('status', form.DummyValue, '_mem', _('内存占用'));
			o1.default = mem;
		}

		o1 = s.taboption('status', form.DummyValue, '_ver', _('核心版本'));
		o1.default = status.version || '-';

		o1 = s.taboption('status', form.DummyValue, '_arch', _('架构'));
		o1.default = status.arch || '-';

		// ---- 驱动完整性 ----
		s = m.section(form.NamedSection, 'main', 'vocat', _('驱动完整性'));

		o1 = s.taboption('status', form.DummyValue, '_drv_serial', _('USB 串口驱动 (option)'));
		o1.rawhtml = true;
		o1.default = probe.usb_serial_driver === 1
			? '<span style="color:green">✓ ' + _('已加载') + '</span>'
			: '<span style="color:red">✗ ' + _('未加载') + '</span>';

		o1 = s.taboption('status', form.DummyValue, '_drv_qmi', _('QMI 驱动 (qmi_wwan)'));
		o1.rawhtml = true;
		o1.default = probe.qmi_driver === 1
			? '<span style="color:green">✓ ' + _('已加载') + '</span>'
			: '<span style="color:red">✗ ' + _('未加载') + '</span>';

		o1 = s.taboption('status', form.DummyValue, '_drv_modem', _('Quectel 模组识别'));
		o1.rawhtml = true;
		o1.default = probe.quectel_found === 1
			? '<span style="color:green">✓ ' + _('已识别') + '</span>'
			: '<span style="color:red">✗ ' + _('未识别') + '</span>';

		o1 = s.taboption('status', form.DummyValue, '_drv_tty', _('串口设备'));
		o1.default = probe.ttys || _('无 /dev/ttyUSB* 节点');

		// ---- 设置（端口） ----
		s = m.section(form.NamedSection, 'main', 'vocat', _('服务设置'));

		var o2 = s.taboption('settings', form.Value, 'host', _('监听地址'));
		o2.placeholder = '0.0.0.0';

		var o3 = s.taboption('settings', form.Value, 'port', _('Web 端口'));
		o3.placeholder = '7575';

		// ---- 控制按钮 ----
		s = m.section(form.NamedSection, 'main', 'vocat', _('服务控制'));

		o1 = s.taboption('status', form.Button, '_start', _('启动'));
		o1.inputtitle = _('启动服务');
		o1.onclick = function() {
			return runScript('/usr/share/vocat/service.sh', ['start'], _('已启动'), _('启动失败'));
		};

		o1 = s.taboption('status', form.Button, '_stop', _('停止'));
		o1.inputtitle = _('停止服务');
		o1.onclick = function() {
			return runScript('/usr/share/vocat/service.sh', ['stop'], _('已停止'), _('停止失败'));
		};

		o1 = s.taboption('status', form.Button, '_restart', _('重启'));
		o1.inputtitle = _('重启服务');
		o1.onclick = function() {
			return runScript('/usr/share/vocat/service.sh', ['restart'], _('已重启'), _('重启失败'));
		};

		o1 = s.taboption('status', form.Button, '_apply', _('应用配置'));
		o1.inputtitle = _('应用配置');
		o1.onclick = function() {
			return runScript('/usr/share/vocat/apply_config.sh', [], _('配置已应用'), _('应用失败'));
		};

		return m.render();
	}
});
