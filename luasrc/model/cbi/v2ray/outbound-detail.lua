-- Copyright 2019 Xingwang Liao <kuoruan@gmail.com>
-- Licensed to the public under the MIT License.

local dsp = require "luci.dispatcher"
local v2ray = require "luci.model.v2ray"
local nixio = require "nixio"
local util = require "luci.util"
local sys = require "luci.sys"

local m, s, o

local sid = arg[1]

m = Map("v2ray", "%s - %s" % { translate("V2Ray"), translate("Edit Outbound") })
m.redirect = dsp.build_url("admin/services/v2ray/outbounds")
m.on_after_save = function ()
	sys.call("/etc/init.d/v2ray reload")
end

if m.uci:get("v2ray", sid) ~= "outbound" then
	luci.http.redirect(m.redirect)
	return
end

local local_ips = { "0.0.0.0" }

for _, v in ipairs(nixio.getifaddrs()) do
	if v.addr and v.family == "inet" and v.name ~= "lo" and not util.contains(local_ips, v.addr) then
		util.append(local_ips, v.addr)
	end
end

local outbound_settings = "/etc/v2ray/outbound-settings.json"
local outbound_stream_settings = "/etc/v2ray/outbound-stream-settings.json"

s = m:section(NamedSection, sid, "outbound")
s.anonymous = true
s.addremove = false

o = s:option(Value, "alias", translate("Alias"), translate("Any custom string"))
o.rmempty = false

o = s:option(Value, "send_through", translate("Send through"), translate("An IP address for sending traffic out."))
o.datatype = "ipaddr"
for _, v in ipairs(local_ips) do
	o:value(v)
end

o = s:option(ListValue, "protocol", translate("Protocol"))
o:value("blackhole")
o:value("dns")
o:value("freedom")
o:value("mtproto")
o:value("shadowsocks")
o:value("socks")
o:value("vmess")

o = s:option(TextValue, "_settings", translate("Settings"), translate("Protocol-specific settings, JSON string"))
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
	return v2ray.get_value_from_file(outbound_settings, section)
end
o.write = function (self, section, value)
	return v2ray.add_value_to_file(outbound_settings, section, value)
end
o.remove = function (self, section, value)
	return v2ray.remove_value_from_file(outbound_settings, section)
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
	return v2ray.get_value_from_file(outbound_stream_settings, section)
end
o.write = function (self, section, value)
	return v2ray.add_value_to_file(outbound_stream_settings, section, value)
end
o.remove = function (self, section, value)
	return v2ray.remove_value_from_file(outbound_stream_settings, section)
end

o = s:option(Value, "tag", translate("Tag"))

o = s:option(Value, "proxy_settings_tag", "%s - %s" % { translate("Proxy settings"), translate("Tag") })

o = s:option(Flag, "mux_enabled", "%s - %s" % { translate("Mux"), translate("Enabled") })

o = s:option(Value, "mux_concurrency", "%s - %s" % { translate("Mux"), translate("Concurrency") })
o.datatype = "uinteger"
o.placeholder = "8"

return m
