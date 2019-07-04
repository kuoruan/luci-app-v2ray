-- Copyright 2019 Xingwang Liao <kuoruan@gmail.com>
-- Licensed to the public under the MIT License.

local dsp = require "luci.dispatcher"
local uci  = require "luci.model.uci".cursor()

local m, s1, s2, o

local level_table = {}

uci:foreach("v2ray", "policy_level", function(s)
	if s.level then
		level_table[s[".name"]] = s.level
	end
end)

m = Map("v2ray", "%s - %s" % { translate("V2Ray"), translate("Policy") })

s1 = m:section(NamedSection, "main_policy", "policy")
s1.anonymous = true
s1.addremove = false

o = s1:option(Flag, "enabled", translate("Enabled"))
o.rmempty = false

o = s1:option(MultiValue, "levels", translate("Levels"), translate("Select policy levels"))
for k, v in pairs(level_table) do
	o:value(k, v)
end

o = s1:option(Flag, "system_stats_inbound_uplink", "%s - %s" % { translate("System"), translate("Stats inbound uplink") })
o.enabled  = "true"
o.disabled = "false"

o = s1:option(Flag, "system_stats_inbound_downlink", "%s - %s" % { translate("System"), translate("Stats inbound downlink") })
o.enabled  = "true"
o.disabled = "false"

s2 = m:section(TypedSection, "policy_level", translate("Policy Level"), translate("Add policy levels here"))
s2.anonymous = true
s2.addremove = true
s2.template = "cbi/tblsection"
s2.extedit = dsp.build_url("admin/services/v2ray/policy/levels/%s")
s2.create = function (...)
	local sid = TypedSection.create(...)
	if sid then
		m.uci:save("v2ray")
		luci.http.redirect(s2.extedit % sid)
		return
	end
end

o = s2:option(DummyValue, "level", translate("Level"))
o.cfgvalue = function (...)
	return Value.cfgvalue(...) or "?"
end

o = s2:option(DummyValue, "handshake", translate("Handshake"))
o.cfgvalue = function (...)
	return Value.cfgvalue(...) or "?"
end

o = s2:option(DummyValue, "conn_idle", translate("Connection Idle"))
o.cfgvalue = function (...)
	return Value.cfgvalue(...) or "?"
end

o = s2:option(DummyValue, "buffer_size", translate("Buffer Size"))
o.cfgvalue = function (...)
	return Value.cfgvalue(...) or "?"
end

return m
