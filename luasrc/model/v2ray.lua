-- Copyright 2019 Xingwang Liao <kuoruan@gmail.com>
-- Licensed to the public under the MIT License.

local fs   = require "nixio.fs"
local util = require "luci.util"
local json = require "luci.jsonc"

module("luci.model.v2ray", package.seeall)

function string_to_object(content)
	if not content then
		return nil
	end

	local obj = json.parse(content)
	return obj
end

function object_to_string(obj)
	if not obj then
		return ""
	end
	if type(obj) == 'table' and not next(obj) then
		return "{}"
	end

	return json.stringify(obj, true) or ""
end

function read_file_as_object(path)
	local content = fs.readfile(path)
	return string_to_object(content)
end

function write_object_to_file(path, value)
	local content = object_to_string(value)
	return fs.writefile(path, content)
end

function add_value_to_file(path, key, value)
	local keys = util.split(key, ".")

	local json = read_file_as_object(path) or {}
	local obj
	if type(value) == 'string' then
		obj = string_to_object(value) or value
	else
		obj = value
	end

	local c = json
	for j=1, #keys do
		local k = keys[j]
		if j ~= #keys then
			if not c[k] then
				c[k] = {}
			end

			c = c[k]
		else
			c[k] = obj
		end
	end

	return write_object_to_file(path, json)
end

function get_value_from_file(path, key)
	local keys = util.split(key, ".")

	local obj = read_file_as_object(path) or {}

	local o = obj
	for j=1, #keys do
		o = o[keys[j]]
		if not o then
			break
		end
	end

	return object_to_string(o)
end

function remove_value_from_file(path, key)
	local keys = util.split(key, ".")

	local json = read_file_as_object(path) or {}

	local o = json
	for j=1, #keys do
		local k = keys[j]
		if j ~= #keys then
			o = o[k]
		else
			o[k] = nil
		end
	end

	return write_object_to_file(path, json)
end

function is_json_string(value)
	if type(value) ~= 'string' then
		return false
	end

	return string_to_object(value) ~= nil
end
