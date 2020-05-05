"use strict";

"require form";
"require uci";
"require v2ray";
// "require view";

// @ts-ignore
return L.view.extend({
  load: function () {
    return v2ray.getSections("policy_level", "level");
  },
  render: function (policyLevels: ReturnType<typeof v2ray.getSections> = []) {
    const m = new form.Map(
      "v2ray",
      "%s - %s".format(_("V2Ray"), _("Policy")),
      _("Details: %s").format(
        '<a href="https://www.v2ray.com/en/configuration/policy.html#policyobject" target="_blank">PolicyObject</a>'
      )
    );

    const s1 = m.section(form.NamedSection, "main_policy", "policy");
    s1.anonymous = true;
    s1.addremove = false;

    let o;
    o = s1.option(form.Flag, "enabled", _("Enabled"));
    o.rmempty = false;

    o = s1.option(
      form.MultiValue,
      "levels",
      _("Levels"),
      _("Select policy levels")
    );
    for (const s of policyLevels) {
      o.value(s.value, s.caption);
    }

    o = s1.option(
      form.Flag,
      "system_stats_inbound_uplink",
      "%s - %s".format(_("System"), _("Stats inbound uplink"))
    );

    o = s1.option(
      form.Flag,
      "system_stats_inbound_downlink",
      "%s - %s".format(_("System"), _("Stats inbound downlink"))
    );

    const s2 = m.section(
      form.GridSection,
      "policy_level",
      _("Policy Level"),
      _("Add policy levels here")
    );
    s2.anonymous = true;
    s2.addremove = true;
    s2.sortable = true;

    o = s2.option(form.Value, "level", _("Level"));
    o.rmempty = false;
    o.datatype = "uinteger";

    o = s2.option(form.Value, "handshake", _("Handshake"));
    o.datatype = "uinteger";
    o.placeholder = "4";

    o = s2.option(form.Value, "conn_idle", _("Connection idle"));
    o.datatype = "uinteger";
    o.placeholder = "300";

    o = s2.option(form.Value, "uplink_only", _("Uplink only"));
    o.modalonly = true;
    o.datatype = "uinteger";
    o.placeholder = "2";

    o = s2.option(form.Value, "downlink_only", _("Downlink only"));
    o.modalonly = true;
    o.datatype = "uinteger";
    o.placeholder = "5";

    o = s2.option(form.Flag, "stats_user_uplink", _("Stats user uplink"));
    o.modalonly = true;

    o = s2.option(form.Flag, "stats_user_downlink", _("Stats user downlink"));
    o.modalonly = true;

    o = s2.option(form.Value, "buffer_size", _("Buffer size"));
    o.datatype = "uinteger";

    return m.render();
  },
});
