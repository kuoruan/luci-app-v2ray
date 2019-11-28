-- Copyright 2019 Xingwang Liao <kuoruan@gmail.com>
-- Licensed to the public under the MIT License.

local http = require "luci.http"
local uci = require "luci.model.uci".cursor()
local sys = require "luci.sys"
local fs = require "nixio.fs"
local v2ray = require "luci.model.v2ray"
local i18n = require "luci.i18n"
local util = require "luci.util"

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

	entry({"admin", "services", "v2ray", "reverse"},
		cbi("v2ray/reverse"), _("Reverse"), 7)

	entry({"admin", "services", "v2ray", "transparent-proxy"},
		cbi("v2ray/transparent-proxy"), _("Transparent Proxy"), 8)

	entry({"admin", "services", "v2ray", "about"},
		form("v2ray/about"), _("About"), 9)

	entry({"admin", "services", "v2ray", "routing", "rules"},
		cbi("v2ray/routing-rule-detail")).leaf = true

	entry({"admin", "services", "v2ray", "policy", "levels"},
		cbi("v2ray/policy-level-detail")).leaf = true

	entry({"admin", "services", "v2ray", "status"}, call("action_status"))

	entry({"admin", "services", "v2ray", "version"}, call("action_version"))

	entry({"admin", "services", "v2ray", "list-status"},
		call("list_status")).leaf = true

	entry({"admin", "services", "v2ray", "list-update"}, call("list_update"))
end

function action_status()
	local running = false

	local pid = util.trim(fs.readfile("/var/run/v2ray.main.pid") or "")

	if pid ~= "" then
		local file = uci:get("v2ray", "main", "v2ray_file") or ""
		if file ~= "" then
			local file_name = fs.basename(file)
			running = sys.call("pidof %s 2>/dev/null | grep -q %s" % { file_name, pid }) == 0
		end
	end

	http.prepare_content("application/json")
	http.write_json({
		running = running
	})
end

function action_version()
	local file = uci:get("v2ray", "main", "v2ray_file") or ""

	local info

	if file == "" or not fs.stat(file) then
		info = {
			valid = false,
			message = i18n.translate("Invalid V2Ray file")
		}
	else
		if not fs.access(file, "rwx", "rx", "rx") then
			fs.chmod(file, 755)
		end

		local version = util.trim(sys.exec("%s --version 2>/dev/null | head -n1" % file))

		if version ~= "" then
			info = {
				valid = true,
				version = version
			}
		else
			info = {
				valid = false,
				message = i18n.translate("Can't get V2Ray version")
			}
		end
	end

	http.prepare_content("application/json")
	http.write_json(info)
end

function list_status(type)
	if type == "chnroute" then
		http.prepare_content("application/json")
		http.write_json(v2ray.get_routelist_status())
	elseif type == "gfwlist" then
		http.prepare_content("application/json")
		http.write_json(v2ray.get_gfwlist_status())
	else
		http.status(500, "Bad address")
	end
end

function list_update()
	local type = http.formvalue("type")

	if type == "chnroute" then
		local chnroute_result, chnroute6_result = v2ray.generate_routelist()
		http.prepare_content("application/json")
		http.write_json({
			chnroute = chnroute_result,
			chnroute6 = chnroute6_result
		})
	elseif type == "gfwlist" then
		local result = v2ray.generate_gfwlist()
		http.prepare_content("application/json")
		http.write_json({
			gfwlist = result
		})
	else
		http.status(500, "Bad address")
	end
end
