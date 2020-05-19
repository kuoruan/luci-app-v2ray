"use strict";

// "require baseclass";
"require fs";
"require network";
"require uci";

// @ts-ignore
return L.Class.extend({
  getLocalIPs: function (): Promise<string[]> {
    return network.getDevices().then(function (devices: network.Device[]) {
      const localIPs: string[] = ["127.0.0.1", "0.0.0.0", "::"];

      for (const d of devices) {
        const IPv4s = d.getIPAddrs();
        const IPv6s = d.getIP6Addrs();

        for (const IPv4 of IPv4s) {
          if (IPv4 && localIPs.indexOf(IPv4) < 0) {
            localIPs.push(IPv4);
          }
        }

        for (const IPv6 of IPv6s) {
          if (IPv6 && localIPs.indexOf(IPv6) < 0) {
            localIPs.push(IPv6);
          }
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
    return uci
      .load("v2ray")
      .then(function () {
        const sections: SectionItem[] = [];

        uci.sections("v2ray", type, function (s: any) {
          let caption: string;
          if ((caption = s[captionKey])) {
            sections.push({
              caption: caption,
              value: s[".name"],
            });
          }
        });
        return sections;
      })
      .catch(function () {
        return [];
      });
  },

  fileExist: function (path: string): Promise<boolean> {
    return fs
      .stat(path)
      .then(function () {
        return true;
      })
      .catch(function () {
        return false;
      });
  },
});
