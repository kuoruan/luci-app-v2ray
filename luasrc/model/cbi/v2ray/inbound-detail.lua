-- Copyright 2019 Xingwang Liao <kuoruan@gmail.com>
-- Licensed to the public under the MIT License.

local dsp = require "luci.dispatcher"
local v2ray = require "luci.model.v2ray"

local m, s, o

local sid = arg[1]

m = Map("v2ray", "%s - %s" % { translate("V2Ray"), translate("Edit Inbound") })
m.redirect = dsp.build_url("admin/services/v2ray/inbounds")

if m.uci:get("v2ray", sid) ~= "inbound" then
	luci.http.redirect(m.redirect)
	return
end

local inbound_settings = "/etc/v2ray/inbound_settings.json"
local inbound_stream_settings = "/etc/v2ray/inbound_stream_settings.json"

s = m:section(NamedSection, sid, "inbound")
s.anonymous = true
s.addremove = false

o = s:option(Value, "alias", translate("Alias"), translate("Any custom string"))
o.rmempty = false

o = s:option(Value, "port", translate("Port"))
o.datatype = "or(port, portrange, string)"

o = s:option(Value, "listen", translate("Listen"))
o.datatype = "or(ip4addr, ip6addr)"

o = s:option(ListValue, "protocol", translate("Protocol"))
o:value("dokodemo-door")
o:value("http")
o:value("mtproto")
o:value("shadowsocks")
o:value("socks")
o:value("vmess")

o = s:option(TextValue, "_settings", translate("Settings"))
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

o = s:option(TextValue, "_stream_settings", translate("Stream settings"))
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

o = s:option(Value, "sniffing_enabled", translate("Sniffing enabled"))
o.enabled  = "true"
o.disabled = "false"

o = s:option(MultiValue, "sniffing_dest_override", translate("Sniffing dest override"))
o:value("http")
o:value("tls")

o = s:option(ListValue, "allocate_strategy", translate("Allocate strategy"))
o:value("always")
o:value("random")

o = s:option(Value, "allocate_refresh", translate("Allocate refresh"))
o.datatype = uinteger

o = s:option(Value, "allocate_concurrency", translate("Allocate concurrency"))
o.datatype = uinteger

return m
