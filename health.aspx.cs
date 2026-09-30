using System;
using System.Web.UI;

namespace InstanaTestApp
{
    public class HealthPage : Page
    {
        protected System.Web.UI.WebControls.Label lblTime;

        protected void Page_Load(object sender, EventArgs e)
        {
            lblTime.Text = DateTime.UtcNow.ToString("o");
            Response.StatusCode = 200;
        }
    }
}
