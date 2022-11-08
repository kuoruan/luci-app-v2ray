# luci-app-v2ray

Luci support for V2Ray

**This branch is new LuCI for OpenWrt 19.07 and later.**

**For legacy version: [Branch legacy](https://github.com/kuoruan/luci-app-v2ray/tree/legacy)**

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
```
wget https://github.com/kuoruan/luci-app-v2ray/releases/download/v2.0.0-1/luci-app-v2ray_2.0.0-1_all.ipk
```

2. Upload files to your router
```
scp luci-app-v2ray_2.0.0-1_all.ipk root@192.168.1.1:/root
```

3. Install package with opkg:

```sh
opkg install luci-app-v2ray_*.ipk
```

Dependencies:

- jshn
- ip (ip-tiny or ip-full)
- ipset
- iptables
- iptables-mod-tproxy
- resolveip
- dnsmasq-full (dnsmasq ipset is required)

For translations, please install ```luci-i18n-v2ray-*```.

> You may need to remove ```dnsmasq``` before installing this package. (`opkg remove dnsmasq && opkg install dnsmasq-full`)

## Configure

1. Download V2Ray file from V2Ray release [link](https://github.com/v2fly/v2ray-core/releases/tag/v5.1.0) or .ipk file form [here](http://openwrt.kuoruan.net/packages/releases/).

2. Upload those files to your router, and install them.

3. Config V2Ray file path in LuCI page (http://192.168.1.1/cgi-bin/luci/admin/services/v2ray).

4. Add your inbound and outbound rules (refer the v2ray docs for more information: https://www.v2ray.com/en/configuration/routing.html#routing).

5. Enable the service via LuCI.

> More info about how to manually install opkg file: https://yingshaoxo.blogspot.com/2022/11/how-to-install-opkg-package-manually.html

> More info about how to do those operations in the shell (or terminal): https://yingshaoxo.blogspot.com/2022/11/master-linux-learn-more-commands-1.html

## Build

Package files is in branch [luci2](https://github.com/kuoruan/luci-app-v2ray/tree/luci2)

Download with Git:

```sh
git clone -b luci2 https://github.com/kuoruan/luci-app-v2ray.git luci-app-v2ray
```
