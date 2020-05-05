"use strict";

// "require baseclass";
"require dom";
"require form";
"require fs";
"require ui";

const CUSTOMTextValue = form.TextValue.extend({
  __name__: "CUSTOM.TextValue",
  filepath: null,
  isjson: false,
  required: false,
  cfgvalue: function () {
    if (!this.filepath) {
      return this.super("cfgvalue", arguments);
    }

    return L.resolveDefault(fs.read(this.filepath), "");
  },
  write: function (__: string, value: string) {
    if (!this.filepath) {
      return this.super("write", arguments);
    }

    const trimmed = value.trim().replace(/\r\n/g, "\n") + "\n";
    return fs.write(this.filepath, trimmed);
  },
  validate: function (__: string, value: string): string | boolean {
    if (this.required && !value) {
      return _("%s is required.").format(this.title);
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
  inputstyle: "button",
  renderWidget: function (
    section_id: string,
    option_index: number,
    cfgvalue: string
  ) {
    const value = cfgvalue != null ? cfgvalue : this.default,
      hiddenEl = new ui.Hiddenfield(value, { id: this.cbid(section_id) }),
      outputEl = E("div"),
      btn_title =
        this.titleFn("inputtitle", section_id) ||
        this.titleFn("title", section_id);

    if (value !== false) {
      const children: HTMLElement[] = [E("p", {}, [])];

      if (this.updatebtn) {
        children.push(
          E(
            "button",
            {
              class: "cbi-button cbi-button-%s".format(
                this.inputstyle || "button"
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

      dom.content(outputEl, children);
    } else {
      dom.content(outputEl, " - ");
    }

    return E([outputEl, hiddenEl.render()]);
  },
  cfgvalue: function () {
    if (!this.listtype) {
      L.error("TypeError", "List type is required");
    }

    return L.resolveDefault(fs.read(""));
  },
  remove: function () {},
  write: function () {},
});

// @ts-ignore
return L.Class.extend({
  TextValue: CUSTOMTextValue,
  ListStatusValue: CUSTOMListStatusValue,
});
