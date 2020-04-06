"use strict";
"require uci";
"require ui";
"require view";
"require fs";
"require view/v2ray/include/custom as custom";
var getSections = function (type) {
    var sections = [];
    uci.sections("v2ray", type, function (s) {
        var alias = s[".alias"];
        if (alias) {
            sections.push({
                name: s[".name"],
                alias: s[".alias"],
            });
        }
    });
    return Promise.resolve(sections);
};
return view.extend({
    handleServiceReload: function (btn, ev) {
        return fs
            .exec("/etc/init.d/v2ray", ["reload"])
            .then(L.bind(function (btn, res) {
            if (res.code !== 0) {
                ui.addNotification(null, [
                    E("p", _("Reload service failed with code %d").format(res.code)),
                    res.stderr ? E("pre", {}, [res.stderr]) : "",
                ]);
                L.raise("Error", "Reload failed");
            }
        }, this, ev.target))
            .catch(function (e) {
            ui.addNotification(null, E("p", e.message));
        });
    },
    load: function () {
        return Promise.all([getSections("inbound"), getSections("outbound")]);
    },
    render: function (data) {
        var inboundSections = data[0], outBoundSections = data[1];
        var m, s, o;
        m = new form.Map("v2ray", "%s - %s".format(_("V2ray"), _("Global Settings")), "<p>%s</p><p>%s</p>".format(_("A platform for building proxies to bypass network restrictions."), _("For more information, please visit: %s").format('<a href="https://www.v2ray.com" target="_blank">https://www.v2ray.com</a>')));
        s = m.section(form.NamedSection, "main", "v2ray");
        s.addremove = false;
        s.anonymous = true;
        o = s.option(form.Flag, "enabled", _("Enabled"));
        o.rmempty = false;
        o = s.option(form.Button, "_reload", _("Reload Service"), _("This will restart service when config file changes."));
        o.inputstyle = "action reload";
        o.inputtitle = _("Reload");
        o.onclick = L.bind(this.handleServiceReload, this);
        o = s.option(form.Value, "v2ray_file", _("V2Ray file"), "<em>%s</em>".format(_("Collecting data...")));
        o.datatype = "file";
        o.placeholder = "/usr/bin/v2ray";
        o.rmempty = false;
        o = s.option(form.Value, "asset_location", _("V2Ray asset location"), _("Directory where geoip.dat and geosite.dat files are, default: same directory as V2Ray file."));
        o.datatype = "directory";
        o.placeholder = "/usr/bin";
        o = s.option(form.Value, "mem_percentage", _("Memory percentage"), _("The maximum percentage of memory used by V2Ray."));
        o.datatype = "and(uinteger, max(100))";
        o.placeholder = "80";
        o = s.option(form.Value, "config_file", _("Config file"), _("Use custom config file."));
        o.datatype = "file";
        o.value("", _("None"));
        o = s.option(form.Value, "access_log", _("Access log file"));
        o.depends("config_file", "");
        o.value("/dev/null");
        o.value("/var/log/v2ray-access.log");
        o = s.option(form.ListValue, "loglevel", _("Log level"));
        o.depends("config_file", "");
        o.value("debug", _("Debug"));
        o.value("info", _("Info"));
        o.value("warning", _("Warning"));
        o.value("error", _("Error"));
        o.value("none", _("None"));
        o.default = "warning";
        o = s.option(form.Value, "error_log", _("Error log file"));
        o.value("/dev/null");
        o.value("/var/log/v2ray-error.log");
        o.depends("loglevel", "debug");
        o.depends("loglevel", "info");
        o.depends("loglevel", "warning");
        o.depends("loglevel", "error");
        o = s.option(form.MultiValue, "inbounds", _("Inbounds enabled"));
        o.depends("config_file", "");
        inboundSections.forEach(function (s) {
            o.value(s.name, s.alias);
        });
        o = s.option(form.MultiValue, "outbounds", _("Outbounds enabled"));
        o.depends("config_file", "");
        outBoundSections.forEach(function (s) {
            o.value(s.name, s.alias);
        });
        o = s.option(form.Flag, "stats_enabled", "%s - %s".format(_("Stats"), _("Enabled")));
        o.depends("config_file", "");
        o = s.option(form.Flag, "transport_enabled", "%s - %s".format(_("Transport"), _("Enabled")));
        o.depends("config_file", "");
        o = s.option(custom.TextValue, "_transport", "%s - %s".format(_("Transport"), _("Settings")), _("<code>transport</code> field in top level configuration, JSON string"));
        o.depends("transport_enabled", "1");
        o.wrap = "off";
        o.rows = 5;
        o.datatype = "string";
        o.filepath = "/etc/v2ray/transport.json";
        return m.render();
    },
});
