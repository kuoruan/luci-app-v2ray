/**
 * @license
 * Copyright 2020 Xingwang Liao <kuoruan@gmail.com>
 *
 * Licensed to the public under the MIT License.
 */

"use strict";

"require form";
"require fs";
// "require request";
"require rpc";
"require uci";
"require ui";
"require v2ray";
// "require view";

"require tools/widgets as widgets";

"require view/v2ray/include/custom as custom";
"require view/v2ray/tools/converters as converters";

const gfwlistUrls = {
  github:
    "https://raw.githubusercontent.com/gfwlist/gfwlist/master/gfwlist.txt",
  gitlab: "https://gitlab.com/gfwlist/gfwlist/raw/master/gfwlist.txt",
  pagure: "https://pagure.io/gfwlist/raw/master/f/gfwlist.txt",
  bitbucket: "https://bitbucket.org/gfwlist/gfwlist/raw/HEAD/gfwlist.txt",
};

const apnicDelegatedUrls = {
  apnic: "https://ftp.apnic.net/stats/apnic/delegated-apnic-latest",
  arin: "https://ftp.arin.net/pub/stats/apnic/delegated-apnic-latest",
  ripe: "https://ftp.ripe.net/pub/stats/apnic/delegated-apnic-latest",
  iana: "https://ftp.iana.org/pub/mirror/rirstats/apnic/delegated-apnic-latest",
};

// @ts-ignore
return L.view.extend<[SectionItem[], Lease[]]>({
  handleListUpdate(ev: MouseEvent, section_id: string, listtype: string) {
    const hideModal = function () {
      ui.hideModal();

      window.location.reload();
    };

    switch (listtype) {
      case "gfwlist": {
        const gfwlistMirror =
          uci.get<string>("v2ray", section_id, "gfwlist_mirror") || "github";
        const url = gfwlistUrls[gfwlistMirror];

        return L.Request.request(L.url("admin/services/v2ray/request"), {
          method: "post",
          timeout: 50 * 1000,
          query: {
            url: url,
            token: L.env.token,
            sessionid: L.env.sessionid,
          },
        })
          .then(function (res: LuCI.response) {
            let data;
            if (res.status === 200 && (data = res.json())) {
              let content;
              if (!data.code && (content = data.content)) {
                const gfwlistDomains = converters.extractGFWList(content);
                if (gfwlistDomains) {
                  fs.write("/etc/v2ray/gfwlist.txt", gfwlistDomains)
                    .then(function () {
                      ui.showModal(_("List Update"), [
                        E("p", _("GFWList updated.")),
                        E(
                          "div",
                          { class: "right" },
                          E(
                            "button",
                            {
                              class: "btn",
                              click: hideModal,
                            },
                            _("OK")
                          )
                        ),
                      ]);
                    })
                    .catch(L.raise);
                } else {
                  L.raise("Error", _("Failed to decode GFWList."));
                }
              } else {
                L.raise("Error", data.message || _("Failed to fetch GFWList."));
              }
            } else {
              L.raise("Error", res.statusText);
            }
          })
          .catch(function (e) {
            ui.addNotification(null, E("p", e.message));
          });
      }
      case "chnroute":
      case "chnroute6": {
        const delegatedMirror =
          uci.get<string>("v2ray", section_id, "apnic_delegated_mirror") ||
          "apnic";

        const url = apnicDelegatedUrls[delegatedMirror];

        return L.Request.request(L.url("admin/services/v2ray/request"), {
          method: "post",
          timeout: 50 * 1000,
          query: {
            url: url,
            token: L.env.token,
            sessionid: L.env.sessionid,
          },
        })
          .then(function (res: LuCI.response) {
            let data;
            if (res.status === 200 && (data = res.json())) {
              let content;
              if ((content = data.content)) {
                const ipList = converters.extractCHNRoute(
                  content,
                  listtype === "chnroute6"
                );

                fs.write(`/etc/v2ray/${listtype}.txt`, ipList)
                  .then(function () {
                    ui.showModal(_("List Update"), [
                      E("p", _("CHNRoute list updated.")),
                      E(
                        "div",
                        { class: "right" },
                        E(
                          "button",
                          {
                            class: "btn",
                            click: hideModal,
                          },
                          _("OK")
                        )
                      ),
                    ]);
                  })
                  .catch(L.raise);
              } else {
                L.raise(
                  "Error",
                  data.message || _("Failed to fetch CHNRoute list.")
                );
              }
            } else {
              L.raise("Error", res.statusText);
            }
          })
          .catch(function (e) {
            ui.addNotification(null, E("p", e.message));
          });
      }

      default: {
        ui.addNotification(null, _("Unexpected error."));
      }
    }
  },
  load: function () {
    return Promise.all([v2ray.getDokodemoDoorPorts(), v2ray.getDHCPLeases()]);
  },
  render: function ([dokodemoDoorPorts = [], dhcpLeases = []] = []) {
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
    for (const p of dokodemoDoorPorts) {
      o.value(p.value, p.caption);
    }
    o.datatype = "port";

    o = s.option(
      widgets.NetworkSelect,
      "lan_ifaces",
      _("LAN interfaces"),
      _("Enable proxy on selected interfaces.")
    );
    o.multiple = true;
    o.nocreate = true;
    o.filter = function (section_id: string, value: string) {
      return value.indexOf("wan") < 0;
    };
    o.rmempty = false;

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
    o.btnstyle = "apply";
    o.onupdate = L.bind(this.handleListUpdate, this);

    o = s.option(form.ListValue, "gfwlist_mirror", _("GFWList mirror"));
    o.value("github", "GitHub");
    o.value("gitlab", "GitLab");
    o.value("bitbucket", "Bitbucket");
    o.value("pagure", "Pagure");

    o = s.option(custom.ListStatusValue, "_gfwlist", _("GFWList"));
    o.listtype = "gfwlist";
    o.btntitle = _("Update");
    o.btnstyle = "apply";
    o.onupdate = L.bind(this.handleListUpdate, this);

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

    o = s.option(form.DynamicList, "direct_client6", _("Direct IPv6 Clients"));
    for (const l of dhcpLeases) {
      if (l.ipv6) {
        o.value(l.ipaddr, l.hostname || l.ipaddr);
      }
    }

    o = s.option(form.DynamicList, "direct_client4", _("Direct IPv4 Clients"));
    for (const l of dhcpLeases) {
      if (!l.ipv6) {
        o.value(l.ipaddr, l.hostname || l.ipaddr);
      }
    }

    return m.render();
  },
});
