using System;
using System.Configuration;
using System.Net.Http;
using System.Web.UI;

namespace InstanaTestApp
{
    public class CallPage : Page
    {
        protected System.Web.UI.WebControls.Label   lblUrl;
        protected System.Web.UI.WebControls.Label   lblStatus;
        protected System.Web.UI.WebControls.Literal litBody;

        // HttpClient estatico: evita socket exhaustion
        private static readonly HttpClient _http = new HttpClient
        {
            Timeout = TimeSpan.FromSeconds(10)
        };

        protected void Page_Load(object sender, EventArgs e)
        {
            // Lanzar excepcion intencionada para generar span con error
            if (Request.QueryString["error"] == "1")
                throw new InvalidOperationException(
                    "Excepcion de prueba para Instana — span con error");

            var url = Request.QueryString["url"]
                   ?? ConfigurationManager.AppSettings["TargetUrl"]
                   ?? "http://httpbin.org/get";

            lblUrl.Text = url;

            try
            {
                // Esta llamada HttpClient genera un SPAN SALIENTE en Instana
                var response = _http.GetAsync(url).GetAwaiter().GetResult();
                var body     = response.Content.ReadAsStringAsync().GetAwaiter().GetResult();

                lblStatus.Text     = ((int)response.StatusCode) + " " + response.StatusCode;
                lblStatus.CssClass = response.IsSuccessStatusCode ? "ok" : "err";
                litBody.Text       = System.Web.HttpUtility.HtmlEncode(
                                        body.Length > 2000 ? body.Substring(0, 2000) + "..." : body);
            }
            catch (Exception ex)
            {
                lblStatus.Text     = "ERROR: " + ex.Message;
                lblStatus.CssClass = "err";
                litBody.Text       = System.Web.HttpUtility.HtmlEncode(ex.ToString());
            }
        }
    }
}
