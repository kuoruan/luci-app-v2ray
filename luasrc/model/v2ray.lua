-- Copyright 2019 Xingwang Liao <kuoruan@gmail.com>
-- Licensed to the public under the MIT License.

local nixio = require "nixio"
local util = require "luci.util"
local json = require "luci.jsonc"
local sys = require "luci.sys"

module("luci.model.v2ray", package.seeall)

local data_settings = "/etc/v2ray/data-settings.json"
local data_stream_settings = "/etc/v2ray/data-stream-settings.json"
local data_transport = "/etc/v2ray/data-transport.json"

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

	if type(obj) == 'table' and not next(obj) then
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

function is_ipv4(addr)
	if addr == nil or type(addr) ~= "string" then
		return false
	end

	local chunks = {
		addr:match("(%d+)%.(%d+)%.(%d+)%.(%d+)")
	}

	if (#chunks == 4) then
		for _, v in pairs(chunks) do
			local n = tonumber(v)
			if (n < 0 or n > 255) then
				return false
			end
		end

		return true
	else
		return false
	end
end

function is_ipv6(addr)
	if addr == nil or type(addr) ~= "string" then
		return false
	end

	local addrs = addr:match("^([a-fA-F0-9:]+)$")

	if addrs ~= nil and #addrs > 1 then
		local nc, dc = 0, false -- chunk count, double colon
		for chunk, colons in addrs:gmatch("([^:]*)(:*)") do
			if nc > (dc and 7 or 8) then -- max allowed chunks
				return false
			end

			if #chunk > 0 and tonumber(chunk, 16) > 65535 then
				return false
			end

			if #colons > 0 then
				-- max consecutive colons allowed: 2
				if #colons > 2 then return false end

				-- double colon shall appear only once
				if #colons == 2 and dc == true then return false end

				if #colons == 2 and dc == false then dc = true end
			end
			nc = nc + 1
		end

		return true
	end

	return false
end
