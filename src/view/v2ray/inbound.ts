"use strict";

"require form";
"require network";
"require uci";
"require v2ray";
// "require view";

// @ts-ignore
return L.view.extend({
  load: function (): Promise<string[]> {
    return v2ray.getLocalIPs();
  },
  render: function (localIPs: string[] = []) {
    const m = new form.Map("v2ray", "%s - %s".format(_("V2Ray"), _("Inbound")));

    const s = m.section(form.GridSection, "inbound");
    s.anonymous = true;
    s.addremove = true;
    s.sortable = true;
    s.modaltitle = function (section_id: string) {
      const alias = uci.get("v2ray", section_id, "alias");
      return `${_("Inbound")} » ${alias ?? _("Add")}`;
    };

    s.tab("general", _("General Settings"));
    s.tab("stream", _("Stream Settings"));
    s.tab("other", _("Other Settings"));

    let o;

    /** General settings */
    o = s.taboption("general", form.Value, "alias", _("Alias"));
    o.rmempty = false;

    o = s.taboption("general", form.Value, "listen", _("Listen"));
    o.datatype = "ipaddr";
    for (const IP of localIPs) {
      o.value(IP);
    }

    o = s.taboption("general", form.Value, "port", _("Port"));
    o.rmempty = false;
    o.datatype = "or(port, portrange)";

    o = s.taboption("general", form.ListValue, "protocol", _("Protocol"));
    o.value("dokodemo-door", "Dokodemo-door");
    o.value("http", "HTTP");
    o.value("mtproto", "MTProto");
    o.value("shadowsocks", "Shadowsocks");
    o.value("socks", "Socks");
    o.value("vmess", "VMess");

    // Settings - Dokodemo-door
    o = s.taboption(
      "general",
      form.Value,
      "s_dokodemo_door_address",
      "%s - %s".format("Dokodemo-door", _("Address")),
      _("Address of the destination server.")
    );
    o.modalonly = true;
    o.depends("protocol", "dokodemo-door");
    o.datatype = "host";

    o = s.taboption(
      "general",
      form.Value,
      "s_dokodemo_door_port",
      "%s - %s".format("Dokodemo-door", _("Port")),
      _("Port of the destination server.")
    );
    o.modalonly = true;
    o.depends("protocol", "dokodemo-door");
    o.datatype = "port";

    o = s.taboption(
      "general",
      form.MultiValue,
      "s_dokodemo_door_network",
      "%s - %s".format("Dokodemo-door", _("Network")),
      _(
        "If transparent proxy enabled on current inbound, this option will be ignored."
      )
    );
    o.modalonly = true;
    o.depends("protocol", "dokodemo-door");
    o.value("tcp");
    o.value("udp");
    o.default = "tcp";

    o = s.taboption(
      "general",
      form.Value,
      "s_dokodemo_door_timeout",
      "%s - %s".format("Dokodemo-door", _("Timeout")),
      _("Time limit for inbound data(seconds)")
    );
    o.modalonly = true;
    o.depends("protocol", "dokodemo-door");
    o.datatype = "uinteger";
    o.placeholder = "300";

    o = s.taboption(
      "general",
      form.Flag,
      "s_dokodemo_door_follow_redirect",
      "%s - %s".format("Dokodemo-door", _("Follow redirect")),
      _(
        "If transparent proxy enabled on current inbound, this option will be ignored."
      )
    );
    o.modalonly = true;
    o.depends("protocol", "dokodemo-door");

    o = s.taboption(
      "general",
      form.Value,
      "s_dokodemo_door_user_level",
      "%s - %s".format("Dokodemo-door", _("User level")),
      _("All connections share this level")
    );
    o.modalonly = true;
    o.depends("protocol", "dokodemo-door");
    o.datatype = "uinteger";

    // Settings - HTTP
    o = s.taboption(
      "general",
      form.Value,
      "s_http_account_user",
      "%s - %s".format("HTTP", _("Account user"))
    );
    o.modalonly = true;
    o.depends("protocol", "http");

    o = s.taboption(
      "general",
      form.Value,
      "s_http_account_pass",
      "%s - %s".format("HTTP", _("Account password"))
    );
    o.modalonly = true;
    o.depends("protocol", "http");
    o.password = true;

    o = s.taboption(
      "general",
      form.Flag,
      "s_http_allow_transparent",
      "%s - %s".format("HTTP", _("Allow transparent"))
    );
    o.modalonly = true;
    o.depends("protocol", "http");

    o = s.taboption(
      "general",
      form.Value,
      "s_http_timeout",
      "%s - %s".format("HTTP", _("Timeout")),
      _("Time limit for inbound data(seconds)")
    );
    o.modalonly = true;
    o.depends("protocol", "http");
    o.datatype = "uinteger";
    o.placeholder = "300";

    o = s.taboption(
      "general",
      form.Value,
      "s_http_user_level",
      "%s - %s".format("HTTP", _("User level")),
      _("All connections share this level")
    );
    o.modalonly = true;
    o.depends("protocol", "http");
    o.datatype = "uinteger";

    // Settings - MTProto
    o = s.taboption(
      "general",
      form.Value,
      "s_mtproto_user_email",
      "%s - %s".format("MTProto", _("User email"))
    );
    o.modalonly = true;
    o.depends("protocol", "mtproto");

    o = s.taboption(
      "general",
      form.Value,
      "s_mtproto_user_secret",
      "%s - %s".format("MTProto", _("User secret"))
    );
    o.modalonly = true;
    o.depends("protocol", "mtproto");
    o.password = true;

    o = s.taboption(
      "general",
      form.Value,
      "s_mtproto_user_level",
      "%s - %s".format("MTProto", _("User level")),
      _("All connections share this level")
    );
    o.modalonly = true;
    o.depends("protocol", "mtproto");
    o.datatype = "uinteger";

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
      "%s - %s".format("Shadowsocks", _("One Time Auth (OTA)"))
    );
    o.modalonly = true;
    o.depends("protocol", "shadowsocks");

    o = s.taboption(
      "general",
      form.MultiValue,
      "s_shadowsocks_network",
      "%s - %s".format("Shadowsocks", _("Network"))
    );
    o.modalonly = true;
    o.depends("protocol", "shadowsocks");
    o.value("tcp");
    o.value("udp");
    o.default = "tcp";

    // Settings - Socks;
    o = s.taboption(
      "general",
      form.ListValue,
      "s_socks_auth",
      "%s - %s".format("Socks", _("Auth"))
    );
    o.modalonly = true;
    o.depends("protocol", "socks");
    o.value("");
    o.value("noauth", _("No Auth"));
    o.value("password", _("Password"));
    o.default = "noauth";

    o = s.taboption(
      "general",
      form.Value,
      "s_socks_account_user",
      "%s - %s".format("Socks", _("Account user"))
    );
    o.modalonly = true;
    o.depends("s_socks_auth", "password");

    o = s.taboption(
      "general",
      form.Value,
      "s_socks_account_pass",
      "%s - %s".format("Socks", _("Account password"))
    );
    o.modalonly = true;
    o.depends("s_socks_auth", "password");
    o.password = true;

    o = s.taboption(
      "general",
      form.Flag,
      "s_socks_udp",
      "%s - %s".format("Socks", _("UDP"))
    );
    o.modalonly = true;
    o.depends("protocol", "socks");

    o = s.taboption(
      "general",
      form.Value,
      "s_socks_ip",
      "%s - %s".format("Socks", _("IP")),
      _(
        "When UDP is enabled, V2Ray needs to know the IP address of current host."
      )
    );
    o.modalonly = true;
    o.depends("s_socks_udp", "1");
    for (const IP of localIPs) {
      o.value(IP);
    }
    o.datatype = "host";
    o.placeholder = "127.0.0.1";

    o = s.taboption(
      "general",
      form.Value,
      "s_socks_user_level",
      "%s - %s".format("Socks", _("User level")),
      _("All connections share this level")
    );
    o.modalonly = true;
    o.depends("protocol", "socks");
    o.datatype = "uinteger";

    // Settings - VMess
    o = s.taboption(
      "general",
      form.Value,
      "s_vmess_client_id",
      "%s - %s".format("VMess", _("Client ID"))
    );
    o.modalonly = true;
    o.depends("protocol", "vmess");

    o = s.taboption(
      "general",
      form.Value,
      "s_vmess_client_alter_id",
      "%s - %s".format("VMess", _("Client alter ID"))
    );
    o.modalonly = true;
    o.depends("protocol", "vmess");
    o.datatype = "and(min(0), max(65535))";

    o = s.taboption(
      "general",
      form.Value,
      "s_vmess_client_email",
      "%s - %s".format("VMess", _("Client email"))
    );
    o.modalonly = true;
    o.depends("protocol", "vmess");

    o = s.taboption(
      "general",
      form.Value,
      "s_vmess_client_user_level",
      "%s - %s".format("VMess", _("Client User level"))
    );
    o.modalonly = true;
    o.depends("protocol", "vmess");
    o.datatype = "uinteger";

    o = s.taboption(
      "general",
      form.Value,
      "s_vmess_default_alter_id",
      "%s - %s".format("VMess", _("Default alter ID"))
    );
    o.modalonly = true;
    o.depends("protocol", "vmess");
    o.datatype = "and(min(0), max(65535))";

    o = s.taboption(
      "general",
      form.Value,
      "s_vmess_default_user_level",
      "%s - %s".format("VMess", _("Default user level"))
    );
    o.modalonly = true;
    o.depends("protocol", "vmess");
    o.datatype = "uinteger";

    o = s.taboption(
      "general",
      form.Value,
      "s_vmess_detour_to",
      "%s - %s".format("VMess", _("Detour to")),
      _(
        "Optional feature to suggest client to take a detour. If specified, this inbound will instruct the outbound to use another inbound."
      )
    );
    o.modalonly = true;
    o.depends("protocol", "vmess");

    o = s.taboption(
      "general",
      form.Flag,
      "s_vmess_disable_insecure_encryption",
      "%s - %s".format("VMess", _("Disable insecure encryption"))
    );
    o.modalonly = true;
    o.depends("protocol", "vmess");

    /** Stream Settings  **/
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
    o.datatype = "host";

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
    o.placeholder = "1.1";

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
    o.default = "GET";

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
    o.placeholder = "1.1";

    o = s.taboption(
      "stream",
      form.Value,
      "ss_tcp_header_response_status",
      "%s - %s".format("TCP", _("HTTP response status"))
    );
    o.modalonly = true;
    o.depends("ss_tcp_header_type", "http");
    o.placeholder = "200";

    o = s.taboption(
      "stream",
      form.Value,
      "ss_tcp_header_response_reason",
      "%s - %s".format("TCP", _("HTTP response reason"))
    );
    o.modalonly = true;
    o.depends("ss_tcp_header_type", "http");
    o.placeholder = "OK";

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
      form.ListValue,
      "ss_sockopt_tcp_fast_open",
      "%s - %s".format(_("Sockopt"), _("TCP fast open"))
    );
    o.modalonly = true;
    o.value("");
    o.value("0", _("False"));
    o.value("1", _("True"));

    o = s.taboption(
      "stream",
      form.ListValue,
      "ss_sockopt_tproxy",
      "%s - %s".format(_("Sockopt"), _("TProxy")),
      _(
        "If transparent proxy enabled on current inbound, this option will be ignored."
      )
    );
    o.modalonly = true;
    o.value("");
    o.value("redirect", "Redirect");
    o.value("tproxy", "TProxy");
    o.value("off", _("Off"));

    /** Other Settings **/
    o = s.taboption("other", form.Value, "tag", _("Tag"));

    o = s.taboption(
      "other",
      form.Flag,
      "sniffing_enabled",
      "%s - %s".format(_("Sniffing"), _("Enabled"))
    );
    o.modalonly = true;

    o = s.taboption(
      "other",
      form.MultiValue,
      "sniffing_dest_override",
      "%s - %s".format(_("Sniffing"), _("Dest override"))
    );
    o.modalonly = true;
    o.value("http");
    o.value("tls");

    o = s.taboption(
      "other",
      form.ListValue,
      "allocate_strategy",
      "%s - %s".format(_("Allocate"), _("Strategy"))
    );
    o.modalonly = true;
    o.value("");
    o.value("always");
    o.value("random");

    o = s.taboption(
      "other",
      form.Value,
      "allocate_refresh",
      "%s - %s".format(_("Allocate"), _("Refresh"))
    );
    o.modalonly = true;
    o.datatype = "uinteger";

    o = s.taboption(
      "other",
      form.Value,
      "allocate_concurrency",
      "%s - %s".format(_("Allocate"), _("Concurrency"))
    );
    o.modalonly = true;
    o.datatype = "uinteger";

    return m.render();
  },
});
