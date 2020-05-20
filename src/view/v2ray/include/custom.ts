"use strict";

// "require baseclass";
// "require dom";
"require form";
"require fs";
// "require poll";
"require rpc";
"require ui";

type ListStatus = {
  count: number;
  datetime: string;
};

const callRunningStatus = rpc.declare<{ code: number }>({
  object: "luci.v2ray",
  method: "runningStatus",
  params: [],
  expect: { "": { code: 1 } },
});

const callListStatus = rpc.declare<ListStatus, [string]>({
  object: "luci.v2ray",
  method: "listStatus",
  params: ["name"],
  expect: { "": { code: 1 } },
  filter: function (data: any): ListStatus {
    if (data.code === 0) {
      return {
        count: data.count,
        datetime: data.datetime,
      };
    }
    return {
      count: 0,
      datetime: _("Unknown"),
    };
  },
});

const callV2RayVersion = rpc.declare<string>({
  object: "luci.v2ray",
  method: "v2rayVersion",
  params: [],
  expect: { "": { code: 1 } },
  filter: function (data: any): string {
    return data.code ? "" : data.version;
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

const CUSTOMListStatusValue = form.AbstractValue.extend({
  __name__: "CUSTOM.ListStatusValue",
  listtype: null,
  onupdate: null,
  btnstyle: "button",
  btntitle: null,
  cfgvalue: function () {
    if (!this.listtype) {
      L.error("TypeError", "List type is required");
    }

    return L.resolveDefault(callListStatus(this.listtype), {
      count: 0,
      datetime: _("Unknown"),
    });
  },
  render: function (option_index: number, section_id: string) {
    return Promise.resolve(this.cfgvalue(section_id)).then(
      L.bind(function ({ count = 0, datetime = "" } = {}) {
        const title = this.titleFn("title", section_id);

        const config_name =
          this.uciconfig || this.section.uciconfig || this.map.config;
        const depend_list = this.transformDepList(section_id);

        const fieldChildren: HTMLDivElement[] = [
          E("div", {}, [
            E(
              "span",
              {
                style: "color: #ff8c00;margin-right: 5px;",
              },
              _("Total: %s").format(count)
            ),
            _("Time: %s").format(datetime),
            E(
              "button",
              {
                style: "margin-left: 10px;",
                class: "cbi-button cbi-button-%s".format(
                  this.btnstyle || "button"
                ),
                click: ui.createHandlerFn(
                  this,
                  function (
                    section_id: string,
                    listtype: string,
                    ev: MouseEvent
                  ) {
                    if (typeof this.onupdate === "function") {
                      this.onupdate(ev, section_id, listtype);
                    }
                  },
                  section_id,
                  this.listtype
                ),
              },
              this.titleFn("btntitle", section_id) || title
            ),
          ]),
        ];

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

const CUSTOMRunningStatus = form.AbstractValue.extend({
  __name__: "CUSTOM.RunningStatus",
  fetchVersion: function (node: HTMLElement) {
    L.resolveDefault(callV2RayVersion(), "").then(function (version: string) {
      L.dom.content(
        node,
        version
          ? _("Version: %s").format(version)
          : E("em", { style: "color: red;" }, _("Unable to get V2Ray version."))
      );
    });
  },
  pollStatus: function (node: HTMLElement) {
    const notRunning = E("span", { style: "color: red;" }, _("Not Running"));
    const running = E("span", { style: "color: green;" }, _("Running"));

    L.Poll.add(function () {
      L.resolveDefault(callRunningStatus(), { code: 0 }).then(function (res) {
        L.dom.content(node, res.code ? notRunning : running);
      });
    }, 5);
  },
  load: function () {},
  cfgvalue: function () {
    return;
  },
  render: function () {
    const status = E<HTMLSpanElement>(
      "span",
      {},
      E("em", {}, _("Collecting data..."))
    );

    const version = E<HTMLSpanElement>("span", {
      style: "margin-left: 10px;",
    });

    this.pollStatus(status);
    this.fetchVersion(version);

    return E("div", {}, [status, version]);
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
