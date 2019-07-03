-- Copyright 2019 Xingwang Liao <kuoruan@gmail.com>
-- Licensed to the public under the MIT License.

local dsp = require "luci.dispatcher"
local v2ray = require "luci.model.v2ray"

local m, s, o

local sid = arg[1]

m = Map("v2ray", "%s - %s" % { translate("V2Ray"), translate("Edit Outbound") })
m.redirect = dsp.build_url("admin/services/v2ray/outbounds")

if m.uci:get("v2ray", sid) ~= "outbound" then
	luci.http.redirect(m.redirect)
	return
end

local outbound-settings = "/etc/v2ray/outbound-settings.json"
local outbound-stream-settings = "/etc/v2ray/outbound-stream-settings.json"

s = m:section(NamedSection, sid, "outbound")
s.anonymous = true
s.addremove = false

o = s:option(Value, "alias", translate("Alias"), translate("Any custom string"))
o.rmempty = false

o = s:option(Value, "send_through", translate("Send through"))

o = s:option(ListValue, "protocol", translate("Protocol"))
o:value("blackhole")
o:value("dns")
o:value("freedom")
o:value("mtproto")
o:value("shadowsocks")
o:value("socks")
o:value("vmess")

o = s:option(Value, "_settings", translate("Settings"))
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
	return v2ray.get_value_from_file(outbound-settings, section)
end
o.write = function (self, section, value)
	return v2ray.add_value_to_file(outbound-settings, section, value)
end
o.remove = function (self, section, value)
	return v2ray.remove_value_from_file(outbound-settings, section)
end

o = s:option(Value, "_stream_settings", translate("Stream settings"))
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
	return v2ray.get_value_from_file(outbound-stream-settings, section)
end
o.write = function (self, section, value)
	return v2ray.add_value_to_file(outbound-stream-settings, section, value)
end
o.remove = function (self, section, value)
	return v2ray.remove_value_from_file(outbound-stream-settings, section)
end

o = s:option(Value, "tag", translate("Tag"))

o = s:option(Value, "proxy_settings_tag", translate("Proxy settings tag"))

o = s:option(Flag, "mux_enabled", translate("Mux enabled"))

o = s:option(Value, "mux_concurrency", translate("Mux concurrency"))

return m
