"use strict";

// "require baseclass";
"require fs";
"require network";
"require uci";

const b64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
const b64re = /^(?:[A-Za-z\d+\\/]{4})*?(?:[A-Za-z\d+\\/]{2}(?:==)?|[A-Za-z\d+\\/]{3}=?)?$/;

const v: V2Ray = {
  getLocalIPs: function (): Promise<string[]> {
    return network.getNetworks().then(function (networks: any[]) {
      const localIPs: string[] = ["127.0.0.1", "0.0.0.0", "::"];

      for (const n of networks) {
        const IPv4 = n.getIPAddr();
        const IPv6CIDR = n.getIP6Addr();

        if (IPv4 && localIPs.indexOf(IPv4) < 0) {
          localIPs.push(IPv4);
        }

        let IPv6: string;
        if (
          IPv6CIDR &&
          (IPv6 = IPv6CIDR.split("/")[0]) &&
          localIPs.indexOf(IPv6) < 0
        ) {
          localIPs.push(IPv6);
        }
      }

      return localIPs.sort();
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

  fileExist: function (path: string) {
    return fs
      .stat(path)
      .then(function () {
        return true;
      })
      .catch(function () {
        return false;
      });
  },

  base64Decode:
    window.atob ||
    function (encoded: string) {
      // atob can work with strings with whitespaces, even inside the encoded part,
      // but only \t, \n, \f, \r and ' ', which can be stripped.
      encoded = String(encoded).replace(/[\t\n\f\r ]+/g, "");
      if (!b64re.test(encoded))
        throw new TypeError(
          "Failed to execute 'atob' on 'Window': The string to be decoded is not correctly encoded."
        );

      // Adding the padding if missing, for semplicity
      encoded += "==".slice(2 - (encoded.length & 3));
      let bitmap,
        result = "",
        r1,
        r2,
        i = 0;
      for (; i < encoded.length; ) {
        bitmap =
          (b64.indexOf(encoded.charAt(i++)) << 18) |
          (b64.indexOf(encoded.charAt(i++)) << 12) |
          ((r1 = b64.indexOf(encoded.charAt(i++))) << 6) |
          (r2 = b64.indexOf(encoded.charAt(i++)));

        result +=
          r1 === 64
            ? String.fromCharCode((bitmap >> 16) & 255)
            : r2 === 64
            ? String.fromCharCode((bitmap >> 16) & 255, (bitmap >> 8) & 255)
            : String.fromCharCode(
                (bitmap >> 16) & 255,
                (bitmap >> 8) & 255,
                bitmap & 255
              );
      }
      return result;
    },

  base64Encode:
    window.btoa ||
    function (str: string) {
      str = String(str);
      let bitmap,
        a,
        b,
        c,
        result = "",
        i = 0;
      const rest = str.length % 3; // To determine the final padding

      for (; i < str.length; ) {
        if (
          (a = str.charCodeAt(i++)) > 255 ||
          (b = str.charCodeAt(i++)) > 255 ||
          (c = str.charCodeAt(i++)) > 255
        )
          throw new TypeError(
            "Failed to execute 'btoa' on 'Window': The string to be encoded contains characters outside of the Latin1 range."
          );

        bitmap = (a << 16) | (b << 8) | c;
        result +=
          b64.charAt((bitmap >> 18) & 63) +
          b64.charAt((bitmap >> 12) & 63) +
          b64.charAt((bitmap >> 6) & 63) +
          b64.charAt(bitmap & 63);
      }

      // If there's need of padding, replace the last 'A's with equal signs
      return rest ? result.slice(0, rest - 3) + "===".substring(rest) : result;
    },
};

// @ts-ignore
return L.Class.extend(v);
