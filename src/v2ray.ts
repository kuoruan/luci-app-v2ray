"use strict";

// "require baseclass";
"require fs";
"require network";
"require uci";

// @ts-ignore
return L.Class.extend({
  getLocalIPs: function (): Promise<string[]> {
    return network.getNetworks().then(function (networks: network.Protocol[]) {
      const localIPs: string[] = ["127.0.0.1", "0.0.0.0", "::"];

      for (const n of networks) {
        let IPv4 = n.getIPAddr();
        let IPv6 = n.getIP6Addr();

        if (IPv4 && (IPv4 = IPv4.split("/")[0]) && localIPs.indexOf(IPv4) < 0) {
          localIPs.push(IPv4);
        }

        if (IPv6 && (IPv6 = IPv6.split("/")[0]) && localIPs.indexOf(IPv6) < 0) {
          localIPs.push(IPv6);
        }
      }

      return localIPs.sort();
    });
  },

  getLanInterfaces: function (): Promise<SectionItem[]> {
    return network.getNetworks().then(function (networks: network.Protocol[]) {
      const sections: SectionItem[] = [];

      for (const n of networks) {
        const netName = n.getName();

        if (netName !== "loopback" && netName.indexOf("wan") < 0) {
          sections.push({ caption: n.getI18n(), value: netName });
        }
      }

      return sections;
    });
  },

  getSections: function (
    type: string,
    captionKey: string = "alias"
  ): Promise<SectionItem[]> {
    return uci.load("v2ray").then(function () {
      const sections: SectionItem[] = [];

      uci.sections("v2ray", type, function (s: uci.SectionObject) {
        let caption: string;
        if ((caption = s[captionKey])) {
          sections.push({
            caption: caption,
            value: s[".name"],
          });
        }
      });
      return sections;
    });
  },

  getDokodemoDoorPorts: function (): Promise<SectionItem[]> {
    return uci.load("v2ray").then(function () {
      const sections: SectionItem[] = [];

      uci.sections("v2ray", "inbound", function (s: uci.SectionObject) {
        let port: string;
        if (s["protocol"] == "dokodemo-door" && (port = s["port"])) {
          let alias: string;

          if ((alias = s["alias"])) {
            sections.push({
              caption: "%s - %s".format(alias, port),
              value: port,
            });
          } else {
            sections.push({
              caption: "%s:%s".format(s["listen"], port),
              value: port,
            });
          }
        }
      });

      return sections;
    });
  },
});
