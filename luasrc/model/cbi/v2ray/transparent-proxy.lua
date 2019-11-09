-- Copyright 2019 Xingwang Liao <kuoruan@gmail.com>
-- Licensed to the public under the MIT License.

local uci = require "luci.model.uci".cursor()
local fs = require "nixio.fs"

local m, s, o

local dokodemo_door_list = {}

uci:foreach("v2ray", "inbound", function(s)
  local port = s.port or ""
  local protocol = s.protocol or ""
  if protocol == "dokodemo-door" and port ~= "" then
    if s.alias then
      dokodemo_door_list[port] = string.format("%s - %s", s.alias, port)
    else
      dokodemo_door_list[port] = string.format("%s:%s", s.listen, port)
    end
  end
end)

m = Map("v2ray", "%s - %s" % { translate("V2Ray"), translate("Transparent Proxy") })
m.apply_on_parse = true
m.on_after_apply = function ()
	sys.call("/etc/init.d/v2ray reload 2>/dev/null")
end

s = m:section(NamedSection, "main_transparent_proxy", "transparent_proxy")

o = s:option(Value, "redirect_port", translate("Redirect port"), translate("Enable transparent proxy on Dokodemo-door port"))
o:value("", "None")
for k, v in pairs(dokodemo_door_list) do
	o:value(k, v)
end
o.datatype = "port"

o = s:option(Flag, "udp_proxy_enabled", translate("UDP proxy enabled"))

o = s:option(Flag, "dns_proxy_enabled", translate("DNS proxy enabled"))
o:depends("udp_proxy_enabled", "")
o:depends("udp_proxy_enabled", "0")

o = s:option(ListValue, "proxy_mode", translate("Proxy mode"))
o:value("default", "Default")
o:value("cn_direct", "CN Direct")
o:value("cn_proxy", "CN Proxy")
o:value("gfwlist_proxy", "GFWList Proxy")

o = s:option(ListValue, "apnic_delegated_mirror", translate("APNIC delegated mirror"))
o:value("apnic", "APNIC")
o:value("arin", "ARIN")
o:value("ripe", "RIPE")
o:value("iana", "IANA")

o = s:option(DummyValue, "_chnroutelist", translate("CHNRoute"))
o.template = "v2ray/list_status"
o.listtype = "chnroute"

o = s:option(ListValue, "gfwlist_mirror", translate("GFWList mirror"))
o:value("github", "GitHub")
o:value("gitlab", "GitLab")
o:value("bitbucket", "Bitbucket")
o:value("pagure", "Pagure")

o = s:option(DummyValue, "_gfwlist", translate("GFWList"))
o.template = "v2ray/list_status"
o.listtype = "gfwlist"

o = s:option(TextValue, "_proxy_list", translate("Extra proxy list"))
o.wrap = "off"
o.rows = 5
o.cfgvalue = function(self, section)
  return fs.readfile("/etc/v2ray/proxylist.txt")
end
o.write = function(self, section, value)
	value = value:gsub("\r\n?", "\n")
	fs.writefile("/etc/v2ray/proxylist.txt", value)
end

o = s:option(TextValue, "_direct_list", translate("Extra direct list"))
o.wrap = "off"
o.rows = 5
o.cfgvalue = function(self, section)
  return fs.readfile("/etc/v2ray/directlist.txt")
end
o.write = function(self, section, value)
	value = value:gsub("\r\n?", "\n")
	fs.writefile("/etc/v2ray/directlist.txt", value)
end

o = s:option(Value, "proxy_list_dns", translate("Proxy list DNS"),
  translatef("DNS used for domains in proxy list, format: <code>ip#port</code>. eg: %s", "127.0.0.1#53"))
o.placeholder = "127.0.0.1#53"

o = s:option(Value, "direct_list_dns", translate("Direct list DNS"),
  translatef("DNS used for domains in direct list, format: <code>ip#port</code>. eg: %s", "127.0.0.1#53"))
o.placeholder = "127.0.0.1#53"

return m
