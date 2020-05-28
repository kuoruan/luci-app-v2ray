/**
 * @license
 * Copyright 2020 Xingwang Liao <kuoruan@gmail.com>
 *
 * Licensed to the public under the MIT License.
 */

"use strict";

"require form";
"require uci";
"require v2ray";
// "require view";

// @ts-ignore
return L.view.extend<SectionItem[][]>({
  load: function () {
    return Promise.all([
      v2ray.getSections("routing_rule"),
      v2ray.getSections("routing_balancer", "tag"),
    ]);
  },
  render: function ([routingRules = [], routingBalancers = []] = []) {
    const m = new form.Map(
      "v2ray",
      "%s - %s".format(_("V2Ray"), _("Routing")),
      _("Details: %s").format(
        '<a href="https://www.v2ray.com/en/configuration/routing.html#routingobject" target="_blank">RoutingObject</a>'
      )
    );

    const s1 = m.section(form.NamedSection, "main_routing", "routing");
    s1.anonymous = true;
    s1.addremove = false;

    let o;
    o = s1.option(form.Flag, "enabled", _("Enabled"));

    o = s1.option(
      form.ListValue,
      "domain_strategy",
      _("Domain resolution strategy")
    );
    o.value("");
    o.value("AsIs");
    o.value("IPIfNonMatch");
    o.value("IPOnDemand");

    o = s1.option(
      form.MultiValue,
      "rules",
      _("Rules"),
      _("Select routing rules to use")
    );
    for (const s of routingRules) {
      o.value(s.value, s.caption);
    }

    o = s1.option(
      form.MultiValue,
      "balancers",
      _("Balancers"),
      _("Select routing balancers to use")
    );
    for (const s of routingBalancers) {
      o.value(s.value, s.caption);
    }

    const s2 = m.section(
      form.GridSection,
      "routing_rule",
      _("Routing Rule"),
      _("Add routing rules here")
    );
    s2.anonymous = true;
    s2.addremove = true;
    s2.sortable = true;

    o = s2.option(form.DummyValue, "_alias", _("Alias"));
    o.modalonly = false;
    o.cfgvalue = function (section_id: string) {
      return uci.get("v2ray", section_id, "alias") ?? "?";
    };

    o = s2.option(form.DummyValue, "_type", _("Type"));
    o.modalonly = false;
    o.cfgvalue = function (section_id: string) {
      return uci.get("v2ray", section_id, "type") ?? "?";
    };

    o = s2.option(form.DummyValue, "_inbound_tag", _("Inbound Tag"));
    o.modalonly = false;
    o.cfgvalue = function (section_id: string) {
      const v = uci.get("v2ray", section_id, "inbound_tag");
      return L.toArray(v).join(" ") || "?";
    };

    o = s2.option(form.DummyValue, "_outbound_tag", _("Outbound Tag"));
    o.modalonly = false;
    o.cfgvalue = function (section_id: string) {
      return uci.get("v2ray", section_id, "outbound_tag") ?? "?";
    };

    o = s2.option(form.DummyValue, "_network", _("Network"));
    o.modalonly = false;
    o.cfgvalue = function (section_id: string) {
      return uci.get("v2ray", section_id, "network") ?? "?";
    };

    o = s2.option(form.Value, "alias", _("Alias"), _("Any custom string"));
    o.modalonly = true;
    o.rmempty = false;

    o = s2.option(form.ListValue, "type", _("Type"));
    o.modalonly = true;
    o.value("field");

    o = s2.option(form.DynamicList, "domain", _("Domain"));
    o.modalonly = true;

    o = s2.option(form.DynamicList, "ip", _("IP"));
    o.modalonly = true;

    o = s2.option(form.DynamicList, "port", _("Port"));
    o.modalonly = true;
    o.datatype = "or(port, portrange)";

    o = s2.option(form.MultiValue, "network", _("Network"));
    o.modalonly = true;
    o.value("tcp");
    o.value("udp");

    o = s2.option(form.DynamicList, "source", _("Source"));
    o.modalonly = true;

    o = s2.option(form.DynamicList, "user", _("User"));
    o.modalonly = true;

    o = s2.option(form.DynamicList, "inbound_tag", _("Inbound tag"));
    o.modalonly = true;

    o = s2.option(form.MultiValue, "protocol", _("Protocol"));
    o.modalonly = true;
    o.value("http");
    o.value("tls");
    o.value("bittorrent");

    o = s2.option(form.Value, "attrs", _("Attrs"));
    o.modalonly = true;

    o = s2.option(form.Value, "outbound_tag", _("Outbound tag"));
    o.modalonly = true;

    o = s2.option(form.Value, "balancer_tag", _("Balancer tag"));
    o.modalonly = true;
    o.depends("outbound_tag", "");

    const s3 = m.section(
      form.TypedSection,
      "routing_balancer",
      _("Routing Balancer", _("Add routing balancers here"))
    );
    s3.anonymous = true;
    s3.addremove = true;

    o = s3.option(form.Value, "tag", _("Tag"));
    o.rmempty = false;

    o = s3.option(form.DynamicList, "selector", _("Selector"));

    return m.render();
  },
});
