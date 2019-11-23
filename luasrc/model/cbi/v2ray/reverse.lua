-- Copyright 2019 Xingwang Liao <kuoruan@gmail.com>
-- Licensed to the public under the MIT License.

local dsp = require "luci.dispatcher"

local m, s, o

m = Map("v2ray", "%s - %s" % { translate("V2Ray"), translate("Reverse") },
	translatef("Details: %s", "<a href=\"https://www.v2ray.com/en/configuration/reverse.html#reverseobject\" target=\"_blank\">ReverseObject</a>"))

s = m:section(NamedSection, "main_reverse", "reverse")
s.anonymous = true
s.addremove = false

o = s:option(Flag, "enabled", translate("Enabled"))
o.rmempty = false

o = s:option(DynamicList, "bridges", translate("Bridges"),
	translatef("A list of bridges, format: <code>tag|domain</code>. eg: %s", "bridge|test.v2ray.com"))

o = s:option(DynamicList, "portals", translate("Portals"),
	translatef("A list of portals, format: <code>tag|domain</code>. eg: %s", "portal|test.v2ray.com"))

return m
