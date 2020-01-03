-- Copyright 2019-2020 Xingwang Liao <kuoruan@gmail.com>
-- Licensed to the public under the MIT License.

local dsp = require "luci.dispatcher"
local uci = require "luci.model.uci".cursor()
local util = require "luci.util"

local m, s1, s2, s3, o

local rule_keys, rule_table, balancer_keys, balancer_table = {}, {}, {}, {}

uci:foreach("v2ray", "routing_rule", function(s)
	if s.alias then
		local key = s[".name"]
		util.append(rule_keys, key)
		rule_table[key] = s.alias
	end
end)

uci:foreach("v2ray", "routing_balancer", function(s)
	if s.tag then
		local key = s[".name"]
		util.append(balancer_keys, key)
		balancer_table[key] = s.tag
	end
end)

m = Map("v2ray", "%s - %s" % { translate("V2Ray"), translate("Routing") },
	translatef("Details: %s", "<a href=\"https://www.v2ray.com/en/configuration/routing.html#routingobject\" target=\"_blank\">RoutingObject</a>"))

s1 = m:section(NamedSection, "main_routing", "routing")
s1.anonymous = true
s1.addremove = false

o = s1:option(Flag, "enabled", translate("Enabled"))

o = s1:option(ListValue, "domain_strategy", translate("Domain resolution strategy"))
o:value("")
o:value("AsIs")
o:value("IPIfNonMatch")
o:value("IPOnDemand")

o = s1:option(MultiValue, "rules", translate("Rules"), translate("Select routing rules to use"))
for _, v in ipairs(rule_keys) do
	o:value(v, rule_table[v])
end

o = s1:option(MultiValue, "balancers", translate("Balancers"), translate("Select routing balancers to use"))
for _, v in ipairs(balancer_keys) do
	o:value(v, balancer_table[v])
end

s2 = m:section(TypedSection, "routing_rule", translate("Routing Rule"), translate("Add routing rules here"))
s2.anonymous = true
s2.addremove = true
s2.sortable = true
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

o = s2:option(DummyValue, "inbound_tag", translate("Inbound Tag"))
o.cfgvalue = function (self, section)
	local v = self.map:get(section, self.option)
	if type(v) == "table" then
		return table.concat(v, " ")
	end
	return v and v or "?"
end

o = s2:option(DummyValue, "outbound_tag", translate("Outbound Tag"))
o.cfgvalue = function (...)
	return Value.cfgvalue(...) or "?"
end

o = s2:option(DummyValue, "network", translate("Network"))
o.cfgvalue = function (...)
	return Value.cfgvalue(...) or "?"
end

s3 = m:section(TypedSection, "routing_balancer", translate("Routing Balancer"), translate("Add routing balancers here"))
s3.anonymous = true
s3.addremove = true

o = s3:option(Value, "tag", translate("Tag"))
o.rmempty = false

o = s3:option(DynamicList, "selector", translate("Selector"))

return m
