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
* refer to [issue #42](https://github.com/kuoruan/luci-app-v2ray/issues/42#issuecomment-573342526), install `luci-compat` if you ran into error when trying to enter V2Ray service settings in LuCI

```sh
opkg install luci-compat
```

We also support HTTPS protocol.

4. Upgrade package:

```sh
opkg update
opkg upgrade luci-app-v2ray
opkg upgrade luci-i18n-v2ray-zh-cn
```

* upgrade `luci-compat` if you chose to install it in the last step:

```sh
opkg update
opkg upgrade luci-compat
```

### Manual install

1. Download ipk files from [release](https://github.com/kuoruan/luci-app-v2ray/releases) page

2. Upload files to your router

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

> You may need to remove ```dnsmasq``` before installing this package.

## Configure

1. Download V2Ray file from V2Ray release [link](https://github.com/v2ray/v2ray-core/releases) or V2Ray ipk release [link](https://github.com/kuoruan/openwrt-v2ray/releases).

2. Upload V2Ray file to your router, or install the ipk file.

3. Config V2Ray file path in LuCI page.

4. Add your inbound and outbound rules.

5. Enable the service via LuCI.

## Build

Package files is in branch [luci2](https://github.com/kuoruan/luci-app-v2ray/tree/luci2)

Download with Git:

```sh
git clone -b luci2 https://github.com/kuoruan/luci-app-v2ray.git luci-app-v2ray
```
