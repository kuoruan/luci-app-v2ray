-- Copyright 2019 Xingwang Liao <kuoruan@gmail.com>
-- Licensed to the public under the MIT License.

local m, s, o

m = Map("v2ray", "%s - %s" % { translate("V2Ray"), translate("Transport") })

s = m:section(NamedSection, "main", "transport")
s.anonymous = true
s.addremove = false

o = s:option(Flag, "enabled", translate("Enabled"))

o = s:option(Value, "tcp_settings", translate("TCP settings"))

o = s:option(Value, "kcp_settings", translate("KCP settings"))

o = s:option(Value, "ws_settings", translate("Websockt settings"))

o = s:option(Value, "http_settings", translate("HTTP settings"))

o = s:option(Value, "ds_settings", translate("Domain socket settings"))

o = s:option(Value, "quic_settings", translate("QUIC settings"))

return m
