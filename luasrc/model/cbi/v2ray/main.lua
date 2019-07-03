-- Copyright 2019 Xingwang Liao <kuoruan@gmail.com>
-- Licensed to the public under the MIT License.

local uci = require "luci.model.uci".cursor()
local util = require "luci.util"
local fs = require "nixio.fs"
local sys = require "luci.sys"

local m, s, o

local transport = "/etc/v2ray/transport.json"

m = Map("v2ray", "%s - %s" % { translate("V2Ray"), translate("Golbal Settings") },
"<p>%s</p><p>%s</p>" % {
	translate("A platform for building proxies to bypass network restrictions."),
	translatef("For more information, please visit: %s",
		"<a href=\"https://www.v2ray.com\" target=\"_blank\">https://www.v2ray.com</a>")
})

s = m:section(NamedSection, "main", "v2ray")
s.addremove = false
s.anonymos = true

o = s:option(Flag, "enabled", translate("Enabled"))

o = s:option(Value, "v2ray_file", translate("V2Ray file"))

o = s:option(Value, "v2ctl_file", translate("V2Ctl file"))

o = s:option(ListValue, "loglevel", translate("Log level"))
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

o = s:option(MultiValue, "inbounds", translate("Outbound proxies"))

o = s:option(Flag, "dns_enabled", translate("DNS enabled"))

o = s:option(Flag, "stats_enabled", translate("Stats enabled"))

o = s:option(Flag, "routing_enabled", translate("Routing strategy enabled"))

o = s:option(Flag, "policy_enabled", translate("Local policy enabled"))

o = s:option(Flag, "reverse_enabled", translate("Local policy enabled"))

o = s:option(Flag, "transport_enabled", translate("Transport enabled"))

o = s:option(TextValue, "_transport", translate("Transport settings"))
o.wrap = "off"
o.rows = 5
o.cfgvalue = function (self, section)
	return v2ray.get_value_from_file(transport, section)
end
o.write = function (self, section, value)
	return v2ray.add_value_to_file(transport, section, value)
end
o.remove = function (self, section, value)
	return v2ray.remove_value_from_file(transport, section)
end

return m
