"use strict";

"require form";
"require uci";
"require v2ray";
// "require view";

// @ts-ignore
return L.view.extend<string[]>({
  load: function () {
    return v2ray.getLocalIPs();
  },
  render: function (localIPs: string[] = []) {
    const m = new form.Map(
      "v2ray",
      "%s - %s".format(_("V2Ray"), _("Outbound"))
    );

    const s = m.section(form.GridSection, "outbound");
    s.anonymous = true;
    s.addremove = true;
    s.sortable = true;
    s.modaltitle = function (section_id: string) {
      const alias = uci.get("v2ray", section_id, "alias");
      return `${_("Outbound")} » ${alias ?? _("Add")}`;
    };
    s.nodescriptions = true;

    s.tab("general", _("General Settings"));
    s.tab("stream", _("Stream Settings"));
    s.tab("other", _("Other Settings"));

    let o;

    /** General Settings **/
    o = s.taboption("general", form.Value, "alias", _("Alias"));
    o.rmempty = false;

    o = s.taboption("general", form.Value, "send_through", _("Send through"));
    o.datatype = "ipaddr";
    for (const IP of localIPs) {
      o.value(IP);
    }

    o = s.taboption("general", form.ListValue, "protocol", _("Protocol"));
    o.value("blackhole", "Blackhole");
    o.value("dns", "DNS");
    o.value("freedom", "Freedom");
    o.value("http", "HTTP/2");
    o.value("mtproto", "MTProto");
    o.value("shadowsocks", "Shadowsocks");
    o.value("socks", "Socks");
    o.value("vmess", "VMess");

    // Settings Blackhole
    o = s.taboption(
      "general",
      form.ListValue,
      "s_blackhole_reponse_type",
      "%s - %s".format("Blackhole", _("Response type"))
    );
    o.modalonly = true;
    o.depends("protocol", "blackhole");
    o.value("");
    o.value("none", _("None"));
    o.value("http", "HTTP");

    // Settings DNS
    o = s.taboption(
      "general",
      form.ListValue,
      "s_dns_network",
      "%s - %s".format("DNS", _("Network"))
    );
    o.modalonly = true;
    o.depends("protocol", "dns");
    o.value("");
    o.value("tcp", "TCP");
    o.value("udp", "UDP");

    o = s.taboption(
      "general",
      form.Value,
      "s_dns_address",
      "%s - %s".format("DNS", _("Address"))
    );
    o.modalonly = true;
    o.depends("protocol", "dns");

    o = s.taboption(
      "general",
      form.Value,
      "s_dns_port",
      "%s - %s".format("DNS", _("Port"))
    );
    o.modalonly = true;
    o.depends("protocol", "dns");
    o.datatype = "port";

    // Settings Freedom
    o = s.taboption(
      "general",
      form.ListValue,
      "s_freedom_domain_strategy",
      "%s - %s".format("Freedom", _("Domain strategy"))
    );
    o.modalonly = true;
    o.depends("protocol", "freedom");
    o.value("");
    o.value("AsIs");
    o.value("UseIP");
    o.value("UseIPv4");
    o.value("UseIPv6");

    o = s.taboption(
      "general",
      form.Value,
      "s_freedom_redirect",
      "%s - %s".format("Freedom", _("Redirect"))
    );
    o.modalonly = true;
    o.depends("protocol", "freedom");

    o = s.taboption(
      "general",
      form.Value,
      "s_freedom_user_level",
      "%s - %s".format("Freedom", _("User level"))
    );
    o.modalonly = true;
    o.depends("protocol", "freedom");
    o.datatype = "uinteger";

    // Settings - HTTP
    o = s.taboption(
      "general",
      form.Value,
      "s_http_server_address",
      "%s - %s".format("HTTP", _("Server address"))
    );
    o.modalonly = true;
    o.depends("protocol", "http");
    o.datatype = "host";

    o = s.taboption(
      "general",
      form.Value,
      "s_http_server_port",
      "%s - %s".format("HTTP", _("Server port"))
    );
    o.modalonly = true;
    o.depends("protocol", "http");
    o.datatype = "port";

    o = s.taboption(
      "general",
      form.Value,
      "s_http_account_user",
      "%s - %s".format("HTTP", _("User"))
    );
    o.modalonly = true;
    o.depends("protocol", "http");

    o = s.taboption(
      "general",
      form.Value,
      "s_http_account_pass",
      "%s - %s".format("HTTP", _("Password"))
    );
    o.modalonly = true;
    o.depends("protocol", "http");
    o.password = true;

    // Settings - Shadowsocks
    o = s.taboption(
      "general",
      form.Value,
      "s_shadowsocks_email",
      "%s - %s".format("Shadowsocks", _("Email"))
    );
    o.modalonly = true;
    o.depends("protocol", "shadowsocks");

    o = s.taboption(
      "general",
      form.Value,
      "s_shadowsocks_address",
      "%s - %s".format("Shadowsocks", _("Address"))
    );
    o.modalonly = true;
    o.depends("protocol", "shadowsocks");
    o.datatype = "host";

    o = s.taboption(
      "general",
      form.Value,
      "s_shadowsocks_port",
      "%s - %s".format("Shadowsocks", _("Port"))
    );
    o.modalonly = true;
    o.depends("protocol", "shadowsocks");
    o.datatype = "port";

    o = s.taboption(
      "general",
      form.ListValue,
      "s_shadowsocks_method",
      "%s - %s".format("Shadowsocks", _("Method"))
    );
    o.modalonly = true;
    o.depends("protocol", "shadowsocks");
    o.value("");
    o.value("aes-256-cfb");
    o.value("aes-128-cfb");
    o.value("chacha20");
    o.value("chacha20-ietf");
    o.value("aes-256-gcm");
    o.value("aes-128-gcm");
    o.value("chacha20-poly1305");
    o.value("chacha20-ietf-poly1305");

    o = s.taboption(
      "general",
      form.Value,
      "s_shadowsocks_password",
      "%s - %s".format("Shadowsocks", _("Password"))
    );
    o.modalonly = true;
    o.depends("protocol", "shadowsocks");
    o.password = true;

    o = s.taboption(
      "general",
      form.Value,
      "s_shadowsocks_level",
      "%s - %s".format("Shadowsocks", _("User level"))
    );
    o.modalonly = true;
    o.depends("protocol", "shadowsocks");
    o.datatype = "uinteger";

    o = s.taboption(
      "general",
      form.Flag,
      "s_shadowsocks_ota",
      "%s - %s".format("Shadowsocks", _("OTA"))
    );
    o.modalonly = true;
    o.depends("protocol", "shadowsocks");

    // Settings - Socks
    o = s.taboption(
      "general",
      form.Value,
      "s_socks_server_address",
      "%s - %s".format("Socks", _("Server address"))
    );
    o.modalonly = true;
    o.depends("protocol", "socks");
    o.datatype = "host";

    o = s.taboption(
      "general",
      form.Value,
      "s_socks_server_port",
      "%s - %s".format("Socks", _("Server port"))
    );
    o.modalonly = true;
    o.depends("protocol", "socks");
    o.datatype = "port";

    o = s.taboption(
      "general",
      form.Value,
      "s_socks_account_user",
      "%s - %s".format("Socks", _("User"))
    );
    o.modalonly = true;
    o.depends("protocol", "socks");

    o = s.taboption(
      "general",
      form.Value,
      "s_socks_account_pass",
      "%s - %s".format("Socks", _("Password"))
    );
    o.modalonly = true;
    o.depends("protocol", "socks");
    o.password = true;

    o = s.taboption(
      "general",
      form.Value,
      "s_socks_user_level",
      "%s - %s".format("Socks", _("User level"))
    );
    o.modalonly = true;
    o.depends("protocol", "socks");
    o.datatype = "uinteger";

    // Settings - VMess
    o = s.taboption(
      "general",
      form.Value,
      "s_vmess_address",
      "%s - %s".format("VMess", _("Address"))
    );
    o.modalonly = true;
    o.depends("protocol", "vmess");
    o.datatype = "host";

    o = s.taboption(
      "general",
      form.Value,
      "s_vmess_port",
      "%s - %s".format("VMess", _("Port"))
    );
    o.modalonly = true;
    o.depends("protocol", "vmess");
    o.datatype = "port";

    o = s.taboption(
      "general",
      form.Value,
      "s_vmess_user_id",
      "%s - %s".format("VMess", _("User ID"))
    );
    o.modalonly = true;
    o.depends("protocol", "vmess");

    o = s.taboption(
      "general",
      form.Value,
      "s_vmess_user_alter_id",
      "%s - %s".format("VMess", _("Alter ID"))
    );
    o.modalonly = true;
    o.depends("protocol", "vmess");
    o.datatype = "and(uinteger, max(65535))";

    o = s.taboption(
      "general",
      form.ListValue,
      "s_vmess_user_security",
      "%s - %s".format("VMess", _("Security"))
    );
    o.modalonly = true;
    o.depends("protocol", "vmess");
    o.value("");
    o.value("auto", _("Auto"));
    o.value("aes-128-gcm");
    o.value("chacha20-poly1305");
    o.value("none", _("None"));

    o = s.taboption(
      "general",
      form.Value,
      "s_vmess_user_level",
      "%s - %s".format("VMess", _("User level"))
    );
    o.modalonly = true;
    o.depends("protocol", "vmess");
    o.datatype = "uinteger";

    /** Stream Settings **/
    o = s.taboption("stream", form.ListValue, "ss_network", _("Network"));
    o.value("");
    o.value("tcp", "TCP");
    o.value("kcp", "mKCP");
    o.value("ws", "WebSocket");
    o.value("http", "HTTP/2");
    o.value("domainsocket", "Domain Socket");
    o.value("quic", "QUIC");

    o = s.taboption("stream", form.ListValue, "ss_security", _("Security"));
    o.modalonly = true;
    o.value("");
    o.value("none", _("None"));
    o.value("tls", "TLS");

    // Stream Settings - TLS
    o = s.taboption(
      "stream",
      form.Value,
      "ss_tls_server_name",
      "%s - %s".format("TLS", _("Server name"))
    );
    o.modalonly = true;
    o.depends("ss_security", "tls");

    o = s.taboption(
      "stream",
      form.Value,
      "ss_tls_alpn",
      "%s - %s".format("TLS", "ALPN")
    );
    o.modalonly = true;
    o.depends("ss_security", "tls");
    o.placeholder = "http/1.1";

    o = s.taboption(
      "stream",
      form.Flag,
      "ss_tls_allow_insecure",
      "%s - %s".format("TLS", _("Allow insecure"))
    );
    o.modalonly = true;
    o.depends("ss_security", "tls");

    o = s.taboption(
      "stream",
      form.Flag,
      "ss_tls_allow_insecure_ciphers",
      "%s - %s".format("TLS", _("Allow insecure ciphers"))
    );
    o.modalonly = true;
    o.depends("ss_security", "tls");

    o = s.taboption(
      "stream",
      form.Flag,
      "ss_tls_disable_system_root",
      "%s - %s".format("TLS", _("Disable system root"))
    );
    o.modalonly = true;
    o.depends("ss_security", "tls");

    o = s.taboption(
      "stream",
      form.ListValue,
      "ss_tls_cert_usage",
      "%s - %s".format("TLS", _("Certificate usage"))
    );
    o.modalonly = true;
    o.depends("ss_security", "tls");
    o.value("");
    o.value("encipherment");
    o.value("verify");
    o.value("issue");

    o = s.taboption(
      "stream",
      form.Value,
      "ss_tls_cert_fiile",
      "%s - %s".format("TLS", _("Certificate file"))
    );
    o.modalonly = true;
    o.depends("ss_security", "tls");

    o = s.taboption(
      "stream",
      form.Value,
      "ss_tls_key_file",
      "%s - %s".format("TLS", _("Key file"))
    );
    o.modalonly = true;
    o.depends("ss_security", "tls");

    // Stream Settings - TCP
    o = s.taboption(
      "stream",
      form.ListValue,
      "ss_tcp_header_type",
      "%s - %s".format("TCP", _("Header type"))
    );
    o.modalonly = true;
    o.depends("ss_network", "tcp");
    o.value("");
    o.value("none", _("None"));
    o.value("http", "HTTP");

    o = s.taboption(
      "stream",
      form.Value,
      "ss_tcp_header_request_version",
      "%s - %s".format("TCP", _("HTTP request version"))
    );
    o.modalonly = true;
    o.depends("ss_tcp_header_type", "http");

    o = s.taboption(
      "stream",
      form.ListValue,
      "ss_tcp_header_request_method",
      "%s - %s".format("TCP", _("HTTP request method"))
    );
    o.modalonly = true;
    o.depends("ss_tcp_header_type", "http");
    o.value("");
    o.value("GET");
    o.value("HEAD");
    o.value("POST");
    o.value("DELETE");
    o.value("PUT");
    o.value("PATCH");
    o.value("OPTIONS");

    o = s.taboption(
      "stream",
      form.Value,
      "ss_tcp_header_request_path",
      "%s - %s".format("TCP", _("Request path"))
    );
    o.modalonly = true;
    o.depends("ss_tcp_header_type", "http");

    o = s.taboption(
      "stream",
      form.DynamicList,
      "ss_tcp_header_request_headers",
      "%s - %s".format("TCP", _("Request headers")),
      _(
        "A list of HTTP headers, format: <code>header=value</code>. eg: %s"
      ).format("Host=www.bing.com")
    );
    o.modalonly = true;
    o.depends("ss_tcp_header_type", "http");

    o = s.taboption(
      "stream",
      form.Value,
      "ss_tcp_header_response_version",
      "%s - %s".format("TCP", _("HTTP response version"))
    );
    o.modalonly = true;
    o.depends("ss_tcp_header_type", "http");

    o = s.taboption(
      "stream",
      form.Value,
      "ss_tcp_header_response_status",
      "%s - %s".format("TCP", _("HTTP response status"))
    );
    o.modalonly = true;
    o.depends("ss_tcp_header_type", "http");

    o = s.taboption(
      "stream",
      form.Value,
      "ss_tcp_header_response_reason",
      "%s - %s".format("TCP", _("HTTP response reason"))
    );
    o.modalonly = true;
    o.depends("ss_tcp_header_type", "http");

    o = s.taboption(
      "stream",
      form.DynamicList,
      "ss_tcp_header_response_headers",
      "%s - %s".format("TCP", _("Response headers")),
      _(
        "A list of HTTP headers, format: <code>header=value</code>. eg: %s"
      ).format("Host=www.bing.com")
    );
    o.modalonly = true;
    o.depends("ss_tcp_header_type", "http");

    // Stream Settings - KCP
    o = s.taboption(
      "stream",
      form.Value,
      "ss_kcp_mtu",
      "%s - %s".format("mKCP", _("Maximum transmission unit (MTU)"))
    );
    o.modalonly = true;
    o.depends("ss_network", "kcp");
    o.datatype = "and(min(576), max(1460))";
    o.placeholder = "1350";

    o = s.taboption(
      "stream",
      form.Value,
      "ss_kcp_tti",
      "%s - %s".format("mKCP", _("Transmission time interval (TTI)"))
    );
    o.modalonly = true;
    o.depends("ss_network", "kcp");
    o.datatype = "and(min(10), max(100))";
    o.placeholder = "50";

    o = s.taboption(
      "stream",
      form.Value,
      "ss_kcp_uplink_capacity",
      "%s - %s".format("mKCP", _("Uplink capacity"))
    );
    o.modalonly = true;
    o.depends("ss_network", "kcp");
    o.datatype = "uinteger";
    o.placeholder = "5";

    o = s.taboption(
      "stream",
      form.Value,
      "ss_kcp_downlink_capacity",
      "%s - %s".format("mKCP", _("Downlink capacity"))
    );
    o.modalonly = true;
    o.depends("ss_network", "kcp");
    o.datatype = "uinteger";
    o.placeholder = "20";

    o = s.taboption(
      "stream",
      form.Flag,
      "ss_kcp_congestion",
      "%s - %s".format("mKCP", _("Congestion enabled"))
    );
    o.modalonly = true;
    o.depends("ss_network", "kcp");

    o = s.taboption(
      "stream",
      form.Value,
      "ss_kcp_read_buffer_size",
      "%s - %s".format("mKCP", _("Read buffer size"))
    );
    o.modalonly = true;
    o.depends("ss_network", "kcp");
    o.datatype = "uinteger";
    o.placeholder = "2";

    o = s.taboption(
      "stream",
      form.Value,
      "ss_kcp_write_buffer_size",
      "%s - %s".format("mKCP", _("Write buffer size"))
    );
    o.modalonly = true;
    o.depends("ss_network", "kcp");
    o.datatype = "uinteger";
    o.placeholder = "2";

    o = s.taboption(
      "stream",
      form.ListValue,
      "ss_kcp_header_type",
      "%s - %s".format("mKCP", _("Header type"))
    );
    o.modalonly = true;
    o.depends("ss_network", "kcp");
    o.value("");
    o.value("none", _("None"));
    o.value("srtp", "SRTP");
    o.value("utp", "uTP");
    o.value("wechat-video", _("Wechat Video"));
    o.value("dtls", "DTLS 1.2");
    o.value("wireguard", "WireGuard");

    // Stream Settings - WebSocket
    o = s.taboption(
      "stream",
      form.Value,
      "ss_websocket_path",
      "%s - %s".format("WebSocket", _("Path"))
    );
    o.modalonly = true;
    o.depends("ss_network", "ws");

    o = s.taboption(
      "stream",
      form.DynamicList,
      "ss_websocket_headers",
      "%s - %s".format("WebSocket", _("Headers")),
      _(
        "A list of HTTP headers, format: <code>header=value</code>. eg: %s"
      ).format("Host=www.bing.com")
    );
    o.modalonly = true;
    o.depends("ss_network", "ws");

    // Stream Settings - HTTP/2
    o = s.taboption(
      "stream",
      form.DynamicList,
      "ss_http_host",
      "%s - %s".format("HTTP/2", _("Host"))
    );
    o.modalonly = true;
    o.depends("ss_network", "http");

    o = s.taboption(
      "stream",
      form.Value,
      "ss_http_path",
      "%s - %s".format("HTTP/2", _("Path"))
    );
    o.modalonly = true;
    o.depends("ss_network", "http");
    o.placeholder = "/";

    // Stream Settings - Domain Socket
    o = s.taboption(
      "stream",
      form.Value,
      "ss_domainsocket_path",
      "%s - %s".format("Domain Socket", _("Path"))
    );
    o.modalonly = true;
    o.depends("ss_network", "domainsocket");

    // Stream Settings - QUIC
    o = s.taboption(
      "stream",
      form.ListValue,
      "ss_quic_security",
      "%s - %s".format("QUIC", _("Security"))
    );
    o.modalonly = true;
    o.depends("ss_network", "quic");
    o.value("");
    o.value("none", _("None"));
    o.value("aes-128-gcm");
    o.value("chacha20-poly1305");

    o = s.taboption(
      "stream",
      form.Value,
      "ss_quic_key",
      "%s - %s".format("QUIC", _("Key"))
    );
    o.modalonly = true;
    o.depends("ss_quic_security", "aes-128-gcm");
    o.depends("ss_quic_security", "chacha20-poly1305");

    o = s.taboption(
      "stream",
      form.ListValue,
      "ss_quic_header_type",
      "%s - %s".format("QUIC", _("Header type"))
    );
    o.modalonly = true;
    o.depends("ss_network", "quic");
    o.value("");
    o.value("none", _("None"));
    o.value("srtp", "SRTP");
    o.value("utp", "uTP");
    o.value("wechat-video", _("Wechat Video"));
    o.value("dtls", "DTLS 1.2");
    o.value("wireguard", "WireGuard");

    // Stream Settings - Socket Options
    o = s.taboption(
      "stream",
      form.Value,
      "ss_sockopt_mark",
      "%s - %s".format(_("Sockopt"), _("Mark")),
      _(
        "If transparent proxy is enabled, this option is ignored and will be set to 255."
      )
    );
    o.modalonly = true;
    o.placeholder = "255";

    o = s.taboption(
      "stream",
      form.ListValue,
      "ss_sockopt_tcp_fast_open",
      "%s - %s".format(_("Sockopt"), _("TCP fast open"))
    );
    o.modalonly = true;
    o.value("");
    o.value("0", _("False"));
    o.value("1", _("True"));

    /** Other Settings **/
    o = s.taboption("general", form.Value, "tag", _("Tag"));

    o = s.taboption(
      "general",
      form.Value,
      "proxy_settings_tag",
      "%s - %s".format(_("Proxy settings"), _("Tag"))
    );
    o.modalonly = true;
    o = s.taboption(
      "other",
      form.Flag,
      "mux_enabled",
      "%s - %s".format(_("Mux"), _("Enabled"))
    );
    o.modalonly = true;

    o = s.taboption(
      "other",
      form.Value,
      "mux_concurrency",
      "%s - %s".format(_("Mux"), _("Concurrency"))
    );
    o.modalonly = true;
    o.datatype = "uinteger";
    o.placeholder = "8";

    return m.render();
  },
});
