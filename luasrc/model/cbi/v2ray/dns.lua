-- Copyright 2019 Xingwang Liao <kuoruan@gmail.com>
-- Licensed to the public under the MIT License.

local m, s, o

m = Map("v2ray", "%s - %s" % { translate("V2Ray"), translate("DNS") })

s = m:section(TypedSection, "dns")
s.anonymous = true
s.addremove = true
s.sortable = true

o = s:option(Value, "alias", translate("Alias"))

o = s:option(Value, "tag", translate("Tag"))

o = s:option(Value, "client_ip", translate("Client IP"))

o = s:option(DynamicList, "hosts", translate("Hosts"))

o = s:option(MultiValue, "servers", translate("Servers"))

o = s:option(Value, "address", translate("Address"))
o.datatype = "or(ip4addr, ip6addr)"

s = m:section(TypedSection, "dns_server")
s.anonymous = true
s.addremove = true
s.sortable = true
s.template = "cbi/tblsection"

o = s:option(Value, "address", translate("Address"))

o = s:option(Value, "port", translate("Port"))

o = s:option(DynamicList, "domains", translate("Domains"))

return m
