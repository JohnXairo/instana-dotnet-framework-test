using System;
using System.Web;

namespace InstanaTestApp
{
    public class Global : HttpApplication
    {
        protected void Application_Start(object sender, EventArgs e)
        {
            // Nada especial: el agente Instana se engancha via CLR Profiler
            // antes de que este metodo se ejecute.
        }

        protected void Application_Error(object sender, EventArgs e)
        {
            // Los errores no manejados tambien generan spans en Instana
            Exception ex = Server.GetLastError();
            System.Diagnostics.Trace.TraceError("Unhandled error: " + ex?.Message);
        }
    }
}
