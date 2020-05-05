module("luci.controller.v2ray", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/v2ray") then
		return
	end

	entry({"admin", "services", "v2ray"}, firstchild(), _("V2Ray")).dependent = false

	entry({"admin", "services", "v2ray", "global"}, view("v2ray/main"), _("Global Settings"), 1)

	entry({"admin", "services", "v2ray", "inbounds"}, view("v2ray/inbound"), _("Inbound"), 2).leaf = true

	entry({"admin", "services", "v2ray", "outbounds"}, view("v2ray/outbound"), _("Outbound"), 3).leaf = true

	entry({"admin", "services", "v2ray", "dns"}, view("v2ray/dns"), _("DNS"), 4)

	entry({"admin", "services", "v2ray", "routing"}, view("v2ray/routing"), _("Routing"), 5)

	entry({"admin", "services", "v2ray", "policy"}, view("v2ray/policy"), _("Policy"), 6)

	entry({"admin", "services", "v2ray", "reverse"}, view("v2ray/reverse"), _("Reverse"), 7)

	entry({"admin", "services", "v2ray", "transparent-proxy"}, view("v2ray/transparent-proxy"), _("Transparent Proxy"), 8)

	entry({"admin", "services", "v2ray", "about"}, view("v2ray/about"), _("About"), 9)
end
