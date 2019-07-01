-- Copyright 2019 Xingwang Liao <kuoruan@gmail.com>
-- Licensed to the public under the MIT License.

local dsp = require "luci.dispatcher"

local m, s, o

m = Map("v2ray", "%s - %s" % { translate("V2Ray"), translate("Policy") })

s = m:section(TypedSection, "policy")
s.anonymous = true
s.addremove = true
s.sortable = true

o = s:option(MultiValue, "levels", translate("Levels"))

o = s:option(ListValue, "system", translate("System"))

s = m:section(TypedSection, "policy_level")
s.anonymous = true
s.addremove = true
s.sortable = true
s.template = "cbi/tblsection"
s.extedit = dsp.build_url("admin/services/policy/levels/%s")
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

s = m:section(TypedSection, "policy_system")
s.anonymous = true
s.addremove = true
s.sortable = true

o = s:option(Flag, "stats_inbound_uplink", translate("Stats inbound uplink"))

o = s:option(Flag, "stats_inbound_downlink", translate("Stats inbound downlink"))

return m
