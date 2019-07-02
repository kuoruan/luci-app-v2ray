-- Copyright 2019 Xingwang Liao <kuoruan@gmail.com>
-- Licensed to the public under the MIT License.

local fs   = require "nixio.fs"
local sys  = require "luci.sys"
local uci  = require "luci.model.uci".cursor()
local util = require "luci.util"
local json = require "luci.jsonc"

module("luci.model.v2ray", package.seeall)

function read_file_as_object(path)
  local content = fs.readfile(path) or ""

  return json.parse(content) or {}
end

function write_object_to_file(path, value)
  local content = json.stringify(value or {})

  return fs.writefile(path, content)
end

function string_to_object(content)
  return json.parse(content)
end

function object_to_string(obj)
  return json.stringify(obj) or ""
end

function add_value_to_file(path, key, value)
  local keys = util.split(key, ".")

  local json = read_file_as_object(path)
  local obj = string_to_object(value)

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

  local obj = read_file_as_object(path)

  local o = obj
  for j=1, #keys do
    o = o[keys[j]]
  end

  return object_to_string(o)
end

function remove_file_value(path, key)
  local keys = util.split(key, ".")

  local json = read_file_as_object(path)

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
