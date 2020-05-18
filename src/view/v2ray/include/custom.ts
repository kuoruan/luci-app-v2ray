"use strict";

// "require baseclass";
// "require dom";
"require form";
"require fs";
"require rpc";
"require ui";

const callRunningStatus = rpc.declare<{ code: number }>({
  object: "luci.v2ray",
  method: "runningStatus",
  params: [],
  expect: { "": { code: 1 } },
});

const callCountList = rpc.declare<number, [string]>({
  object: "luci.v2ray",
  method: "countList",
  params: ["name"],
  expect: { "": { code: 1, count: 0 } },
  filter: function (data: any) {
    if (data.code === 0) {
      return data.count;
    }
    return 0;
  },
});

const callFileMTime = rpc.declare<string, [string]>({
  object: "file",
  method: "stat",
  params: ["path"],
  expect: { "": { mtime: 0 } },
  filter: function (data: any) {
    if (data.mtime) {
      return new Date(data.mtime * 1000).toUTCString();
    }

    return "Unknown";
  },
});

const CUSTOMTextValue = form.TextValue.extend<
  CustomTextValueProperties,
  form.TextValue
>({
  __name__: "CUSTOM.TextValue",
  filepath: null,
  isjson: false,
  required: false,
  cfgvalue: function () {
    if (!this.filepath) {
      return this.super("cfgvalue", L.toArray(arguments));
    }

    return L.resolveDefault(fs.read(this.filepath), "");
  },
  write: function (__: string, value: string) {
    if (!this.filepath) {
      return this.super("write", L.toArray(arguments));
    }

    const trimmed = value.trim().replace(/\r\n/g, "\n") + "\n";
    return fs.write(this.filepath, trimmed);
  },
  validate: function (section_id: string, value: string): string | boolean {
    if (this.required && !value) {
      const title = this.titleFn("title", section_id);
      return _("%s is required.").format(title);
    }

    if (this.isjson) {
      let obj;
      try {
        obj = JSON.parse(value);
      } catch (e) {
        if (!obj || typeof obj !== "object") {
          return _("Invalid JSON content.");
        }
      }
    }

    return true;
  },
});

type ListStatus = {
  lines: number;
  data: string;
};

const CUSTOMListStatusValue = form.Value.extend({
  __name__: "CUSTOM.ListStatusValue",
  listtype: null,
  updatebtn: false,
  btnstyle: "button",
  btntitle: null,
  onclick: null,
  renderWidget: function (
    section_id: string,
    option_index: number,
    cfgvalue: [string, string]
  ) {
    const outputEl = E("div");

    const [count, modifyTime] = cfgvalue;

    const children: (Node | string)[] = [
      _("Total: %s").format(
        `<span style="color: #ff8c00;margin: 0 5px;">${count}</span>`
      ),
      _("Time: %s").format(modifyTime),
    ];

    if (this.updatebtn) {
      const btn_title =
        this.titleFn("btntitle", section_id) ||
        this.titleFn("title", section_id);

      children.push(
        E<HTMLButtonElement>(
          "button",
          {
            class: "cbi-button cbi-button-%s".format(this.btnstyle || "button"),
            click: ui.createHandlerFn(
              this,
              function (
                this: any,
                section_id: string,
                listtype: string,
                ev: MouseEvent
              ) {
                if (this.onclick) {
                  return this.onclick(ev, section_id, listtype);
                }
                return false;
              },
              section_id,
              this.listtype
            ),
          },
          [btn_title]
        )
      );
    }

    L.dom.content(outputEl, children);

    return outputEl;
  },
  cfgvalue: function () {
    if (!this.listtype) {
      L.error("TypeError", "List type is required");
    }

    return Promise.all([
      callCountList(this.listtype),
      callFileMTime(`/etc/v2ray/${this.listtype}.txt`),
    ]);
  },
  remove: function () {},
  write: function () {},
});

const CUSTOMRunningStatus = form.Value.extend({
  __name__: "CUSTOM.RunningStatus",
  pollStatus: function () {
    poll.add(async function () {
      const statusElement = document.getElementById("v2ray_status");
      if (!statusElement) return;

      const res = await callRunningStatus();

      if (res.code === 0) {
        statusElement.innerHTML = _("Running");
      } else {
        statusElement.innerHTML = _("Not Running");
      }
    }, 5);
  },
  renderWidget: function () {
    this.pollStatus();

    return E(
      "div",
      {
        id: "v2ray_status",
      },
      E("em", {}, _("Collecting data..."))
    );
  },
  remove: function () {},
  write: function () {},
});

// @ts-ignore
return L.Class.extend({
  TextValue: CUSTOMTextValue,
  ListStatusValue: CUSTOMListStatusValue,
  RunningStatus: CUSTOMRunningStatus,
});
