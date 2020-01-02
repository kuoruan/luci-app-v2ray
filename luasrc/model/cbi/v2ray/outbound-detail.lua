-- Copyright 2019 Xingwang Liao <kuoruan@gmail.com>
-- Licensed to the public under the MIT License.

local dsp = require "luci.dispatcher"
local nixio = require "nixio"
local util = require "luci.util"

local m, s, o

local sid = arg[1]

m = Map("v2ray", "%s - %s" % { translate("V2Ray"), translate("Edit Outbound") },
	translatef("Details: %s", "<a href=\"https://www.v2ray.com/en/configuration/overview.html#outboundobject\" target=\"_blank\">OutboundObject</a>"))
m.redirect = dsp.build_url("admin/services/v2ray/outbounds")

if m.uci:get("v2ray", sid) ~= "outbound" then
	luci.http.redirect(m.redirect)
	return
end

local local_ips = { "0.0.0.0", "::" }

for _, v in ipairs(nixio.getifaddrs()) do
	if v.addr and
		(v.family == "inet" or v.family == "inet6") and
		v.name ~= "lo" and
		not util.contains(local_ips, v.addr)
	then
		util.append(local_ips, v.addr)
	end
end

s = m:section(NamedSection, sid, "outbound")
s.anonymous = true
s.addremove = false

o = s:option(Value, "alias", translate("Alias"), translate("Any custom string"))
o.rmempty = false

o = s:option(Value, "send_through", translate("Send through"), translate("An IP address for sending traffic out."))
o.datatype = "ipaddr"
for _, v in ipairs(local_ips) do
	o:value(v)
end

o = s:option(ListValue, "protocol", translate("Protocol"))
o:value("blackhole", "Blackhole")
o:value("dns", "DNS")
o:value("freedom", "Freedom")
o:value("http", "HTTP/2")
o:value("mtproto", "MTProto")
o:value("shadowsocks", "Shadowsocks")
o:value("socks", "Socks")
o:value("vmess", "VMess")

-- Settings Blackhole
o = s:option(ListValue, "s_blackhole_reponse_type", "%s - %s" % { "Blackhole", translate("Response type") } )
o:depends("protocol", "blackhole")
o:value("")
o:value("none", translate("None"))
o:value("http", "HTTP")

-- Settings DNS
o = s:option(ListValue, "s_dns_network", "%s - %s" % { "DNS", translate("Network") } )
o:depends("protocol", "dns")
o:value("")
o:value("tcp", "TCP")
o:value("udp", "UDP")

o = s:option(Value, "s_dns_address", "%s - %s" % { "DNS", translate("Address") } )
o:depends("protocol", "dns")

o = s:option(Value, "s_dns_port", "%s - %s" % { "DNS", translate("Port") } )
o:depends("protocol", "dns")
o.datatype = "port"

-- Settings Freedom
o = s:option(ListValue, "s_freedom_domain_strategy", "%s - %s" % { "Freedom", translate("Domain strategy") } )
o:depends("protocol", "freedom")
o:value("")
o:value("AsIs")
o:value("UseIP")
o:value("UseIPv4")
o:value("UseIPv6")

o = s:option(Value, "s_freedom_redirect", "%s - %s" % { "Freedom", translate("Redirect") } )
o:depends("protocol", "freedom")

o = s:option(Value, "s_freedom_user_level", "%s - %s" % { "Freedom", translate("User level") } )
o:depends("protocol", "freedom")
o.datatype = "uinteger"

-- Settings - HTTP
o = s:option(Value, "s_http_server_address", "%s - %s" % { "HTTP", translate("Server address") } )
o:depends("protocol", "http")
o.datatype = "host"

o = s:option(Value, "s_http_server_port", "%s - %s" % { "HTTP", translate("Server port") } )
o:depends("protocol", "http")
o.datatype = "port"

o = s:option(Value, "s_http_account_user", "%s - %s" % { "HTTP", translate("User") } )
o:depends("protocol", "http")

o = s:option(Value, "s_http_account_pass", "%s - %s" % { "HTTP", translate("Password") } )
o:depends("protocol", "http")
o.password = true

-- Settings - Shadowsocks
o = s:option(Value, "s_shadowsocks_email", "%s - %s" % { "Shadowsocks", translate("Email") } )
o:depends("protocol", "shadowsocks")

o = s:option(Value, "s_shadowsocks_address", "%s - %s" % { "Shadowsocks", translate("Address") } )
o:depends("protocol", "shadowsocks")
o.datatype = "host"

o = s:option(Value, "s_shadowsocks_port", "%s - %s" % { "Shadowsocks", translate("Port") } )
o:depends("protocol", "shadowsocks")
o.datatype = "port"

o = s:option(ListValue, "s_shadowsocks_method", "%s - %s" % { "Shadowsocks", translate("Method") } )
o:depends("protocol", "shadowsocks")
o:value("")
o:value("aes-256-cfb")
o:value("aes-128-cfb")
o:value("chacha20")
o:value("chacha20-ietf")
o:value("aes-256-gcm")
o:value("aes-128-gcm")
o:value("chacha20-poly1305")
o:value("chacha20-ietf-poly1305")

o = s:option(Value, "s_shadowsocks_password", "%s - %s" % { "Shadowsocks", translate("Password") })
o:depends("protocol", "shadowsocks")
o.password = true

o = s:option(Value, "s_shadowsocks_level", "%s - %s" % { "Shadowsocks", translate("User level") })
o:depends("protocol", "shadowsocks")
o.datatype = "uinteger"

o = s:option(Flag, "s_shadowsocks_ota", "%s - %s" % { "Shadowsocks", translate("OTA") })
o:depends("protocol", "shadowsocks")

-- Settings - Socks
o = s:option(Value, "s_socks_server_address", "%s - %s" % { "Socks", translate("Server address") })
o:depends("protocol", "socks")
o.datatype = "host"

o = s:option(Value, "s_socks_server_port", "%s - %s" % { "Socks", translate("Server port") })
o:depends("protocol", "socks")
o.datatype = "port"

o = s:option(Value, "s_socks_account_user", "%s - %s" % { "Socks", translate("User") })
o:depends("protocol", "socks")

o = s:option(Value, "s_socks_account_pass", "%s - %s" % { "Socks", translate("Password") })
o:depends("protocol", "socks")
o.password = true

o = s:option(Value, "s_socks_user_level", "%s - %s" % { "Socks", translate("User level") })
o:depends("protocol", "socks")
o.datatype = "uinteger"

-- Settings - VMess
o = s:option(Value, "s_vmess_address", "%s - %s" % { "VMess", translate("Address") })
o:depends("protocol", "vmess")
o.datatype = "host"

o = s:option(Value, "s_vmess_port", "%s - %s" % { "VMess", translate("Port") })
o:depends("protocol", "vmess")
o.datatype = "port"

o = s:option(Value, "s_vmess_user_id", "%s - %s" % { "VMess", translate("User ID") })
o:depends("protocol", "vmess")

o = s:option(Value, "s_vmess_user_alter_id", "%s - %s" % { "VMess", translate("Alter ID") })
o:depends("protocol", "vmess")
o.datatype = "and('uinteger', max(65535))"

o = s:option(ListValue, "s_vmess_user_security", "%s - %s" % { "VMess", translate("Security") })
o:depends("protocol", "vmess")
o:value("")
o:value("auto", translate("Auto"))
o:value("aes-128-gcm")
o:value("chacha20-poly1305")
o:value("none", translate("None"))

o = s:option(Value, "s_vmess_user_level", "%s - %s" % { "VMess", translate("User level") })
o:depends("protocol", "vmess")
o.datatype = "uinteger"

-- Stream Settings
o = s:option(ListValue, "ss_network", "%s - %s" % { translate("Stream settings"), translate("Network") })
o:value("")
o:value("tcp", "TCP")
o:value("kcp", "mKCP")
o:value("ws", "WebSocket")
o:value("http", "HTTP/2")
o:value("domainsocket", "Domain Socket")
o:value("quic", "QUIC")

o = s:option(ListValue, "ss_security", "%s - %s" % { translate("Stream settings"), translate("Security") })
o:value("")
o:value("none", translate("None"))
o:value("tls", "TLS")

-- Stream Settings - TLS
o = s:option(Value, "ss_tls_server_name", "%s - %s" % { "TLS", translate("Server name") })
o:depends("ss_security", "tls")

o = s:option(Value, "ss_tls_alpn", "%s - %s" % { "TLS", "ALPN" })
o:depends("ss_security", "tls")
o.placeholder = "http/1.1"

o = s:option(Flag, "ss_tls_allow_insecure", "%s - %s" % { "TLS", translate("Allow insecure") })
o:depends("ss_security", "tls")

o = s:option(Flag, "ss_tls_allow_insecure_ciphers", "%s - %s" % { "TLS", translate("Allow insecure ciphers") })
o:depends("ss_security", "tls")

o = s:option(Flag, "ss_tls_disable_system_root", "%s - %s" % { "TLS", translate("Disable system root") })
o:depends("ss_security", "tls")

o = s:option(ListValue, "ss_tls_cert_usage", "%s - %s" % { "TLS", translate("Certificate usage") })
o:depends("ss_security", "tls")
o:value("")
o:value("encipherment")
o:value("verify")
o:value("issue")

o = s:option(Value, "ss_tls_cert_fiile", "%s - %s" % { "TLS", translate("Certificate file") })
o:depends("ss_security", "tls")

o = s:option(Value, "ss_tls_key_file", "%s - %s" % { "TLS", translate("Key file") })
o:depends("ss_security", "tls")

-- Stream Settings - TCP
o = s:option(ListValue, "ss_tcp_header_type", "%s - %s" % { "TCP", translate("Header type") })
o:depends("ss_network", "tcp")
o:value("")
o:value("none", translate("None"))
o:value("http", "HTTP")

o = s:option(Value, "ss_tcp_header_request_version", "%s - %s" % { "TCP", translate("HTTP request version") })
o:depends("ss_tcp_header_type", "http")

o = s:option(ListValue, "ss_tcp_header_request_method", "%s - %s" % { "TCP", translate("HTTP request method") })
o:depends("ss_tcp_header_type", "http")
o:value("")
o:value("GET")
o:value("HEAD")
o:value("POST")
o:value("DELETE")
o:value("PUT")
o:value("PATCH")
o:value("OPTIONS")

o = s:option(Value, "ss_tcp_header_request_path", "%s - %s" % { "TCP", translate("Request path") })
o:depends("ss_tcp_header_type", "http")

o = s:option(DynamicList, "ss_tcp_header_request_headers", "%s - %s" % { "TCP", translate("Request headers") },
	translatef("A list of HTTP headers, format: <code>header=value</code>. eg: %s", "Host=www.bing.com"))
o:depends("ss_tcp_header_type", "http")

o = s:option(Value, "ss_tcp_header_response_version", "%s - %s" % { "TCP", translate("HTTP response version") })
o:depends("ss_tcp_header_type", "http")

o = s:option(Value, "ss_tcp_header_response_status", "%s - %s" % { "TCP", translate("HTTP response status") })
o:depends("ss_tcp_header_type", "http")

o = s:option(Value, "ss_tcp_header_response_reason", "%s - %s" % { "TCP", translate("HTTP response reason") })
o:depends("ss_tcp_header_type", "http")

o = s:option(DynamicList, "ss_tcp_header_response_headers", "%s - %s" % { "TCP", translate("Response headers") },
	translatef("A list of HTTP headers, format: <code>header=value</code>. eg: %s", "Host=www.bing.com"))
o:depends("ss_tcp_header_type", "http")

-- Stream Settings - KCP
o = s:option(Value, "ss_kcp_mtu", "%s - %s" % { "mKCP", translate("Maximum transmission unit (MTU)") })
o:depends("ss_network", "kcp")
o.datatype = "and(min(576), max(1460))"
o.placeholder = "1350"

o = s:option(Value, "ss_kcp_tti", "%s - %s" % { "mKCP", translate("Transmission time interval (TTI)") })
o:depends("ss_network", "kcp")
o.datatype = "and(min(10), max(100))"
o.placeholder = "50"

o = s:option(Value, "ss_kcp_uplink_capacity", "%s - %s" % { "mKCP", translate("Uplink capacity") })
o:depends("ss_network", "kcp")
o.datatype = "uinteger"
o.placeholder = "5"

o = s:option(Value, "ss_kcp_downlink_capacity", "%s - %s" % { "mKCP", translate("Downlink capacity") })
o:depends("ss_network", "kcp")
o.datatype = "uinteger"
o.placeholder = "20"

o = s:option(Flag, "ss_kcp_congestion", "%s - %s" % { "mKCP", translate("Congestion enabled") })
o:depends("ss_network", "kcp")

o = s:option(Value, "ss_kcp_read_buffer_size", "%s - %s" % { "mKCP", translate("Read buffer size") })
o:depends("ss_network", "kcp")
o.datatype = "uinteger"
o.placeholder = "2"

o = s:option(Value, "ss_kcp_write_buffer_size", "%s - %s" % { "mKCP", translate("Write buffer size") })
o:depends("ss_network", "kcp")
o.datatype = "uinteger"
o.placeholder = "2"

o = s:option(ListValue, "ss_kcp_header_type", "%s - %s" % { "mKCP", translate("Header type") })
o:depends("ss_network", "kcp")
o:value("")
o:value("none", translate("None"))
o:value("srtp", "SRTP")
o:value("utp", "uTP")
o:value("wechat-video", translate("Wechat Video"))
o:value("dtls", "DTLS 1.2")
o:value("wireguard", "WireGuard")

-- Stream Settings - WebSocket
o = s:option(Value, "ss_websocket_path", "%s - %s" % { "WebSocket", translate("Path") })
o:depends("ss_network", "ws")

o = s:option(DynamicList, "ss_websocket_headers", "%s - %s" % { "WebSocket", translate("Headers") },
	translatef("A list of HTTP headers, format: <code>header=value</code>. eg: %s", "Host=www.bing.com"))
o:depends("ss_network", "ws")

-- Stream Settings - HTTP/2
o = s:option(DynamicList, "ss_http_host", "%s - %s" % { "HTTP/2", translate("Host") })
o:depends("ss_network", "http")

o = s:option(Value, "ss_http_path", "%s - %s" % { "HTTP/2", translate("Path") })
o:depends("ss_network", "http")
o.placeholder = "/"

-- Stream Settings - Domain Socket
o = s:option(Value, "ss_domainsocket_path", "%s - %s" % { "Domain Socket", translate("Path") })
o:depends("ss_network", "domainsocket")

-- Stream Settings - QUIC
o = s:option(ListValue, "ss_quic_security", "%s - %s" % { "QUIC", translate("Security") })
o:depends("ss_network", "quic")
o:value("")
o:value("none", translate("None"))
o:value("aes-128-gcm")
o:value("chacha20-poly1305")

o = s:option(Value, "ss_quic_key", "%s - %s" % { "QUIC", translate("Key") })
o:depends("ss_quic_security", "aes-128-gcm")
o:depends("ss_quic_security", "chacha20-poly1305")

o = s:option(ListValue, "ss_quic_header_type", "%s - %s" % { "QUIC", translate("Header type") })
o:depends("ss_network", "quic")
o:value("")
o:value("none", translate("None"))
o:value("srtp", "SRTP")
o:value("utp", "uTP")
o:value("wechat-video", translate("Wechat Video"))
o:value("dtls", "DTLS 1.2")
o:value("wireguard", "WireGuard")

-- Stream Settings - Socket Options
o = s:option(Value, "ss_sockopt_mark", "%s - %s" % { translate("Sockopt"), translate("Mark") },
	translate("If transparent proxy is enabled, this option is ignored and will be set to 255."))
o.placeholder = "255"

o = s:option(ListValue, "ss_sockopt_tcp_fast_open", "%s - %s" % { translate("Sockopt"), translate("TCP fast open") })
o:value("")
o:value("0", translate("False"))
o:value("1", translate("True"))

-- Other Settings
o = s:option(Value, "tag", translate("Tag"))

o = s:option(Value, "proxy_settings_tag", "%s - %s" % { translate("Proxy settings"), translate("Tag") })

o = s:option(Flag, "mux_enabled", "%s - %s" % { translate("Mux"), translate("Enabled") })

o = s:option(Value, "mux_concurrency", "%s - %s" % { translate("Mux"), translate("Concurrency") })
o.datatype = "uinteger"
o.placeholder = "8"

return m
