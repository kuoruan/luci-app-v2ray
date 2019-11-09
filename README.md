# luci-app-v2ray

Luci support for V2Ray

[![Release Version](https://img.shields.io/github/release/kuoruan/luci-app-v2ray.svg)](https://github.com/kuoruan/luci-app-v2ray/releases/latest) [![Latest Release Download](https://img.shields.io/github/downloads/kuoruan/luci-app-v2ray/latest/total.svg)](https://github.com/kuoruan/luci-app-v2ray/releases/latest) [![Total Download](https://img.shields.io/github/downloads/kuoruan/luci-app-v2ray/total.svg)](https://github.com/kuoruan/luci-app-v2ray/releases)

## Install

1. Download ipk files from [release](https://github.com/kuoruan/luci-app-v2ray/releases) page

2. Upload files to your router

3. Install package with opkg:

```sh
opkg install luci-app-v2ray_*.ipk
```

Depends:

- jshn
- luci-lib-jsonc
- ip
- ipset
- iptables
- iptables-mod-tproxy
- resolveip
- dnsmasq-full (optional)

For translations, please install ```luci-i18n-v2ray-*```.

## Configure

1. Download V2Ray file from V2Ray release [link](https://github.com/v2ray/v2ray-core/releases) or V2Ray ipk release [link](https://github.com/kuoruan/openwrt-v2ray/releases).

2. Upload V2Ray file to your router, or install the ipk file.

3. Config V2Ray file path in LuCI page.

4. Add your inbound and outbound rules.

5. Enable the service via LuCI.
