-- Copyright 2019 Xingwang Liao <kuoruan@gmail.com>
-- Licensed to the public under the MIT License.

local uci = require "luci.model.uci".cursor()
local util = require "luci.util"
local fs = require "nixio.fs"
local sys = require "luci.sys"
local v2ray = require "luci.model.v2ray"

local m, s, o

local transport = "/etc/v2ray/transport.json"

local inbound_table, outbound_table = {}, {}

uci:foreach("v2ray", "inbound", function(s)
	if s.alias then
		inbound_table[s[".name"]] = s.alias
	end
end)

uci:foreach("v2ray", "outbound", function(s)
	if s.alias then
		outbound_table[s[".name"]] = s.alias
	end
end)

m = Map("v2ray", "%s - %s" % { translate("V2Ray"), translate("Global Settings") },
"<p>%s</p><p>%s</p>" % {
	translate("A platform for building proxies to bypass network restrictions."),
	translatef("For more information, please visit: %s",
		"<a href=\"https://www.v2ray.com\" target=\"_blank\">https://www.v2ray.com</a>")
})

s = m:section(NamedSection, "main", "v2ray")
s.addremove = false
s.anonymos = true

o = s:option(Flag, "enabled", translate("Enabled"))
o.rmempty = false

o = s:option(Value, "v2ray_file", translate("V2Ray file"))
o.datatype = file

o = s:option(Value, "config_file", translate("Config file"))
o:value("", translate("Do not use"))

o = s:option(ListValue, "loglevel", translate("Log level"))
o:depends("config_file", "")
o:value("debug", translate("Debug"))
o:value("info", translate("Info"))
o:value("warning", translate("Warning"))
o:value("error", translate("Error"))
o:value("none", translate("None"))
o.default = "warning"

o = s:option(Value, "access_log", translate("Access log file"))
o:value("/dev/null")
o:depends("loglevel", "debug")
o:depends("loglevel", "info")
o:depends("loglevel", "warning")
o:depends("loglevel", "error")

o = s:option(Value, "error_log", translate("Error log file"))
o:value("/dev/null")
o:depends("loglevel", "debug")
o:depends("loglevel", "info")
o:depends("loglevel", "warning")
o:depends("loglevel", "error")

o = s:option(MultiValue, "inbounds", translate("Inbound proxies"))
o:depends("config_file", "")
for k, v in pairs(inbound_table) do
	o:value(k, v)
end

o = s:option(MultiValue, "outbounds", translate("Outbound proxies"))
o:depends("config_file", "")
for k, v in pairs(outbound_table) do
	o:value(k, v)
end

o = s:option(Flag, "stats_enabled", "%s - %s" % { translate("Stats"), translate("Enabled") })
o:depends("config_file", "")

o = s:option(Flag, "transport_enabled", "%s - %s" % { translate("Transport"), translate("Enabled") })
o:depends("config_file", "")

o = s:option(TextValue, "_transport", "%s - %s" % { translate("Transport"), translate("Settings") })
o:depends("transport_enabled", "1")
o.wrap = "off"
o.rows = 5
o.cfgvalue = function (self, section)
	return v2ray.get_value_from_file(transport, section)
end
o.validate = function (self, value, section)
	if not v2ray.is_json_string(value) then
		return nil, translate("invalid JSON")
	else
		return value
	end
end
o.write = function (self, section, value)
	return v2ray.add_value_to_file(transport, section, value)
end
o.remove = function (self, section, value)
	return v2ray.remove_value_from_file(transport, section)
end

return m
