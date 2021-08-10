/**
 * @license
 * Copyright 2020 Xingwang Liao <kuoruan@gmail.com>
 *
 * Licensed to the public under the MIT License.
 */

"use strict";

"require form";
"require v2ray";
// "require view";

// @ts-ignore
return L.view.extend<SectionItem[]>({
  load: function () {
    return v2ray.getSections("dns_server");
  },
  render: function (dnsServers = []) {
    const m = new form.Map(
      "v2ray",
      "%s - %s".format(_("V2Ray"), _("DNS")),
      _("Details: %s").format(
        '<a href="https://www.v2ray.com/en/configuration/dns.html#dnsobject" target="_blank">DnsObject</a>'
      )
    );

    const s1 = m.section(form.NamedSection, "main_dns", "dns");
    s1.anonymous = true;
    s1.addremove = false;

    let o;

    o = s1.option(form.Flag, "enabled", _("Enabled"));
    o.rmempty = false;

    o = s1.option(form.Value, "tag", _("Tag"));

    o = s1.option(form.Flag, "disable_cache", _("Disable Cache"),
      _(
        "Disable cache for DNS query."
      )
    );

    o = s1.option(form.Flag, "disable_fallback", _("Disable Fallback"),
      _(
        "Disable the fallback query when none dns server matches normally."
      )
    );

    o = s1.option(
      form.Value,
      "client_ip",
      _("Client IP"),
      '<a href="https://icanhazip.com" target="_blank">%s</a>'.format(
        _("Get my public IP address")
      )
    );
    o.datatype = "ipaddr";

    o = s1.option(
      form.ListValue,
      "query_strategy",
      _("Query strategy")
    );
    o.value("");
    o.value("UseIP");
    o.value("UseIPv4");
    o.value("UseIPv6");

    o = s1.option(
      form.DynamicList,
      "hosts",
      _("Hosts"),
      _(
        "A list of static addresses, format: <code>domain|address</code>. eg: %s"
      ).format("google.com|127.0.0.1")
    );

    o = s1.option(
      form.MultiValue,
      "servers",
      _("DNS Servers"),
      _("Select DNS servers to use")
    );
    for (const d of dnsServers) {
      o.value(d.value, d.caption);
    }

    const s2 = m.section(
      form.GridSection,
      "dns_server",
      _("DNS server"),
      _("Add DNS servers here")
    );
    s2.anonymous = true;
    s2.addremove = true;
    s2.nodescription = true;
    s2.sortable = true;

    o = s2.option(form.Value, "alias", _("Alias"));
    o.rmempty = false;

    o = s2.option(form.Value, "address", _("Address"));

    o = s2.option(form.Value, "port", _("Port"));
    o.datatype = "port";
    o.placeholder = "53";

    o = s2.option(form.DynamicList, "domains", _("Domains"));
    o.modalonly = true;

    o = s2.option(form.DynamicList, "expect_ips", _("Expect IPs"));
    o.modalonly = true;

    return m.render();
  },
});
