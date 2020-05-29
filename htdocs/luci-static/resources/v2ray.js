/**
 * @license
 * Copyright 2020 Xingwang Liao <kuoruan@gmail.com>
 *
 * Licensed to the public under the MIT License.
 */
"use strict";"require fs";"require network";"require uci";return L.Class.extend({getLocalIPs:function(){return network.getNetworks().then((function(r){for(var t=["127.0.0.1","0.0.0.0","::"],n=0,e=r;n<e.length;n++){var o=e[n],i=o.getIPAddr(),u=o.getIP6Addr();i&&(i=i.split("/")[0])&&t.indexOf(i)<0&&t.push(i),u&&(u=u.split("/")[0])&&t.indexOf(u)<0&&t.push(u)}return t.sort()}))},getSections:function(r,t){return void 0===t&&(t="alias"),uci.load("v2ray").then((function(){var n=[];return uci.sections("v2ray",r,(function(r){var e;(e=r[t])&&n.push({caption:e,value:r[".name"]})})),n}))},getDokodemoDoorPorts:function(){return uci.load("v2ray").then((function(){var r=[];return uci.sections("v2ray","inbound",(function(t){var n;if("dokodemo-door"==t.protocol&&(n=t.port)){var e;(e=t.alias)?r.push({caption:"%s - %s".format(e,n),value:n}):r.push({caption:"%s:%s".format(t.listen,n),value:n})}})),r}))}});