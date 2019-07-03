-- Copyright 2019 Xingwang Liao <kuoruan@gmail.com>
-- Licensed to the public under the MIT License.

local http = require "luci.http"
local uci = require "luci.model.uci".cursor()
local sys = require "luci.sys"

module("luci.controller.v2ray", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/v2ray") then
		return
	end

	entry({"admin", "services", "v2ray"},
		firstchild(), _("V2Ray")).dependent = false

	entry({"admin", "services", "v2ray", "global"},
		cbi("v2ray/main"), _("Global Settings"), 1)

	entry({"admin", "services", "v2ray", "inbounds"},
		arcombine(cbi("v2ray/inbound-list"), cbi("v2ray/inbound-detail")),
		_("Inbound"), 2).leaf = true

	entry({"admin", "services", "v2ray", "outbounds"},
		arcombine(cbi("v2ray/outbound-list"), cbi("v2ray/outbound-detail")),
		_("Outbound"), 3).leaf = true

	entry({"admin", "services", "v2ray", "dns"},
		cbi("v2ray/dns"), _("DNS"), 4)

	entry({"admin", "services", "v2ray", "routing"},
		arcombine(cbi("v2ray/routing"), cbi("v2ray/routing-rule-detail")),
		_("Routing"), 5)

	entry({"admin", "services", "v2ray", "policy"},
		arcombine(cbi("v2ray/policy"), cbi("v2ray/policy-level-detail")),
		_("Policy"), 6)

	entry({"admin", "services", "v2ray", "routing", "rules"},
		cbi("v2ray/routing-rule-detail")).leaf = true

	entry({"admin", "services", "v2ray", "policy", "levels"},
		cbi("v2ray/policy-level-detail")).leaf = true

	entry({"admin", "services", "v2ray", "status"}, call("action_status"))
end

function action_status()
	local running = false
	local file = uci:get("v2ray", "main", "v2ray_file")
	if file and file ~= "" then
		local file_name = file:match(".*/([^/]+)$") or ""
		if file_name ~= "" then
			running = sys.call("pidof %s >/dev/null" % file_name) == 0
		end
	end

	http.prepare_content("application/json")
	http.write_json({
		running = running
	})
end
