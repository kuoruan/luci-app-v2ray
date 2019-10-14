-- Copyright 2019 Xingwang Liao <kuoruan@gmail.com>
-- Licensed to the public under the MIT License.

local dsp = require "luci.dispatcher"
local v2ray = require "luci.model.v2ray"

local m, s, o

m = Map("v2ray", "%s - %s" % { translate("V2Ray"), translate("Inbound") })

s = m:section(TypedSection, "inbound")
s.anonymous = true
s.addremove = true
s.sortable = true
s.template = "cbi/tblsection"
s.extedit = dsp.build_url("admin/services/v2ray/inbounds/%s")
s.create = function (...)
	local sid = TypedSection.create(...)
	if sid then
		m.uci:save("v2ray")
		luci.http.redirect(s.extedit % sid)
		return
	end
end
s.remove = function (self, section)
	local settings_key = self.map:get(section, "settings") or ""
	local stream_settings_key = self.map:get(section, "stream_settings") or ""

	if settings_key ~= "" then
		v2ray.remove_setting(settings_key)
	end

	if stream_settings_key ~= "" then
		v2ray.remove_stream_setting(stream_settings_key)
	end

	return TypedSection.remove(self, section)
end

o = s:option(DummyValue, "alias", translate("Alias"))
o.cfgvalue = function (...)
	return Value.cfgvalue(...) or "?"
end

o = s:option(DummyValue, "listen", translate("Listen"))
o.cfgvalue = function (...)
	return Value.cfgvalue(...) or "-"
end

o = s:option(DummyValue, "port", translate("Port"))
o.cfgvalue = function (...)
	return Value.cfgvalue(...) or "?"
end

o = s:option(DummyValue, "protocol", translate("Protocol"))
o.cfgvalue = function (...)
	return Value.cfgvalue(...) or "?"
end

o = s:option(DummyValue, "tag", translate("Tag"))
o.cfgvalue = function (...)
	return Value.cfgvalue(...) or "?"
end

o = s:option(DummyValue, "transparent_proxy_enabled", translate("Transparent Proxy"))
o.cfgvalue = function (...)
	local v = Value.cfgvalue(...)
	return v == "1" and translate("Yes") or translate("No")
end

return m
