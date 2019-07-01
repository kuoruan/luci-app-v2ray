-- Copyright 2019 Xingwang Liao <kuoruan@gmail.com>
-- Licensed to the public under the MIT License.

local dsp = require "luci.dispatcher"

local m, s, o

m = Map("v2ray", "%s - %s" % { translate("V2Ray"), translate("Routing") })

s = m:section(TypedSection, "routing")
s.anonymous = true
s.addremove = true
s.sortable = true

o = s:option(ListValue, "domain_strategy", translate("Domain resolution strategy"))
o:value("AsIs")
o:value("IPIfNonMatch")
o:value("IPOnDemand")

o = s:option(MultiValue, "rules", translate("Rules"))

o = s:option(MultiValue, "balancers", translate("Balancers"))

s = m:section(TypedSection, "routing_rule")
s.anonymous = true
s.addremove = true
s.sortable = true
s.template = "cbi/tblsection"
s.extedit = dsp.build_url("admin/services/routing/rules/%s")
function s.create(...)
	local sid = TypedSection.create(...)
	if sid then
		m.uci:save("v2ray")
		luci.http.redirect(s.extedit % sid)
		return
	end
end

o = s:option(DummyValue, "alias", translate("Alias"))
o.cfgvalue = function (...)
	return Value.cfgvalue(...) or "?"
end

o = s:option(DummyValue, "type", translate("Type"))
o.cfgvalue = function (...)
	return Value.cfgvalue(...) or "?"
end

o = s:option(DummyValue, "port", translate("Port"))
o.cfgvalue = function (...)
	return Value.cfgvalue(...) or "?"
end

o = s:option(DummyValue, "network", translate("Network"))
o.cfgvalue = function (...)
	return Value.cfgvalue(...) or "?"
end

s = m:section(TypedSection, "routing_balancer")
s.anonymous = true
s.addremove = true
s.sortable = true

o = s:option(Value, "tag", translate("Tag"))

o = s:option(DynamicList, "selector", translate("Tag"))

return m
