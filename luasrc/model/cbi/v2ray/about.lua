-- Copyright 2019 Xingwang Liao <kuoruan@gmail.com>
-- Licensed to the public under the MIT License.

m = SimpleForm("v2ray", "%s - %s" % { translate("V2Ray"), translate("About") },
  "<p>%s</p><p>%s</p><p>%s</p><p>%s</p><p>%s</p><p>%s</p>" % {
    translatef("LuCI support for V2Ray"),
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
  })

m.reset = false
m.submit = false

return m
