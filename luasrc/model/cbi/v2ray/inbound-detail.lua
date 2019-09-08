-- Copyright 2019 Xingwang Liao <kuoruan@gmail.com>
-- Licensed to the public under the MIT License.

local dsp = require "luci.dispatcher"
local nixio = require "nixio"
local util = require "luci.util"
local sys = require "luci.sys"
local v2ray = require "luci.model.v2ray"

local m, s, o

local sid = arg[1]

m = Map("v2ray", "%s - %s" % { translate("V2Ray"), translate("Edit Inbound") })
m.redirect = dsp.build_url("admin/services/v2ray/inbounds")
m.on_after_save = function ()
	sys.call("/etc/init.d/v2ray reload 2>/dev/null")
end

if m.uci:get("v2ray", sid) ~= "inbound" then
	luci.http.redirect(m.redirect)
	return
end

local local_ips = { "0.0.0.0", "127.0.0.1" }

for _, v in ipairs(nixio.getifaddrs()) do
	if v.addr and v.family == "inet" and v.name ~= "lo" and not util.contains(local_ips, v.addr) then
		util.append(local_ips, v.addr)
	end
end

local inbound_settings = "/etc/v2ray/inbound-settings.json"
local inbound_stream_settings = "/etc/v2ray/inbound-stream-settings.json"

s = m:section(NamedSection, sid, "inbound")
s.anonymous = true
s.addremove = false

o = s:option(Value, "alias", translate("Alias"), translate("Any custom string"))
o.rmempty = false

o = s:option(Value, "listen", translate("Listen"))
o.datatype = "ipaddr"
for _, v in ipairs(local_ips) do
	o:value(v)
end

o = s:option(Value, "port", translate("Port"))
o.rmempty = false
o.datatype = "or(port, portrange)"

o = s:option(ListValue, "protocol", translate("Protocol"))
o:value("dokodemo-door")
o:value("http")
o:value("mtproto")
o:value("shadowsocks")
o:value("socks")
o:value("vmess")

o = s:option(Flag, "transparent_proxy_enabled", "%s - %s" % { translate("Transparent proxy"), translate("Enabled") })
o:depends("protocol", "dokodemo-door")

o = s:option(Flag, "transparent_proxy_udp", "%s - %s" %{ translate("Transparent proxy"), translate("UDP traffic") })
o:depends("transparent_proxy_enabled", "1")

o = s:option(Flag, "transparent_proxy_dns", "%s - %s" %{ translate("Transparent proxy"), translate("DNS traffic") })
o:depends({ transparent_proxy_enabled = "1", transparent_proxy_udp = "" })
o:depends({ transparent_proxy_enabled = "1", transparent_proxy_udp = "0" })

o = s:option(Flag, "transparent_proxy_router", "%s - %s" %{ translate("Transparent proxy"), translate("Router traffic") },
	translate("Proxy router's own traffic."))
o:depends("transparent_proxy_enabled", "1")

o = s:option(TextValue, "_settings", translate("Settings"), translate("Protocol-specific settings, JSON string"))
o:depends("transparent_proxy_enabled", "")
o:depends("transparent_proxy_enabled", "0")
o.wrap = "off"
o.rows = 5
o.validate = function (self, value, section)
	if not v2ray.is_json_string(value) then
		return nil, translate("invalid JSON")
	else
		return value
	end
end
o.cfgvalue = function (self, section)
	return v2ray.get_value_from_file(inbound_settings, section)
end
o.write = function (self, section, value)
	return v2ray.add_value_to_file(inbound_settings, section, value)
end
o.remove = function (self, section, value)
	return v2ray.remove_value_from_file(inbound_settings, section)
end

o = s:option(TextValue, "_stream_settings", translate("Stream settings"), translate("Protocol transport options, JSON string"))
o.wrap = "off"
o.rows = 5
o.validate = function (self, value, section)
	if not v2ray.is_json_string(value) then
		return nil, translate("invalid JSON")
	else
		return value
	end
end
o.cfgvalue = function (self, section)
	return v2ray.get_value_from_file(inbound_stream_settings, section)
end
o.write = function (self, section, value)
	return v2ray.add_value_to_file(inbound_stream_settings, section, value)
end
o.remove = function (self, section, value)
	return v2ray.remove_value_from_file(inbound_stream_settings, section)
end

o = s:option(Value, "tag", translate("Tag"))

o = s:option(Flag, "sniffing_enabled", "%s - %s" %{ translate("Sniffing"), translate("Enabled") })

o = s:option(MultiValue, "sniffing_dest_override", "%s - %s" % { translate("Sniffing"), translate("Dest override") })
o:value("http")
o:value("tls")

o = s:option(ListValue, "allocate_strategy", "%s - %s" % { translate("Allocate"), translate("Strategy") })
o:value("")
o:value("always")
o:value("random")

o = s:option(Value, "allocate_refresh", "%s - %s" % { translate("Allocate"), translate("Refresh") })
o.datatype = "uinteger"

o = s:option(Value, "allocate_concurrency", "%s - %s" % { translate("Allocate"), translate("Concurrency") })
o.datatype = "uinteger"

return m
