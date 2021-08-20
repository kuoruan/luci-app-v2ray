-- Copyright 2019-2020 Xingwang Liao <kuoruan@gmail.com>
-- Licensed to the public under the MIT License.

local dsp = require "luci.dispatcher"
local  uci = require "luci.model.uci".cursor()
local v2ray = require "luci.model.v2ray"

local inbound_tag, outbound_tag = {}, {}

uci:foreach("v2ray", "inbound", function(s)
	local i_tag = s.tag or ""
	if s.alias then
		inbound_tag[i_tag] = string.format("%s  (%s)", s.alias, i_tag)
	end
end)

uci:foreach("v2ray", "outbound", function(s)
	local o_tag = s.tag or ""
	if s.alias then
		outbound_tag[o_tag] = string.format("%s  (%s)", s.alias, o_tag)
	end
end)


local m, s, o

local sid = arg[1]

m = Map("v2ray", "%s - %s" % { translate("V2Ray"), translate("Edit Routing Rule") },
	translatef("Details: %s", "<a href=\"https://www.v2ray.com/en/configuration/routing.html#ruleobject\" target=\"_blank\">RuleObject</a>"))
m.redirect = dsp.build_url("admin/services/v2ray/routing")

if m.uci:get("v2ray", sid) ~= "routing_rule" then
	luci.http.redirect(m.redirect)
	return
end

s = m:section(NamedSection, sid, "routing_rule")
s.anonymous = true
s.addremove = false

o = s:option(Value, "alias", translate("Alias"), translate("Any custom string"))
o.rmempty = false

o = s:option(ListValue, "type", translate("Type"))
o:value("field")

o = s:option(DynamicList, "domain", translate("Domain"))

o = s:option(DynamicList, "ip", translate("IP"))

o = s:option(DynamicList, "port", translate("Port"))
o.datatype = "or(port, portrange)"

o = s:option(MultiValue, "network", translate("Network"))
o:value("tcp")
o:value("udp")

o = s:option(DynamicList, "source", translate("Source"))

o = s:option(DynamicList, "user", translate("User"))
-- Get inboundTags automatically to avoid misentry
o = s:option(MultiValue, "inbound_tag", translate("Inbound tag"))
for k , v in pairs(inbound_tag) do
		o:value(k , v)
end


o = s:option(MultiValue, "protocol", translate("Protocol"))
o:value("http")
o:value("tls")
o:value("bittorrent")

o = s:option(Value, "attrs", translate("Attrs"))

-- Get outboundTags automatically to avoid misentry
o = s:option(ListValue, "outbound_tag", translate("Outbound tag"))
for k , v in pairs(inbound_tag) do
		o:value(k , v)
end

o = s:option(Value, "balancer_tag", translate("Balancer tag"))
o:depends("outbound_tag", "")

return m
