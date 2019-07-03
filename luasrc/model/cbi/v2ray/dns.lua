-- Copyright 2019 Xingwang Liao <kuoruan@gmail.com>
-- Licensed to the public under the MIT License.

local m, s1, s2, o

m = Map("v2ray", "%s - %s" % { translate("V2Ray"), translate("DNS") })

s1 = m:section(NamedSection, "main_dns", "dns")
s1.anonymous = true
s1.addremove = false

o = s1:option(Flag, "enabled", translate("Enabled"))

o = s1:option(Value, "tag", translate("Tag"))

o = s1:option(Value, "client_ip", translate("Client IP"))

o = s1:option(DynamicList, "hosts", translate("Hosts"))

o = s1:option(MultiValue, "servers", translate("DNS Servers"), translate("Select DNS servers to use"))

o = s1:option(Value, "address", translate("Address"))
o.datatype = "or(ip4addr, ip6addr)"

s2 = m:section(TypedSection, "dns_server", translate("DNS server"), translate("Add DNS servers here"))
s2.anonymous = true
s2.addremove = true

o = s2:option(Value, "alias", translate("Alias"), translate("Any custom string"))
o.rmempty = false

o = s2:option(Value, "address", translate("Address"))

o = s2:option(Value, "port", translate("Port"))

o = s2:option(DynamicList, "domains", translate("Domains"))

return m
