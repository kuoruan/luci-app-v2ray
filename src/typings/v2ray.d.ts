type SectionItem = {
  caption: string;
  value: string;
};

type CustomTextValueProperties = {
  filepath: string | null;
  isjson: boolean;
  required: boolean;
};

interface Custom extends LuCI.baseclass {
  TextValue: form.TextValue & CustomTextValueProperties;
  RunningStatus: form.Value;
}

interface V2Ray extends LuCI.baseclass {
  getLocalIPs(): Promise<string[]>;
  getSections(type: string): Promise<SectionItem[]>;
  getLanInterfaces(): Promise<SectionItem[]>;
  getDokodemoDoorPorts(): Promise<SectionItem[]>;
}

interface Base64 extends LuCI.baseclass {
  encode(str: string): string;
  decode(str: string): string;
}

interface Converters extends LuCI.baseclass {
  extractGFWList(gfwlist: string): string;
  extractCHNRoute(delegatedlist: string, ipv6?: boolean): string;
}

declare const base64: Base64;
declare const converters: Converters;
declare const custom: Custom;
declare const v2ray: V2Ray;
