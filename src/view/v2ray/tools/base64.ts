/**
 * @license
 * Copyright 2020 Xingwang Liao <kuoruan@gmail.com>
 *
 * Licensed to the public under the MIT License.
 */

"use strict";

// @ts-ignore
return L.Class.extend({
  decode: function (encoded: string) {
    const _hasatob = typeof atob === "function";
    const _hasBuffer = typeof Buffer === "function";
    const b64ch =
      "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    const b64chs = [...b64ch];
    const b64tab = ((a) => {
      const tab = {};
      a.forEach((c, i) => (tab[c] = i));
      return tab;
    })(b64chs);
    const b64re = /^(?:[A-Za-z\d+/]{4})*?(?:[A-Za-z\d+/]{2}(?:==)?|[A-Za-z\d+/]{3}=?)?$/;
    const _fromCC = String.fromCharCode.bind(String);
    const _tidyB64 = (s: string) => s.replace(/[^A-Za-z0-9+/]/g, "");
    /**
     * @deprecated should have been internal use only.
     * @param {string} src UTF-16 string
     * @returns {string} UTF-8 string
     */
    const btou = (src: string) => decodeURIComponent(escape(src));
    /**
     * polyfill version of `atob`
     */
    const atobPolyfill = (asc: string) => {
      // console.log('polyfilled');
      asc = asc.replace(/\s+/g, "");
      if (!b64re.test(asc)) throw new TypeError("malformed base64.");
      asc += "==".slice(2 - (asc.length & 3));
      let u24,
        bin = "",
        r1,
        r2;
      for (let i = 0; i < asc.length; ) {
        u24 =
          (b64tab[asc.charAt(i++)] << 18) |
          (b64tab[asc.charAt(i++)] << 12) |
          ((r1 = b64tab[asc.charAt(i++)]) << 6) |
          (r2 = b64tab[asc.charAt(i++)]);
        bin +=
          r1 === 64
            ? _fromCC((u24 >> 16) & 255)
            : r2 === 64
            ? _fromCC((u24 >> 16) & 255, (u24 >> 8) & 255)
            : _fromCC((u24 >> 16) & 255, (u24 >> 8) & 255, u24 & 255);
      }
      return bin;
    };
    /**
     * does what `window.atob` of web browsers do.
     * @param {String} asc Base64-encoded string
     * @returns {string} binary string
     */
    const _atob = _hasatob
      ? (asc: string) => atob(_tidyB64(asc))
      : _hasBuffer
      ? (asc: string) => Buffer.from(asc, "base64").toString("binary")
      : atobPolyfill;
    const _decode = _hasBuffer
      ? (a: string) => Buffer.from(a, "base64").toString("utf8")
      : (a: string) => btou(_atob(a));
    const _unURI = (a: string) =>
      _tidyB64(a.replace(/[-_]/g, (m0) => (m0 == "-" ? "+" : "/")));
    /**
     * converts a Base64 string to a UTF-8 string.
     * @param {String} src Base64 string.  Both normal and URL-safe are supported
     * @returns {string} UTF-8 string
     */
    const decode = (src: string) => _decode(_unURI(src));
    return decode(encoded);
  },

  encode: function (str: string) {
    const _hasbtoa = typeof btoa === "function";
    const _hasBuffer = typeof Buffer === "function";
    const b64ch =
      "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    const b64chs = [...b64ch];
    const _mkUriSafe = (src: string) =>
      src.replace(/[+/]/g, (m0) => (m0 == "+" ? "-" : "_")).replace(/=+$/m, "");
    /**
     * polyfill version of `btoa`
     */
    const btoaPolyfill = (bin: string) => {
      // console.log('polyfilled');
      let u32,
        c0,
        c1,
        c2,
        asc = "";
      const pad = bin.length % 3;
      for (let i = 0; i < bin.length; ) {
        if (
          (c0 = bin.charCodeAt(i++)) > 255 ||
          (c1 = bin.charCodeAt(i++)) > 255 ||
          (c2 = bin.charCodeAt(i++)) > 255
        )
          throw new TypeError("invalid character found");
        u32 = (c0 << 16) | (c1 << 8) | c2;
        asc +=
          b64chs[(u32 >> 18) & 63] +
          b64chs[(u32 >> 12) & 63] +
          b64chs[(u32 >> 6) & 63] +
          b64chs[u32 & 63];
      }
      return pad ? asc.slice(0, pad - 3) + "===".substring(pad) : asc;
    };
    /**
     * does what `window.btoa` of web browsers do.
     * @param {String} bin binary string
     * @returns {string} Base64-encoded string
     */
    const _btoa = _hasbtoa
      ? (bin: string) => btoa(bin)
      : _hasBuffer
      ? (bin: string) => Buffer.from(bin, "binary").toString("base64")
      : btoaPolyfill;
    /**
     * @deprecated should have been internal use only.
     * @param {string} src UTF-8 string
     * @returns {string} UTF-16 string
     */
    const utob = (src: string) => unescape(encodeURIComponent(src));
    //
    const _encode = _hasBuffer
      ? (s: string) => Buffer.from(s, "utf8").toString("base64")
      : (s: string) => _btoa(utob(s));
    /**
     * converts a UTF-8-encoded string to a Base64 string.
     * @param {boolean} [urlsafe] if `true` make the result URL-safe
     * @returns {string} Base64 string
     */
    const encode = (src: string, urlsafe = false) =>
      urlsafe ? _mkUriSafe(_encode(src)) : _encode(src);
    return encode(str);
  },
});
