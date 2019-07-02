-- Copyright 2019 Xingwang Liao <kuoruan@gmail.com>
-- Licensed to the public under the MIT License.

local uci = require "luci.model.uci".cursor()
local util = require "luci.util"
local fs = require "nixio.fs"
local sys = require "luci.sys"

local m, s, o

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

o = s:option(Flag, "stats_enabled", translate("Stats enabled"))

o = s:option(ListValue, "routing", translate("Routing strategy"))
o:value("", translate("Off"))

o = s:option(ListValue, "policy", translate("Local policy"))
o:value("", translate("Off"))

o = s:option(MultiValue, "inbounds", translate("Inbound proxies"))

o = s:option(MultiValue, "inbounds", translate("Outbound proxies"))

o = s:option(ListValue, "transport", translate("Transport proxies"))
o:value("", translate("Off"))

return m
