"use strict";

"require form";
"require ui";
// "require view";

// @ts-ignore
return L.view.extend({
  render: function () {
    const configTextarea = new ui.Textarea();

    return E([configTextarea.render()]);
  },
  handleReset: null,
  handleSave: null,
  handleSaveApply: null,
});
