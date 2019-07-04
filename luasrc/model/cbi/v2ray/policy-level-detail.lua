-- Copyright 2019 Xingwang Liao <kuoruan@gmail.com>
-- Licensed to the public under the MIT License.

local dsp = require "luci.dispatcher"

local m, s, o

local sid = arg[1]

m = Map("v2ray", "%s - %s" % { translate("V2Ray"), translate("Edit Policy Level") })
m.redirect = dsp.build_url("admin/services/v2ray/policy")

if m.uci:get("v2ray", sid) ~= "policy_level" then
	luci.http.redirect(m.redirect)
	return
end

s = m:section(NamedSection, sid, "policy_level")
s.anonymous = true
s.addremove = false

o = s:option(Value, "level", translate("Level"))
o.rmempty = false
o.datatype = "uinteger"

o = s:option(Value, "handshake", translate("Handshake"))
o.datatype = "uinteger"
o.placeholder = "4"

o = s:option(Value, "conn_idle", translate("Connection idle"))
o.datatype = "uinteger"
o.placeholder = "300"

o = s:option(Value, "uplink_only", translate("Uplink only"))
o.datatype = "uinteger"
o.placeholder = "2"

o = s:option(Value, "downlink_only", translate("Downlink only"))
o.datatype = "uinteger"
o.placeholder = "5"

o = s:option(Flag, "stats_user_uplink", translate("Stats user uplink"))
o.enabled  = "true"
o.disabled = "false"

o = s:option(Flag, "stats_user_downlink", translate("Stats user downlink"))
o.enabled  = "true"
o.disabled = "false"

o = s:option(Value, "buffer_size", translate("Buffer size"))
o.datatype = "uinteger"

return m
