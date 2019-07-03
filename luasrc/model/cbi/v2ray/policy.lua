-- Copyright 2019 Xingwang Liao <kuoruan@gmail.com>
-- Licensed to the public under the MIT License.

local dsp = require "luci.dispatcher"

local m, s, o

m = Map("v2ray", "%s - %s" % { translate("V2Ray"), translate("Policy") })

s = m:section(NamedSection, "main", "policy")
s.anonymous = true
s.addremove = false

o = s:option(MultiValue, "levels", translate("Levels"))

s = m:section(TypedSection, "policy_level")
s.anonymous = true
s.addremove = true
s.template = "cbi/tblsection"
s.extedit = dsp.build_url("admin/services/v2ray/policy/levels/%s")
function s.create(...)
	local sid = TypedSection.create(...)
	if sid then
		m.uci:save("v2ray")
		luci.http.redirect(s.extedit % sid)
		return
	end
end

o = s:option(DummyValue, "level", translate("Level"))
o.cfgvalue = function (...)
	return Value.cfgvalue(...) or "?"
end

o = s:option(Flag, "system_stats_inbound_uplink", translate("System Stats inbound uplink"))
o.enabled  = "true"
o.disabled = "false"

o = s:option(Flag, "system_stats_inbound_downlink", translate("System Stats inbound downlink"))
o.enabled  = "true"
o.disabled = "false"

return m
