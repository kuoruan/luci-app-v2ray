type SectionItem = {
  caption: string;
  value: string;
};

type CustomTextValueProperties = {
  filepath: string | null;
  isjson: boolean;
  required: boolean;
};

declare interface Custom extends LuCI.baseclass {
  TextValue: form.TextValue & CustomTextValueProperties;
}

declare interface V2Ray extends LuCI.baseclass {
  getLocalIPs(): Promise<string[]>;
  getSections(type: string): Promise<SectionItem[]>;
  fileExist(path: string): Promise<boolean>;
}

declare interface Base64 extends LuCI.baseclass {
  encode(str: string): string;
  edcode(str: string): string;
}

declare const custom: Custom;
declare const v2ray: V2Ray;
declare const base64: Base64;
