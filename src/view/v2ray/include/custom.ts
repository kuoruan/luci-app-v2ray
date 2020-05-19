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

const CUSTOMListStatusValue = form.AbstractValue.extend({
  __name__: "CUSTOM.ListStatusValue",
  listtype: null,
  updatebtn: false,
  btnstyle: "button",
  btntitle: null,
  onclick: null,
  cfgvalue: function () {
    if (!this.listtype) {
      L.error("TypeError", "List type is required");
    }

    return Promise.all([
      L.resolveDefault(callCountList(this.listtype), 0),
      L.resolveDefault(callFileMTime(`/etc/v2ray/${this.listtype}.txt`), ""),
    ]);
  },
  render: function (option_index: number, section_id: string) {
    return Promise.resolve(this.cfgvalue(section_id)).then(
      L.bind(function ([count = 0, modifyTime = ""] = []) {
        const title = this.titleFn("title", section_id);

        const config_name =
          this.uciconfig || this.section.uciconfig || this.map.config;
        const depend_list = this.transformDepList(section_id);

        const outputEl = E<HTMLDivElement>("div");

        const children: (Node | string)[] = [
          E(
            "span",
            {
              style: "color: #ff8c00;margin-right: 5px;",
            },
            _("Total: %s").format(count)
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
                class: "cbi-button cbi-button-%s".format(
                  this.btnstyle || "button"
                ),
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

        const fieldChildren: HTMLDivElement[] = [outputEl];

        if (typeof this.description === "string" && this.description !== "") {
          fieldChildren.push(
            E("div", { class: "cbi-value-description" }, this.description)
          );
        }

        const optionEl = E<HTMLDivElement>(
          "div",
          {
            class: "cbi-value",
            id: "cbi-%s-%s-%s".format(config_name, section_id, this.option),
            "data-index": option_index,
            "data-depends": depend_list,
            "data-field": this.cbid(section_id),
            "data-name": this.option,
            "data-widget": this.__name__,
          },
          [
            E(
              "label",
              {
                class: "cbi-value-title",
                for: "widget.cbid.%s.%s.%s".format(
                  config_name,
                  section_id,
                  this.option
                ),
              },
              [title]
            ),
            E("div", { class: "cbi-value-field" }, fieldChildren),
          ]
        );

        if (depend_list && depend_list.length) {
          optionEl.classList.add("hidden");
        }

        optionEl.addEventListener(
          "widget-change",
          L.bind(this.map.checkDepends, this.map)
        );

        L.dom.bindClassInstance(optionEl, this);

        return optionEl;
      }, this)
    );
  },
  remove: function () {},
  write: function () {},
});

const CUSTOMRunningStatus = form.Value.extend({
  __name__: "CUSTOM.RunningStatus",
  pollStatus: function () {
    poll.add(function () {
      const statusElement = document.getElementById("v2ray_status");
      if (!statusElement) return;

      callRunningStatus().then(function (res) {
        if (res.code === 0) {
          statusElement.innerHTML = _("Running");
        } else {
          statusElement.innerHTML = _("Not Running");
        }
      });
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
