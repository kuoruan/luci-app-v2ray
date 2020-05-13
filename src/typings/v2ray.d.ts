type SectionItem = {
  caption: string;
  value: string;
};

declare interface V2Ray {
  getLocalIPs(): Promise<string[]>;
  getSections(type: string): Promise<SectionItem[]>;
  fileExist(path: string): Promise<boolean>;
  base64Decode(encoded: string): string;
  base64Encode(str: string): string;
}

declare const custom: any;
declare const v2ray: V2Ray;
