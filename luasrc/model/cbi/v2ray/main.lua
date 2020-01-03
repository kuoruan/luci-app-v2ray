-- Copyright 2019-2020 Xingwang Liao <kuoruan@gmail.com>
-- Licensed to the public under the MIT License.

local uci = require "luci.model.uci".cursor()
local util = require "luci.util"
local sys = require "luci.sys"
local json = require "luci.jsonc"
local fs = require "nixio.fs"

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

m = Map("v2ray", "%s - %s" % { translate("V2Ray"), translate("Global Settings") },
"<p>%s</p><p>%s</p>" % {
	translate("A platform for building proxies to bypass network restrictions."),
	translatef("For more information, please visit: %s",
		"<a href=\"https://www.v2ray.com\" target=\"_blank\">https://www.v2ray.com</a>")
})
m:append(Template("v2ray/status_header"))

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

o = s:option(Value, "v2ray_file", translate("V2Ray file"), "<em>%s</em>" % translate("Collecting data..."))
o.datatype = "file"
o.placeholder = "/usr/bin/v2ray"
o.rmempty = false

o = s:option(Value, "asset_location", translate("V2Ray asset location"),
	translate("Directory where geoip.dat and geosite.dat files are, default: same directory as V2Ray file."))
o.datatype = "directory"
o.placeholder = "/usr/bin"

o = s:option(Value, "config_file", translate("Config file"),
	translate("Use custom config file."))
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

o = s:option(TextValue, "_transport", "%s - %s" % { translate("Transport"), translate("Settings") },
	translate("<code>transport</code> field in top level configuration, JSON string"))
o:depends("transport_enabled", "1")
o.wrap = "off"
o.rows = 5
o.validate = function (self, value, section)
	if not value or value == "" then
		return nil, translate("Transport settings is required.")
	end

	local json = json.parse(value)
	if not json then
		return nil, translate("Invalid JSON content.")
	end
end
o.cfgvalue = function (self, section)
	return fs.readfile("/etc/v2ray/transport.json")
end
o.write = function (self, section, value)
	value = value:gsub("\r\n?", "\n")
	fs.writefile("/etc/v2ray/transport.json", value)
end

return m
