-- Copyright 2019 Xingwang Liao <kuoruan@gmail.com>
-- Licensed to the public under the MIT License.

local dsp = require "luci.dispatcher"

local m, s, o

local sid = arg[1]

m = Map("v2ray", "%s - %s" % { translate("V2Ray"), translate("Edit Routing Rule") })
m.redirect = dsp.build_url("admin/services/v2ray/routing")

if m.uci:get("v2ray", sid) ~= "routing_rule" then
	luci.http.redirect(m.redirect)
	return
end

s = m:section(NamedSection, sid, "routing_rule")
s.anonymous = true
s.addremove = false

o = s:option(Value, "alias", translate("Any custom string"))
o.rmempty = false

o = s:option(ListValue, "type", translate("Type"))
o:value("field")

o = s:option(DynamicList, "domain", translate("Domain"))

o = s:option(DynamicList, "ip", translate("IP"))

o = s:option(DynamicList, "port", translate("Port"))
o.datatype = 'or(port, portrange)'

o = s:option(MultiValue, "network", translate("Network"))
o:value("tcp")
o:value("udp")

o = s:option(DynamicList, "source", translate("Source"))
o.datatype = 'or(ip4addr, ip6addr, cidr)'

o = s:option(DynamicList, "user", translate("User"))

o = s:option(DynamicList, "inbound_tag", translate("Inbound tag"))

o = s:option(MultiValue, "protocol", translate("Protocol"))
o:value("http")
o:value("tls")
o:value("bittorrent")

o = s:option(Value, "attrs", translate("Attrs"))

o = s:option(Value, "outbound_tag", translate("Outbound tag"))

o = s:option(Value, "balancer_tag", translate("Balancer tag"))
o:depends("outbound_tag", "")

return m
