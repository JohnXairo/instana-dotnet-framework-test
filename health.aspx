<%@ Page Language="C#" AutoEventWireup="true" CodeFile="health.aspx.cs" Inherits="InstanaTestApp.HealthPage" %>
<!DOCTYPE html>
<html>
<head><meta charset="utf-8" /><title>Health</title></head>
<body>
  <h2>Health OK</h2>
  <p>Timestamp: <asp:Label ID="lblTime" runat="server" /></p>
  <p>Este request genera un <strong>span entrante</strong> en Instana.</p>
  <p><a href="Default.aspx">&larr; Volver</a></p>
</body>
</html>
