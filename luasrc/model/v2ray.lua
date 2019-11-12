-- Copyright 2019 Xingwang Liao <kuoruan@gmail.com>
-- Licensed to the public under the MIT License.

local nixio = require "nixio"
local util = require "luci.util"
local json = require "luci.jsonc"
local sys = require "luci.sys"
local uci = require "luci.model.uci".cursor()

module("luci.model.v2ray", package.seeall)

local data_settings = "/etc/v2ray/data-settings.json"
local data_stream_settings = "/etc/v2ray/data-stream-settings.json"
local data_transport = "/etc/v2ray/data-transport.json"

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

function random_setting_key()
	return sys.uniqueid(4)
end

function json_string_to_object(content)
	if not content or content == "" then
		return nil
	end

	return json.parse(content)
end

function object_to_json_string(obj, format)
	if not obj then
		return ""
	end

	if format == nil then
		format = true
	end

	if type(obj) == "table" and not next(obj) then
		return "{}"
	end

	return json.stringify(obj, format) or ""
end

function read_object_from_file(path)
	if not nixio.fs.access(path) then
		return nil
	end

	local content = nixio.fs.readfile(path)
	return json_string_to_object(content)
end

function write_object_to_file(path, value)
	local content = object_to_json_string(value, true)
	return nixio.fs.writefile(path, content)
end

function save_value_to_file(path, key, value)
	local keys = util.split(key, ".")

	if type(value) == "table" then
		value = object_to_json_string(value, false)
	end

	local obj = read_object_from_file(path) or {}

	local c = obj
	for j=1, #keys do
		local k = keys[j]
		if j ~= #keys then
			if not c[k] then
				c[k] = {}
			end

			c = c[k]
		else
			c[k] = value
		end
	end

	return write_object_to_file(path, obj)
end

function get_value_from_file(path, key)
	local keys = util.split(key, ".")

	local obj = read_object_from_file(path) or {}

	local o = obj
	for j=1, #keys do
		o = o[keys[j]]
		if not o then
			break
		end
	end

	if type(o) == "table" then
		return object_to_json_string(o, false)
	end

	return o
end

function remove_value_from_file(path, key)
	local keys = util.split(key, ".")

	local obj = read_object_from_file(path) or {}

	local o = obj
	for j=1, #keys do
		local k = keys[j]
		if j ~= #keys then
			o = o[k]
			if not o then
				break
			end
		else
			o[k] = nil
		end
	end

	return write_object_to_file(path, obj)
end

function is_json_string(value)
	if type(value) ~= "string" then
		return false
	end

	return json_string_to_object(value) ~= nil
end

-- settings json
function get_setting(key)
	local setting_base64 = get_value_from_file(data_settings, key)

	if not setting_base64 or util.trim(setting_base64) == "" then
		return ""
	end

	return nixio.bin.b64decode(setting_base64)
end

function save_setting(key, value)
	if not value or util.trim(value) == "" then
		return save_value_to_file(data_settings, key, "")
	end

	local setting_base64 = nixio.bin.b64encode(value)
	return save_value_to_file(data_settings, key, setting_base64)
end

function remove_setting(key)
	return remove_value_from_file(data_settings, key)
end

-- stream settings json
function get_stream_setting(key)
	local setting_base64 = get_value_from_file(data_stream_settings, key)

	if not setting_base64 or util.trim(setting_base64) == "" then
		return ""
	end

	return nixio.bin.b64decode(setting_base64)
end

function save_stream_setting(key, value)
	if not value or util.trim(value) == "" then
		return save_value_to_file(data_stream_settings, key, "")
	end

	local setting_base64 = nixio.bin.b64encode(value)
	return save_value_to_file(data_stream_settings, key, setting_base64)
end

function remove_stream_setting(key)
	return remove_value_from_file(data_stream_settings, key)
end

-- transport json
function get_transport(key)
	local setting_base64 = get_value_from_file(data_transport, key)

	if not setting_base64 or util.trim(setting_base64) == "" then
		return ""
	end

	return nixio.bin.b64decode(setting_base64)
end

function save_transport(key, value)
	if not value or util.trim(value) == "" then
		return save_value_to_file(data_transport, key, "")
	end

	local setting_base64 = nixio.bin.b64encode(value)
	return save_value_to_file(data_transport, key, setting_base64)
end

function remove_transport(key)
	return remove_value_from_file(data_transport, key)
end

function get_url_content(url)
	local f = sys.httpget(url, true)

	if f ~= nil then
		local file = f:read("*all")
		f:close()

		return file
	end

	return nil
end

function generate_gfwlist()
	local gfwlist_mirror = uci:get("v2ray", "main_transparent_proxy", "gfwlist_mirror") or "github"

	local gfwlist_url = gfwlist_urls[gfwlist_mirror]

	if gfwlist_url == nil then
		gfwlist_url = gfwlist_urls['github']
	end

	local content = get_url_content(gfwlist_url)

	if content == nil or content == "" then
		return false
	end

	local domains = {}

	local content = string.gsub(content, "[\r\n%s]+", "")
	local decoded = nixio.bin.b64decode(content)

	for line in util.imatch(decoded) do
		if not string.match(line, "^$") and
			not string.match(line, "^[!%[@]") and
			not string.match(line, "^%d+%.%d+%.%d+%.%d+") then
			local start, _, domain = string.find(line, "(%w[%w%-_]+%.%w[%w%.%-_]+)")

			if start ~= nil then
				domains[domain] = true
			end
		end
	end

	if not next(domains) then
		return false
	end

	local result = false
	local temp = sys.exec("mktemp /tmp/gfwlist.XXXXXX")

	local out_temp = io.open(temp, "w")

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

	if apnic_delegated_url == nil then
		apnic_delegated_url = apnic_delegated_urls['apnic']
	end

	local content = get_url_content(apnic_delegated_url)

	if content == nil or content == "" then
		return false, false
	end

	local result_ipv4, result_ipv6 = false, false

	local temp_ipv4 = sys.exec("mktemp /tmp/chnroute.XXXXXX")
	local temp_ipv6 = sys.exec("mktemp /tmp/chnroute6.XXXXXX")

	local out_temp_ipv4 = io.open(temp_ipv4, "w")
	local out_temp_ipv6 = io.open(temp_ipv6, "w")

	for line in util.imatch(content) do
		local start, _, type, ip, value = string.find(line, "CN|(ipv%d)|([%d%.:]+)|(%d+)")

		if start ~= nil then
			if type == "ipv4" then
				local mask = 32 - math.log(tonumber(value)) / math.log(2)
				out_temp_ipv4:write(string.format("%s/%d", ip, mask), "\n")
			elseif type == "ipv6" then
				out_temp_ipv6:write(string.format("%s/%s", ip, value), "\n")
			end
		end
	end

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
