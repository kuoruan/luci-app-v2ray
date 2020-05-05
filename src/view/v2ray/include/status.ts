"use strict";

"require poll";
"require fs";
"require ui";
// "require view";

// @ts-ignore
return ui.AbstractElement.extend({
  pollStatus: function (clientFile: string | null) {
    poll.add(async function () {
      const statusElement = document.getElementById("v2ray_status");

      const pid = await L.resolveDefault(
        fs.read("/var/run/v2ray.main.pid"),
        ""
      );

      if (pid && clientFile) {
        const res = await L.resolveDefault(
          fs.exec("pidof %s 2>/dev/null | grep -q %s".format(clientFile, pid)),
          { code: 1 }
        );

        if (res.code === 0) {
          statusElement?.innerHTML(_("Running"));
          return;
        }
      }

      statusElement?.innerHTML(_("Not Running"));
    }, 5);
  },
  load: function () {
    return uci.load("v2ray").then(function () {
      return uci.get("v2ray", "main", "v2ray_file");
    });
  },
  render: function (clientFile: string | null) {
    this.pollStatus(clientFile);
    return E(
      "div",
      { class: "cbi-section" },
      E(
        "p",
        {
          id: "v2ray_status",
        },
        E("em", {}, _("Collecting data..."))
      )
    );
  },
});
