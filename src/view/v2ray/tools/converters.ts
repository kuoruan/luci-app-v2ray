"use strict";

// @ts-ignore
return L.Class.extend({
  extractGFWList: function (gfwlist: string): string {
    const gfwlistLines = gfwlist.split(/\r?\n/);

    const domainList: { [key: string]: boolean } = Object.create(null);

    for (const line of gfwlistLines) {
      if (!line || /^[![@]/.test(line) || /^(\d+\.){3}\d+/.test(line)) {
        continue;
      }

      const matches = line.match(/\w[\w-_]+\.\w[\w.-_]+/);

      let domain: string;
      if (matches && (domain = matches[0])) {
        domainList[domain] = true;
      }
    }

    return Object.keys(domainList).join("\n") + "\n";
  },

  extractCHNRoute: function (
    delegatedlist: string,
    ipv6: boolean = false
  ): string {
    const delegatedLines = delegatedlist.split(/\r?\n/);

    const ipList: string[] = [];

    const regex = ipv6
      ? /CN\|ipv6\|([0-9a-zA-Z:]+)\|(\d+)/
      : /CN\|ipv4\|([\d.]+)\|(\d+)/;

    for (const line of delegatedLines) {
      if (!line || line.indexOf("#") === 0) {
        continue;
      }

      const matches = line.match(regex);
      if (matches && matches.length >= 3) {
        const [, ip, value] = matches;

        if (ipv6) {
          ipList.push(`${ip}/${value}`);
        } else {
          // base log
          const mask = 32 - Math.log(+value) / Math.log(2);

          ipList.push(`${ip}/${mask}`);
        }
      }
    }

    return ipList.join("\n") + "\n";
  },
});
