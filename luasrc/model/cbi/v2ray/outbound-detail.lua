-- Copyright 2019 Xingwang Liao <kuoruan@gmail.com>
-- Licensed to the public under the MIT License.

local dsp = require "luci.dispatcher"

local m, s, o

local sid = arg[1]

m = Map("v2ray", "%s - %s" % { translate("V2Ray"), translate("Edit Outbound") })
m.redirect = dsp.build_url("admin/services/v2ray/outbound")

if m.uci:get("v2ray", sid) ~= "outbound" then
	luci.http.redirect(m.redirect)
	return
end

o = s:option(Value, "alias", translate("Alias"))

o = s:option(Value, "send_through", translate("Send through"))

o = s:option(ListValue, "protocol", translate("Protocol"))
o:value("blackhole")
o:value("dns")
o:value("freedom")
o:value("mtproto")
o:value("shadowsocks")
o:value("socks")
o:value("vmess")

o = s:option(Value, "settings", translate("Settings"))

o = s:option(Value, "stream_settings", translate("Stream settings"))

o = s:option(Value, "tag", translate("Tag"))

o = s:option(Value, "proxy_settings_tag", translate("Proxy settings tag"))

o = s:option(Flag, "mux_enabled", translate("Mux enabled"))

o = s:option(Value, "mux_concurrency", translate("Mux concurrency"))

return m
