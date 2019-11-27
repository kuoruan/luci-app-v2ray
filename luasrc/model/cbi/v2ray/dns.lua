-- Copyright 2019 Xingwang Liao <kuoruan@gmail.com>
-- Licensed to the public under the MIT License.

local uci = require "luci.model.uci".cursor()
local util = require "luci.util"

local m, s1, s2, o

local dns_keys, dns_table = {}, {}

uci:foreach("v2ray", "dns_server", function(s)
	if s.alias then
		local key = s[".name"]
		util.append(dns_keys, key)
		dns_table[key] = s.alias
	end
end)

m = Map("v2ray", "%s - %s" % { translate("V2Ray"), translate("DNS") },
	translatef("Details: %s", "<a href=\"https://www.v2ray.com/en/configuration/dns.html#dnsobject\" target=\"_blank\">DnsObject</a>"))

s1 = m:section(NamedSection, "main_dns", "dns")
s1.anonymous = true
s1.addremove = false

o = s1:option(Flag, "enabled", translate("Enabled"))
o.rmempty = false

o = s1:option(Value, "tag", translate("Tag"))

o = s1:option(Value, "client_ip", translate("Client IP"),
	"<a href=\"https://www.icanhazip.com\" target=\"_blank\">%s</a>" % translate("Get my public IP address"))
o.datatype = "ipaddr"

o = s1:option(DynamicList, "hosts", translate("Hosts"),
	translatef("A list of static addresses, format: <code>domain|address</code>. eg: %s", "google.com|127.0.0.1"))

o = s1:option(MultiValue, "servers", translate("DNS Servers"), translate("Select DNS servers to use"))
for _, v in ipairs(dns_keys) do
	o:value(v, dns_table[v])
end

s2 = m:section(TypedSection, "dns_server", translate("DNS server"), translate("Add DNS servers here"))
s2.anonymous = true
s2.addremove = true

o = s2:option(Value, "alias", translate("Alias"), translate("Any custom string"))
o.rmempty = false

o = s2:option(Value, "address", translate("Address"))
o.datatype = "host"

o = s2:option(Value, "port", translate("Port"))
o.datatype = "port"
o.placeholder = "53"

o = s2:option(DynamicList, "domains", translate("Domains"))

return m
