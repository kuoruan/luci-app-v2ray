-- Copyright 2019 Xingwang Liao <kuoruan@gmail.com>
-- Licensed to the public under the MIT License.

local dsp = require "luci.dispatcher"
local v2ray = require "luci.model.v2ray"

local m, s, o

local sid = arg[1]

m = Map("v2ray", "%s - %s" % { translate("V2Ray"), translate("Edit Inbound") })
m.redirect = dsp.build_url("admin/services/v2ray/inbound")

if m.uci:get("v2ray", sid) ~= "inbound" then
	luci.http.redirect(m.redirect)
	return
end

local inbound-settings = "/etc/v2ray/inbound-settings.json"
local inbound-stream-settings = "/etc/v2ray/inbound-stream-settings.json"

s = m:section(NamedSection, sid, "inbound")
s.anonymous = true
s.addremove = false

o = s:option(Value, "alias", translate("Alias"))

o = s:option(Value, "port", translate("Port"))

o = s:option(Value, "listen", translate("Listen"))

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
o.cfgvalue = function (self, section)
	return v2ray.get_value_from_file(inbound-settings, section)
end
o.write = function (self, section, value)
	return v2ray.add_value_to_file(inbound-settings, section, value)
end
o.remove = function (self, section, value)
	return v2ray.remove_value_from_file(inbound-settings, section)
end

o = s:option(TextValue, "_stream_settings", translate("Stream settings"))
o.wrap = "off"
o.rows = 5
o.cfgvalue = function (self, section)
	return v2ray.get_value_from_file(inbound-stream-settings, section)
end
o.write = function (self, section, value)
	return v2ray.add_value_to_file(inbound-stream-settings, section, value)
end
o.remove = function (self, section, value)
	return v2ray.remove_value_from_file(inbound-stream-settings, section)
end

o = s:option(Value, "tag", translate("Tag"))

o = s:option(Value, "sniffing_enabled", translate("Sniffing enabled"))

o = s:option(MultiValue, "sniffing_dest_override", translate("Sniffing dest override"))

o = s:option(ListValue, "allocate_strategy", translate("Allocate strategy"))
o:value("always")
o:value("random")

o = s:option(ListValue, "allocate_refresh", translate("Allocate refresh"))

o = s:option(ListValue, "allocate_concurrency", translate("Allocate concurrency"))

return m
