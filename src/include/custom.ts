"use strict";
"require form";
"require fs";
"require baseclass";

const CUSTOMTextValue = form.TextValue.extend({
  filepath: null,
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
    if (!value) {
      return _("%s is required.").format(this.title);
    }

    try {
      JSON.parse(value);
    } catch (e) {
      return _("Invalid JSON content.");
    }
    return true;
  },
});

// @ts-ignore
return baseclass.extend({
  TextValue: CUSTOMTextValue,
});
