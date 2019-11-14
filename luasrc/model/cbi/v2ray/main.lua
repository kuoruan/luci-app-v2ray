-- Copyright 2019 Xingwang Liao <kuoruan@gmail.com>
-- Licensed to the public under the MIT License.

local uci = require "luci.model.uci".cursor()
local util = require "luci.util"
local fs = require "nixio.fs"
local sys = require "luci.sys"
local v2ray = require "luci.model.v2ray"

local m, s, o

local inbound_keys, inbound_table, outbound_keys, outbound_table = {}, {}, {}, {}

uci:foreach("v2ray", "inbound", function(s)
	if s.alias then
		local key = s[".name"]
		util.append(inbound_keys, key)
		inbound_table[key] = s.alias
	end
end)

uci:foreach("v2ray", "outbound", function(s)
	if s.alias then
		local key = s[".name"]
		util.append(outbound_keys, key)
		outbound_table[key] = s.alias
	end
end)

local function v2ray_version()
	local file = uci:get("v2ray", "main", "v2ray_file")

	if not file or file == "" or not fs.stat(file) then
		return "<em style=\"color: red;\">%s</em>" % translate("Invalid V2Ray file")
	end

	if not fs.access(file, "rwx", "rx", "rx") then
		fs.chmod(file, 755)
	end

	local version = util.trim(sys.exec("%s --version 2>/dev/null | head -n1" % file))
	if version == "" then
		return "<em style=\"color: red;\">%s</em>" % translate("Can't get V2Ray version")
	end
	return translatef("Version: %s", version)
end

m = Map("v2ray", "%s - %s" % { translate("V2Ray"), translate("Global Settings") },
"<p>%s</p><p>%s</p>" % {
	translate("A platform for building proxies to bypass network restrictions."),
	translatef("For more information, please visit: %s",
		"<a href=\"https://www.v2ray.com\" target=\"_blank\">https://www.v2ray.com</a>")
})
m:append(Template("v2ray/status_header"))
m.apply_on_parse = true
m.on_after_apply = function ()
	sys.call("/etc/init.d/v2ray restart 2>/dev/null")
end

s = m:section(NamedSection, "main", "v2ray")
s.addremove = false
s.anonymos = true

o = s:option(Flag, "enabled", translate("Enabled"))
o.rmempty = false

o = s:option(Button, "_reload", translate("Reload Service"), translate("This will restart service when config file changes."))
o.inputstyle = "reload"
o.write = function ()
	sys.call("/etc/init.d/v2ray reload 2>/dev/null")
end

o = s:option(Value, "v2ray_file", translate("V2Ray file"), v2ray_version())
o.datatype = "file"
o.placeholder = "/usr/bin/v2ray"

o = s:option(Value, "asset_location", translate("V2Ray asset location"), translate("Directory where geoip.dat and geosite.dat files are, default: same directory as V2Ray file."))
o.datatype = "directory"
o.placeholder = "/usr/bin"

o = s:option(Value, "config_file", translate("Config file"), translate("Use custom config file"))
o.datatype = "file"
o:value("", translate("None"))

o = s:option(Value, "access_log", translate("Access log file"))
o:depends("config_file", "")
o:value("/dev/null")
o:value("/var/log/v2ray-access.log")

o = s:option(ListValue, "loglevel", translate("Log level"))
o:depends("config_file", "")
o:value("debug", translate("Debug"))
o:value("info", translate("Info"))
o:value("warning", translate("Warning"))
o:value("error", translate("Error"))
o:value("none", translate("None"))
o.default = "warning"

o = s:option(Value, "error_log", translate("Error log file"))
o:value("/dev/null")
o:value("/var/log/v2ray-error.log")
o:depends("loglevel", "debug")
o:depends("loglevel", "info")
o:depends("loglevel", "warning")
o:depends("loglevel", "error")

o = s:option(MultiValue, "inbounds", translate("Inbound proxies"))
o:depends("config_file", "")
for _, v in ipairs(inbound_keys) do
	o:value(v, inbound_table[v])
end

o = s:option(MultiValue, "outbounds", translate("Outbound proxies"))
o:depends("config_file", "")
for _, v in ipairs(outbound_keys) do
	o:value(v, outbound_table[v])
end

o = s:option(Flag, "stats_enabled", "%s - %s" % { translate("Stats"), translate("Enabled") })
o:depends("config_file", "")

o = s:option(Flag, "transport_enabled", "%s - %s" % { translate("Transport"), translate("Enabled") })
o:depends("config_file", "")

o = s:option(TextValue, "_transport", "%s - %s" % { translate("Transport"), translate("Settings") }, translate("<code>transport</code> field in top level configuration, JSON string"))
o:depends("transport_enabled", "1")
o.wrap = "off"
o.rows = 5
o.validate = function (self, value, section)
	if not v2ray.is_json_string(value) then
		return nil, translate("invalid JSON")
	else
		return value
	end
end
o.cfgvalue = function (self, section)
	local key = self.map:get(section, "transport") or ""

	if key == "" then
		return ""
	end

	return v2ray.get_transport(key)
end
o.write = function (self, section, value)
	local key = self.map:get(section, "transport") or ""

	if key == "" then
		key = v2ray.random_setting_key()
	end
	return v2ray.save_transport(key, value) and self.map:set(section, "transport", key)
end
o.remove = function (self, section, value)
	local key = self.map:get(section, "transport") or ""

	if key == "" then
		return true
	end
	return v2ray.remove_transport(key) and self.map:del(section, "transport")
end

return m
