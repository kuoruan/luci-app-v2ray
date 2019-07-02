-- Copyright 2019 Xingwang Liao <kuoruan@gmail.com>
-- Licensed to the public under the MIT License.

local dsp = require "luci.dispatcher"

local m, s, o

local sid = arg[1]

m = Map("v2ray", "%s - %s" % { translate("V2Ray"), translate("Edit Inbound") })
m.redirect = dsp.build_url("admin/services/v2ray/inbound")

if m.uci:get("v2ray", sid) ~= "inbound" then
	luci.http.redirect(m.redirect)
	return
end

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

o = s:option(Value, "settings", translate("Settings"))

o = s:option(Value, "stream_settings", translate("Stream settings"))

o = s:option(Value, "tag", translate("Tag"))

o = s:option(Value, "sniffing_enabled", translate("Sniffing enabled"))

o = s:option(MultiValue, "sniffing_dest_override", translate("Sniffing dest override"))

o = s:option(ListValue, "allocate_strategy", translate("Allocate strategy"))
o:value("always")
o:value("random")

o = s:option(ListValue, "allocate_refresh", translate("Allocate refresh"))

o = s:option(ListValue, "allocate_concurrency", translate("Allocate concurrency"))

return m
