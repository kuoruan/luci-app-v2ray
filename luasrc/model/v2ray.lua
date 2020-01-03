-- Copyright 2019-2020 Xingwang Liao <kuoruan@gmail.com>
-- Licensed to the public under the MIT License.

local nixio = require "nixio"
local util = require "luci.util"
local sys = require "luci.sys"
local uci = require "luci.model.uci".cursor()
local json = require "luci.jsonc"

module("luci.model.v2ray", package.seeall)

local gfwlist_urls = {
	["github"] = "https://raw.githubusercontent.com/gfwlist/gfwlist/master/gfwlist.txt",
	["gitlab"] = "https://gitlab.com/gfwlist/gfwlist/raw/master/gfwlist.txt",
	["pagure"] = "https://pagure.io/gfwlist/raw/master/f/gfwlist.txt",
	["bitbucket"] = "https://bitbucket.org/gfwlist/gfwlist/raw/HEAD/gfwlist.txt"
}

local apnic_delegated_urls = {
	["apnic"] = "https://ftp.apnic.net/stats/apnic/delegated-apnic-latest",
	["arin"] = "https://ftp.arin.net/pub/stats/apnic/delegated-apnic-latest",
	["ripe"] = "https://ftp.ripe.net/pub/stats/apnic/delegated-apnic-latest",
	["iana"] = "https://ftp.iana.org/pub/mirror/rirstats/apnic/delegated-apnic-latest"
}

local apnic_delegated_extended_url = "https://ftp.apnic.net/stats/apnic/delegated-apnic-extended-latest"
local cn_zone_url = "http://www.ipdeny.com/ipblocks/data/countries/cn.zone"

local gfwlist_file = "/etc/v2ray/gfwlist.txt"
local chnroute_file_ipv4 = "/etc/v2ray/chnroute.txt"
local chnroute_file_ipv6 = "/etc/v2ray/chnroute6.txt"

function generate_gfwlist()
	local gfwlist_mirror = uci:get("v2ray", "main_transparent_proxy", "gfwlist_mirror") or "github"

	local gfwlist_url = gfwlist_urls[gfwlist_mirror]

	if not gfwlist_url then
		gfwlist_url = gfwlist_urls['github']
	end

	local f = sys.httpget(gfwlist_url, true)
	if not f then
		return false
	end

	local t = {}

	for line in f:lines() do
		t[#t+1] = line
	end

	f:close()

	if not next(t) then
		return false
	end

	local content = table.concat(t, "")

	local domains = {}

	local decoded = nixio.bin.b64decode(content)

	for line in util.imatch(decoded) do
		if not string.match(line, "^$") and
			not string.match(line, "^[!%[@]") and
			not string.match(line, "^%d+%.%d+%.%d+%.%d+") then
			local start, _, domain = string.find(line, "(%w[%w%-_]+%.%w[%w%.%-_]+)")

			if start then
				domains[domain] = true
			end
		end
	end

	if not next(domains) then
		return false
	end

	local result = false
	local temp = util.trim(sys.exec("mktemp /tmp/gfwlist.XXXXXX"))

	local out_temp = io.open(temp, "w")

	if not out_temp then
		return false
	end

	for k in util.kspairs(domains) do
		out_temp:write(k, "\n")
	end

	out_temp:flush()
	out_temp:close()

	local file_size = nixio.fs.stat(temp, "size")
	if file_size and file_size > 1 then
		local code = sys.call("cat %s >%s 2>/dev/null" % {
			util.shellquote(temp),
			util.shellquote(gfwlist_file)
		})

		result = (code == 0)
	end

	nixio.fs.remove(temp)

	return result
end

function generate_routelist()
	local apnic_delegated_mirror = uci:get("v2ray", "main_transparent_proxy", "apnic_delegated_mirror") or "apnic"

	local apnic_delegated_url = apnic_delegated_urls[apnic_delegated_mirror]

	if not apnic_delegated_url then
		apnic_delegated_url = apnic_delegated_urls['apnic']
	end

	local f = sys.httpget(apnic_delegated_url, true)
	if not f then
		return false, false
	end

	local result_ipv4, result_ipv6 = false, false

	local temp_ipv4 = util.trim(sys.exec("mktemp /tmp/chnroute.XXXXXX"))
	local temp_ipv6 = util.trim(sys.exec("mktemp /tmp/chnroute6.XXXXXX"))

	local out_temp_ipv4 = io.open(temp_ipv4, "w")
	local out_temp_ipv6 = io.open(temp_ipv6, "w")

	if not out_temp_ipv4 or not out_temp_ipv6 then
		return false, false
	end

	for line in f:lines() do
		local start, _, type, ip, value = string.find(line, "CN|(ipv%d)|([%d%.:]+)|(%d+)")

		if start then
			if type == "ipv4" then
				local mask = 32 - math.log(tonumber(value)) / math.log(2)
				out_temp_ipv4:write(string.format("%s/%d", ip, mask), "\n")
			elseif type == "ipv6" then
				out_temp_ipv6:write(string.format("%s/%s", ip, value), "\n")
			end
		end
	end

	f:close()

	out_temp_ipv4:flush()
	out_temp_ipv4:close()

	out_temp_ipv6:flush()
	out_temp_ipv6:close()

	local file_size_ipv4 = nixio.fs.stat(temp_ipv4, "size")
	local file_size_ipv6 = nixio.fs.stat(temp_ipv6, "size")

	if file_size_ipv4 and file_size_ipv4 > 1 then
		local code = sys.call("cat %s >%s 2>/dev/null" % {
			util.shellquote(temp_ipv4),
			util.shellquote(chnroute_file_ipv4)
		})

		result_ipv4 = (code == 0)
	end

	if file_size_ipv6 and file_size_ipv6 > 1 then
		local code = sys.call("cat %s >%s 2>/dev/null" % {
			util.shellquote(temp_ipv6),
			util.shellquote(chnroute_file_ipv6)
		})

		result_ipv6 = (code == 0)
	end

	nixio.fs.remove(temp_ipv4)
	nixio.fs.remove(temp_ipv6)

	return result_ipv4, result_ipv6
end

function get_gfwlist_status()
	local gfwlist_size = util.exec("cat %s | grep -v '^$' | wc -l" % util.shellquote(gfwlist_file))
	local gfwlist_time = util.exec("date -r %s '+%%Y/%%m/%%d %%H:%%M:%%S'" % util.shellquote(gfwlist_file))

	return {
		gfwlist = {
			size = tonumber(gfwlist_size),
			lastModify = gfwlist_time ~= "" and util.trim(gfwlist_time) or "-/-/-"
		}
	}
end

function get_routelist_status()
	local chnroute_size = util.exec("cat %s | grep -v '^$' | wc -l" % util.shellquote(chnroute_file_ipv4))
	local chnroute_time = util.exec("date -r %s '+%%Y/%%m/%%d %%H:%%M:%%S'" % util.shellquote(chnroute_file_ipv4))

	local chnroute6_size = util.exec("cat %s | grep -v '^$' | wc -l" % util.shellquote(chnroute_file_ipv6))
	local chnroute6_time = util.exec("date -r %s '+%%Y/%%m/%%d %%H:%%M:%%S'" % util.shellquote(chnroute_file_ipv4))

	return {
		chnroute = {
			size = tonumber(chnroute_size),
			lastModify = chnroute_time ~= "" and util.trim(chnroute_time) or "-/-/-"
		},
		chnroute6 = {
			size = tonumber(chnroute6_size),
			lastModify = chnroute6_time ~= "" and util.trim(chnroute6_time) or "-/-/-"
		}
	}
end

function vmess_to_object(link)
	local content = string.match(link, "^vmess://(%S+)")

	if not content or content == "" then
		return nil
	end

	local decoded = nixio.bin.b64decode(content)

	if not decoded or decoded == "" then
		return nil
	end

	return json.parse(decoded)
end
