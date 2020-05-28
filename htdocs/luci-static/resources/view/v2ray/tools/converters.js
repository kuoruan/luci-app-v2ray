/**
 * @license
 * Copyright 2020 Xingwang Liao <kuoruan@gmail.com>
 *
 * Licensed to the public under the MIT License.
 */
"use strict";"require view/v2ray/tools/base64 as base64";return L.Class.extend({extractGFWList:function(t){var e;try{e=base64.decode(t.replace(/\r?\n/g,""))}catch(t){e=""}if(!e)return"";for(var r=e.split(/\r?\n/),n=Object.create(null),a=0,s=r;a<s.length;a++){var i=s[a];if(i&&!/^[![@]/.test(i)&&!/(\d+\.){3}\d+/.test(i)){var c=i.match(/\w[\w-]*\.\w[\w\-.]+/),l=void 0;c&&(l=c[0])&&(n[l]=!0)}}return Object.keys(n).sort().join("\n")+"\n"},extractCHNRoute:function(t,e){void 0===e&&(e=!1);for(var r=[],n=e?/CN\|ipv6\|([0-9a-zA-Z:]+)\|(\d+)/:/CN\|ipv4\|([\d.]+)\|(\d+)/,a=0,s=t.split(/\r?\n/);a<s.length;a++){var i=s[a];if(i&&0!==i.indexOf("#")){var c=i.match(n);if(c&&c.length>=3){var l=c[1],u=c[2];if(e)r.push(l+"/"+u);else{var o=32-Math.log(+u)/Math.log(2);r.push(l+"/"+o)}}}}return r.join("\n")+"\n"},vmessLinkToVmess:function(t){var e,r,n;if(!t||!(t=t.trim())||!(e=t.match(/^vmess:\/\/([a-zA-Z0-9/+]+={0,2})$/i))||e.length<2)return null;try{r=base64.decode(e[1])}catch(t){r=""}if(!r)return null;try{n=JSON.parse(r)}catch(t){n=null}return n}});