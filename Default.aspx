<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="InstanaTestApp.DefaultPage" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8" />
  <title>Instana Test App - .NET Framework 4.8</title>
  <style>
    body  { font-family: Segoe UI, sans-serif; max-width: 860px; margin: 40px auto; color: #1f2328; }
    h1    { color: #c0392b; }
    h2    { border-bottom: 1px solid #e5e7eb; padding-bottom: 6px; }
    table { border-collapse: collapse; width: 100%; margin-top: 12px; }
    th, td{ border: 1px solid #ccc; padding: 7px 12px; text-align: left; font-size: 13px; }
    th    { background: #f0f0f0; }
    .ok   { color: green;  font-weight: bold; }
    .warn { color: #e67e22; font-weight: bold; }
    .err  { color: red;    font-weight: bold; }
    a.btn { display: inline-block; margin: 5px 4px; padding: 8px 16px;
            background: #0078d4; color: #fff; text-decoration: none;
            border-radius: 4px; font-size: 13px; }
    a.btn:hover { background: #005fa3; }
    a.btn.red   { background: #c0392b; }
    a.btn.red:hover { background: #962d22; }
    pre   { background: #f7f8fa; border: 1px solid #e5e7eb; padding: 12px; font-size: 12px; }
  </style>
</head>
<body>
  <h1>Instana Test App</h1>
  <p>Emulando: <strong>Windows Server 2012 R2 / IIS 8.5 / .NET Framework 4.8 / CLR v4.0</strong></p>

  <h2>Estado del entorno</h2>
  <table>
    <tr><th>Propiedad</th><th>Valor</th><th>Estado</th></tr>
    <asp:Repeater ID="rptEnv" runat="server">
      <ItemTemplate>
        <tr>
          <td><%# Eval("Key") %></td>
          <td><%# Eval("Value") %></td>
          <td class='<%# Eval("Css") %>'><%# Eval("Status") %></td>
        </tr>
      </ItemTemplate>
    </asp:Repeater>
  </table>

  <h2>Generar trazas</h2>
  <a class="btn" href="health.aspx">Health check (span entrante simple)</a>
  <a class="btn" href="call.aspx">HTTP saliente OK</a>
  <a class="btn" href="call.aspx?url=http://httpbin.org/delay/1">HTTP saliente con latencia</a>
  <a class="btn" href="call.aspx?url=http://httpbin.org/status/503">HTTP saliente con error 503</a>
  <a class="btn red" href="call.aspx?error=1">Lanzar excepcion (span con error)</a>

  <h2>Instrucciones</h2>
  <ol>
    <li>Revisa que todas las filas criticas de la tabla de arriba esten en verde.</li>
    <li>Haz clic en los botones para generar trazas.</li>
    <li>Busca la app <strong><asp:Label ID="lblAppName" runat="server" /></strong> en <em>Instana UI &rarr; Applications</em>.</li>
  </ol>

  <h2>Siguiente paso si no ves trazas</h2>
  <pre>1. Verificar que el agente Instana esta corriendo:
   Test-NetConnection -ComputerName &lt;INSTANA_AGENT_HOST&gt; -Port 42699

2. Reciclar el App Pool DESPUES de setear las variables:
   Restart-WebAppPool "InstanaTest"

3. Para .NET Framework (CLR v4.0) las variables correctas son COR_* (no CORECLR_*):
   COR_ENABLE_PROFILING  = 1
   COR_PROFILER          = {CF0D821E-299B-5307-A3D8-B283C03916DD}
   COR_PROFILER_PATH     = &lt;agente&gt;\profiler\x64\Instana.Profiler.dll

4. Ejecutar setup-iis.ps1 como Administrador para configurar todo automaticamente.</pre>
</body>
</html>
