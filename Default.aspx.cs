using System;
using System.Collections.Generic;
using System.Configuration;
using System.Web.UI;

namespace InstanaTestApp
{
    public partial class DefaultPage : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            lblAppName.Text = ConfigurationManager.AppSettings["AppName"] ?? "InstanaTestApp";

            var rows = new List<object>
            {
                MakeRow(".NET Framework Version",
                    System.Runtime.InteropServices.RuntimeEnvironment.GetSystemVersion(), true),
                MakeRow("CLR Version",
                    Environment.Version.ToString(), true),
                MakeRow("OS",
                    Environment.OSVersion.ToString(), true),
                MakeRow("Machine",
                    Environment.MachineName, true),
                MakeRow("App Pool (APPL_MD_PATH)",
                    Environment.GetEnvironmentVariable("APPL_MD_PATH") ?? "(no disponible fuera de IIS)", true),
                // Variables criticas del agente Instana para CLR v4.0
                MakeRow("COR_ENABLE_PROFILING",
                    Environment.GetEnvironmentVariable("COR_ENABLE_PROFILING"),
                    Environment.GetEnvironmentVariable("COR_ENABLE_PROFILING") == "1"),
                MakeRow("COR_PROFILER",
                    Environment.GetEnvironmentVariable("COR_PROFILER"),
                    !string.IsNullOrEmpty(Environment.GetEnvironmentVariable("COR_PROFILER"))),
                MakeRow("COR_PROFILER_PATH",
                    Environment.GetEnvironmentVariable("COR_PROFILER_PATH"),
                    !string.IsNullOrEmpty(Environment.GetEnvironmentVariable("COR_PROFILER_PATH"))),
                MakeRow("INSTANA_AGENT_HOST",
                    Environment.GetEnvironmentVariable("INSTANA_AGENT_HOST"),
                    !string.IsNullOrEmpty(Environment.GetEnvironmentVariable("INSTANA_AGENT_HOST"))),
                MakeRow("INSTANA_AGENT_PORT",
                    Environment.GetEnvironmentVariable("INSTANA_AGENT_PORT"),
                    !string.IsNullOrEmpty(Environment.GetEnvironmentVariable("INSTANA_AGENT_PORT"))),
            };

            rptEnv.DataSource = rows;
            rptEnv.DataBind();
        }

        private static object MakeRow(string key, string value, bool ok)
        {
            bool missing = string.IsNullOrEmpty(value);
            return new
            {
                Key    = key,
                Value  = missing ? "(no configurada)" : value,
                Css    = ok && !missing ? "ok" : (missing ? "err" : "warn"),
                Status = ok && !missing ? "OK"  : (missing ? "FALTA" : "REVISAR")
            };
        }
    }
}
