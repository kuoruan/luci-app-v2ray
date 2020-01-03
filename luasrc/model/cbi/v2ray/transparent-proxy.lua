-- Copyright 2019-2020 Xingwang Liao <kuoruan@gmail.com>
-- Licensed to the public under the MIT License.

local uci = require "luci.model.uci".cursor()
local fs = require "nixio.fs"
local sys = require "luci.sys"

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

local proxy_list_path, direct_list_path = "/etc/v2ray/proxylist.txt", "/etc/v2ray/directlist.txt"

local has_ssl = true, ssl_note

if not fs.stat("/lib/libustream-ssl.so") then
	has_ssl = false
	ssl_note = translatef("Please install %s or %s to enable list update.", "libustream-openssl", "libustream-mbedtls")
end

m = Map("v2ray", "%s - %s" % { translate("V2Ray"), translate("Transparent Proxy") })
m.apply_on_parse = true
m.on_after_apply = function ()
	sys.call("/etc/init.d/v2ray reload 2>/dev/null")
end

s = m:section(NamedSection, "main_transparent_proxy", "transparent_proxy")

o = s:option(Value, "redirect_port", translate("Redirect port"), translate("Enable transparent proxy on Dokodemo-door port"))
o:value("", translate("None"))
for k, v in pairs(dokodemo_door_list) do
	o:value(k, v)
end
o.datatype = "port"

o = s:option(Flag, "use_tproxy", translate("Use TProxy"), translate("Setup redirect rules with TProxy."))

o = s:option(Flag, "only_privileged_ports", translate("Only privileged ports"),
	translate("Only redirect traffic on ports below 1024."))

o = s:option(Flag, "redirect_udp", translate("Redirect UDP"), translate("Redirect UDP traffic to V2Ray."))

o = s:option(Flag, "redirect_dns", translate("Redirect DNS"), translate("Redirect DNS traffic to V2Ray."))
o:depends("redirect_udp", "")
o:depends("redirect_udp", "0")

o = s:option(ListValue, "proxy_mode", translate("Proxy mode"))
o:value("default", translate("Default"))
o:value("cn_direct", translate("CN Direct"))
o:value("cn_proxy", translate("CN Proxy"))
o:value("gfwlist_proxy", translate("GFWList Proxy"))

o = s:option(ListValue, "apnic_delegated_mirror", translate("APNIC delegated mirror"))
o:value("apnic", "APNIC")
o:value("arin", "ARIN")
o:value("ripe", "RIPE")
o:value("iana", "IANA")

o = s:option(DummyValue, "_chnroutelist", translate("CHNRoute"), ssl_note)
o.template = "v2ray/list_status"
o.listtype = "chnroute"
o.updatebtn = has_ssl

o = s:option(ListValue, "gfwlist_mirror", translate("GFWList mirror"))
o:value("github", "GitHub")
o:value("gitlab", "GitLab")
o:value("bitbucket", "Bitbucket")
o:value("pagure", "Pagure")

o = s:option(DummyValue, "_gfwlist", translate("GFWList"), ssl_note)
o.template = "v2ray/list_status"
o.listtype = "gfwlist"
o.updatebtn = has_ssl

o = s:option(TextValue, "_proxy_list", translate("Extra proxy list"),
	translatef("One address per line. Allow types: DOMAIN, IP, CIDR. eg: %s, %s, %s", "www.google.com", "1.1.1.1", "192.168.0.0/16"))
o.wrap = "off"
o.rows = 5
o.datatype = "string"
o.cfgvalue = function(self, section)
  return fs.readfile(proxy_list_path) or ""
end
o.write = function(self, section, value)
	value = value:gsub("\r\n?", "\n")
	fs.writefile(proxy_list_path, value)
end
o.remove = function(self, section, value)
	fs.writefile(proxy_list_path, "")
end

o = s:option(TextValue, "_direct_list", translate("Extra direct list"),
	translatef("One address per line. Allow types: DOMAIN, IP, CIDR. eg: %s, %s, %s", "www.google.com", "1.1.1.1", "192.168.0.0/16"))
o.wrap = "off"
o.rows = 5
o.datatype = "string"
o.cfgvalue = function(self, section)
  return fs.readfile(direct_list_path) or ""
end
o.write = function(self, section, value)
	value = value:gsub("\r\n?", "\n")
	fs.writefile(direct_list_path, value)
end
o.remove = function(self, section, value)
	fs.writefile(direct_list_path, "")
end

o = s:option(Value, "proxy_list_dns", translate("Proxy list DNS"),
	translatef("DNS used for domains in proxy list, format: <code>ip#port</code>. eg: %s", "1.1.1.1#53"))

o = s:option(Value, "direct_list_dns", translate("Direct list DNS"),
	translatef("DNS used for domains in direct list, format: <code>ip#port</code>. eg: %s", "114.114.114.114#53"))

return m
