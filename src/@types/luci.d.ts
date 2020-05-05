declare class UCI {
  load(config: string | string[]): Promise<string[]>;
  add(config: string, type: string, name: string): string;
  sections(config: string, type: string, cb: Function): any[];
}

declare const L: any;
declare const E: any;
declare const custom: any;
declare const dom: any;
declare const form: any;
declare const fs: any;
declare const uci: UCI;
declare const view: any;
declare const network: any;
declare const poll: any;
declare const ui: any;

declare function _(s: string): string;
