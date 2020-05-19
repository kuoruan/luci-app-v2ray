"use strict";

"require form";
"require v2ray";
// "require view";

"require view/v2ray/include/custom as custom";

// @ts-ignore
return L.view.extend<[boolean, SectionItem[]]>({
  load: function () {
    return Promise.all([v2ray.getLanInterfaces()]);
  },
  render: function ([lanIfaces = []] = []) {
    const m = new form.Map(
      "v2ray",
      "%s - %s".format(_("V2Ray"), _("Transparent Proxy"))
    );

    const s = m.section(
      form.NamedSection,
      "main_transparent_proxy",
      "transparent_proxy"
    );

    let o;

    o = s.option(
      form.Value,
      "redirect_port",
      _("Redirect port"),
      _("Enable transparent proxy on Dokodemo-door port.")
    );
    o.value("", _("None"));
    o.datatype = "port";

    o = s.option(
      form.MultiValue,
      "lan_ifaces",
      _("LAN interfaces"),
      _("Enable proxy on selected interfaces.")
    );
    for (const i of lanIfaces) {
      o.value(i.value, i.caption);
    }

    o = s.option(
      form.Flag,
      "use_tproxy",
      _("Use TProxy"),
      _("Setup redirect rules with TProxy.")
    );

    o = s.option(
      form.Flag,
      "only_privileged_ports",
      _("Only privileged ports"),
      _("Only redirect traffic on ports below 1024.")
    );

    o = s.option(
      form.Flag,
      "redirect_udp",
      _("Redirect UDP"),
      _("Redirect UDP traffic to V2Ray.")
    );

    o = s.option(
      form.Flag,
      "redirect_dns",
      _("Redirect DNS"),
      _("Redirect DNS traffic to V2Ray.")
    );
    o.depends("redirect_udp", "");
    o.depends("redirect_udp", "0");

    o = s.option(
      form.ListValue,
      "proxy_mode",
      _("Proxy mode"),
      _(
        "If enabled, iptables rules will be added to pre-filter traffic and then sent to V2Ray."
      )
    );
    o.value("default", _("Default"));
    o.value("cn_direct", _("CN Direct"));
    o.value("cn_proxy", _("CN Proxy"));
    o.value("gfwlist_proxy", _("GFWList Proxy"));

    o = s.option(
      form.ListValue,
      "apnic_delegated_mirror",
      _("APNIC delegated mirror")
    );
    o.value("apnic", "APNIC");
    o.value("arin", "ARIN");
    o.value("ripe", "RIPE");
    o.value("iana", "IANA");

    o = s.option(custom.ListStatusValue, "_chnroutelist", _("CHNRoute"));
    o.listtype = "chnroute";
    o.btntitle = _("Update");

    o = s.option(form.ListValue, "gfwlist_mirror", _("GFWList mirror"));
    o.value("github", "GitHub");
    o.value("gitlab", "GitLab");
    o.value("bitbucket", "Bitbucket");
    o.value("pagure", "Pagure");

    o = s.option(custom.ListStatusValue, "_gfwlist", _("GFWList"));
    o.listtype = "gfwlist";
    o.btntitle = _("Update");

    o = s.option(
      custom.TextValue,
      "_proxy_list",
      _("Extra proxy list"),
      _(
        "One address per line. Allow types: DOMAIN, IP, CIDR. eg: %s, %s, %s"
      ).format("www.google.com", "1.1.1.1", "192.168.0.0/16")
    );
    o.wrap = "off";
    o.rows = 5;
    o.datatype = "string";
    o.filepath = "/etc/v2ray/proxylist.txt";

    o = s.option(
      custom.TextValue,
      "_direct_list",
      _("Extra direct list"),
      _(
        "One address per line. Allow types: DOMAIN, IP, CIDR. eg: %s, %s, %s"
      ).format("www.google.com", "1.1.1.1", "192.168.0.0/16")
    );
    o.wrap = "off";
    o.rows = 5;
    o.datatype = "string";
    o.filepath = "/etc/v2ray/directlist.txt";

    o = s.option(
      form.Value,
      "proxy_list_dns",
      _("Proxy list DNS"),
      _(
        "DNS used for domains in proxy list, format: <code>ip#port</code>. eg: %s"
      ).format("1.1.1.1#53")
    );

    o = s.option(
      form.Value,
      "direct_list_dns",
      _("Direct list DNS"),
      _(
        "DNS used for domains in direct list, format: <code>ip#port</code>. eg: %s"
      ).format("114.114.114.114#53")
    );

    o = s.option(
      custom.TextValue,
      "_src_direct_list",
      _("Local devices direct outbound list"),
      _("One address per line. Allow types: IP, CIDR. eg: %s, %s").format(
        "192.168.0.19",
        "192.168.0.0/16"
      )
    );
    o.wrap = "off";
    o.rows = 3;
    o.datatype = "string";
    o.filepath = "/etc/v2ray/srcdirectlist.txt";

    return m.render();
  },
});
