# luci-app-v2ray

Luci support for V2Ray

[![Release Version](https://img.shields.io/github/release/kuoruan/luci-app-v2ray.svg)](https://github.com/kuoruan/luci-app-v2ray/releases/latest) [![Latest Release Download](https://img.shields.io/github/downloads/kuoruan/luci-app-v2ray/latest/total.svg)](https://github.com/kuoruan/luci-app-v2ray/releases/latest) [![Total Download](https://img.shields.io/github/downloads/kuoruan/luci-app-v2ray/total.svg)](https://github.com/kuoruan/luci-app-v2ray/releases)

## Install

### Install via OPKG (recommend)

1. Add new opkg key:

```sh
wget -O kuoruan-public.key http://openwrt.kuoruan.net/packages/public.key
opkg-key add kuoruan-public.key
```

2. Add opkg repository from kuoruan:

```sh
echo "src/gz kuoruan_universal http://openwrt.kuoruan.net/packages/releases/all" \
  >> /etc/opkg/customfeeds.conf
opkg update
```

3. Install package:

```sh
opkg install luci-app-v2ray
opkg install luci-i18n-v2ray-zh-cn
```

We also support HTTPS protocol.

4. Upgrade package:

```sh
opkg update
opkg upgrade luci-app-v2ray
opkg upgrade luci-i18n-v2ray-zh-cn
```

### Manual install

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
- dnsmasq-full (dnsmasq ipset is required)

For translations, please install ```luci-i18n-v2ray-*```.

> You may need to remove ```dnsmasq``` before installing this package.

## Configure

1. Download V2Ray file from V2Ray release [link](https://github.com/v2ray/v2ray-core/releases) or V2Ray ipk release [link](https://github.com/kuoruan/openwrt-v2ray/releases).

2. Upload V2Ray file to your router, or install the ipk file.

3. Config V2Ray file path in LuCI page.

4. Add your inbound and outbound rules.

5. Enable the service via LuCI.
