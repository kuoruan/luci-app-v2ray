-- Copyright 2019 Xingwang Liao <kuoruan@gmail.com>
-- Licensed to the public under the MIT License.

local uci  = require "luci.model.uci".cursor()

local m, s1, s2, o

local dns_table = {}

uci:foreach("v2ray", "dns_server", function(s)
	if s.alias then
		dns_table[s[".name"]] = s.alias
	end
end)

m = Map("v2ray", "%s - %s" % { translate("V2Ray"), translate("DNS") })

s1 = m:section(NamedSection, "main_dns", "dns")
s1.anonymous = true
s1.addremove = false

o = s1:option(Flag, "enabled", translate("Enabled"))
o.rmempty = false

o = s1:option(Value, "tag", translate("Tag"))

o = s1:option(Value, "client_ip", translate("Client IP"))
o.datatype = "or(ip4addr, ip6addr)"

o = s1:option(DynamicList, "hosts", translate("Hosts"), translate("A list of static addresses, format: domain|address"))

o = s1:option(MultiValue, "servers", translate("DNS Servers"), translate("Select DNS servers to use"))
for k, v in pairs(dns_table) do
	o:value(k, v)
end

s2 = m:section(TypedSection, "dns_server", translate("DNS server"), translate("Add DNS servers here"))
s2.anonymous = true
s2.addremove = true

o = s2:option(Value, "alias", translate("Alias"), translate("Any custom string"))
o.rmempty = false

o = s2:option(Value, "address", translate("Address"))
o.datatype = "or(ip4addr, ip6addr)"

o = s2:option(Value, "port", translate("Port"))
o.datatype = port

o = s2:option(DynamicList, "domains", translate("Domains"))

return m
