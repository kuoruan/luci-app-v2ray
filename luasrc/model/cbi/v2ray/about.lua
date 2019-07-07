-- Copyright 2019 Xingwang Liao <kuoruan@gmail.com>
-- Licensed to the public under the MIT License.

local uci = require "luci.model.uci".cursor()
local util = require "luci.util"
local fs = require "nixio.fs"

local config_file = uci:get("v2ray", "main", "config_file")

if not config_file or util.trim(config_file) == "" then
  config_file = "/var/etc/v2ray/v2ray.main.json"
end

local config_content = fs.readfile(config_file) or translate("Failed to open file.")

m = SimpleForm("v2ray", "%s - %s" % { translate("V2Ray"), translate("About") },
  "<p>%s</p><p>%s</p><p>%s</p><p>%s</p><p>%s</p><p>%s</p><p>%s</p><p>%s</p>" % {
    translate("LuCI support for V2Ray."),
    translatef("Author: %s", "Xingwang Liao"),
    translatef(
      "Source: %s",
      "<a href=\"https://github.com/kuoruan/luci-app-v2ray\" target=\"_blank\">https://github.com/kuoruan/luci-app-v2ray</a>"
    ),
    translatef(
      "Latest: %s",
      "<a href=\"https://github.com/kuoruan/luci-app-v2ray/releases/latest\" target=\"_blank\">https://github.com/kuoruan/luci-app-v2ray/releases/latest</a>"
    ),
    translatef(
      "Report Bugs: %s",
      "<a href=\"https://github.com/kuoruan/luci-app-v2ray/issues\" target=\"_blank\">https://github.com/kuoruan/luci-app-v2ray/issues</a>"
    ),
    translatef(
      "Donate: %s",
      "<a href=\"https://blog.kuoruan.com/donate\" target=\"_blank\">https://blog.kuoruan.com/donate</a>"
    ),
    translatef("Current Config File: %s", config_file),
    "<pre>%s</pre>" % config_content,
  })

m.reset = false
m.submit = false

return m
