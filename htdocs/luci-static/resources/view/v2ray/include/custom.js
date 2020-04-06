"use strict";
"require form";
"require fs";
"require baseclass";
var CUSTOMTextValue = form.TextValue.extend({
    filepath: null,
    cfgvalue: function () {
        if (!this.filepath) {
            return this.super("cfgvalue", arguments);
        }
        return L.resolveDefault(fs.read(this.filepath), "");
    },
    write: function (__, value) {
        if (!this.filepath) {
            return this.super("write", arguments);
        }
        var trimmed = value.trim().replace(/\r\n/g, "\n") + "\n";
        return fs.write(this.filepath, trimmed);
    },
    validate: function (__, value) {
        if (!value) {
            return _("%s is required.").format(this.title);
        }
        try {
            JSON.parse(value);
        }
        catch (e) {
            return _("Invalid JSON content.");
        }
        return true;
    },
});
return baseclass.extend({
    TextValue: CUSTOMTextValue,
});
