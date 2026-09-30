<%@ Page Language="C#" AutoEventWireup="true" CodeFile="call.aspx.cs" Inherits="InstanaTestApp.CallPage" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8" />
  <title>HTTP Call</title>
  <style>
    body { font-family: Segoe UI, sans-serif; max-width: 800px; margin: 40px auto; }
    pre  { background: #f7f8fa; border: 1px solid #e5e7eb; padding: 12px; font-size: 12px; }
    .ok  { color: green; } .err { color: red; }
  </style>
</head>
<body>
  <h2>Llamada HTTP saliente</h2>
  <p>URL destino: <strong><asp:Label ID="lblUrl"    runat="server" /></strong></p>
  <p>Resultado:   <strong><asp:Label ID="lblStatus" runat="server" /></strong></p>
  <h3>Respuesta:</h3>
  <pre><asp:Literal ID="litBody" runat="server" /></pre>
  <p><a href="Default.aspx">&larr; Volver</a></p>
</body>
</html>
