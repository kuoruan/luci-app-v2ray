-- Copyright 2019 Xingwang Liao <kuoruan@gmail.com>
-- Licensed to the public under the MIT License.

local http = require "luci.http"
local uci = require "luci.model.uci".cursor()
local sys = require "luci.sys"

module("luci.controller.frpc", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/v2ray") then
		return
	end
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
