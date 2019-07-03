-- Copyright 2019 Xingwang Liao <kuoruan@gmail.com>
-- Licensed to the public under the MIT License.

local dsp = require "luci.dispatcher"

local m, s1, s2, s3, o

m = Map("v2ray", "%s - %s" % { translate("V2Ray"), translate("Routing") })

s1 = m:section(NamedSection, "main_routing", "routing")
s1.anonymous = true
s1.addremove = false

o = s1:option(Flag, "enabled", translate("Enabled"))

o = s1:option(ListValue, "domain_strategy", translate("Domain resolution strategy"))
o:value("AsIs")
o:value("IPIfNonMatch")
o:value("IPOnDemand")

o = s1:option(MultiValue, "rules", translate("Rules"), translate("Select routing rules to use"))

o = s1:option(MultiValue, "balancers", translate("Balancers"), translate("Select routing balancers to use"))

s2 = m:section(TypedSection, "routing_rule", translate("Routing Rule"))
s2.anonymous = true
s2.addremove = true
s2.template = "cbi/tblsection"
s2.extedit = dsp.build_url("admin/services/v2ray/routing/rules/%s")
s2.create = function (...)
	local sid = TypedSection.create(...)
	if sid then
		m.uci:save("v2ray")
		luci.http.redirect(s2.extedit % sid)
		return
	end
end

o = s2:option(DummyValue, "alias", translate("Alias"))
o.cfgvalue = function (...)
	return Value.cfgvalue(...) or "?"
end

o = s2:option(DummyValue, "type", translate("Type"))
o.cfgvalue = function (...)
	return Value.cfgvalue(...) or "?"
end

o = s2:option(DummyValue, "port", translate("Port"))
o.cfgvalue = function (...)
	return Value.cfgvalue(...) or "?"
end

o = s2:option(DummyValue, "network", translate("Network"))
o.cfgvalue = function (...)
	return Value.cfgvalue(...) or "?"
end

s3 = m:section(TypedSection, "routing_balancer", translate("Routing Balancer"))
s3.anonymous = true
s3.addremove = true

o = s3:option(Value, "tag", translate("Tag"))

o = s3:option(DynamicList, "selector", translate("Selector"))

return m
