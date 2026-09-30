# instana-dotnet-framework-test

App de prueba **ASP.NET Framework 4.8 / IIS 8.5** para emular la instrumentación nativa del agente Instana mediante el CLR Profiler de Windows.

Reproduce el ambiente del cliente:
- OS: Windows Server 2012 R2 Standard
- IIS: 8.5
- .NET Framework: 4.8
- App Pool CLR: v4.0 (modo integrado)

---

## Estructura

```
instana-dotnet-framework-test/
├── InstanaTestApp.csproj   # Proyecto MSBuild
├── web.config              # Config IIS + targetFramework 4.8
├── Global.asax / .cs       # Application lifecycle
├── Default.aspx / .cs      # Dashboard de estado del entorno
├── health.aspx / .cs       # Endpoint health (span entrante simple)
├── call.aspx / .cs         # HTTP saliente (genera span saliente)
├── setup-iis.ps1           # Script PowerShell: crea site, pool, vars Instana
└── docs/
    └── variables-instana.md  # Referencia de variables de entorno del agente
```

---

## Despliegue rápido

### 1. Prerequisitos
- Windows Server 2012 R2 o superior con IIS 8.5+ habilitado
- .NET Framework 4.8 instalado
- Agente Instana instalado (incluye el CLR Profiler en `%INSTANA_AGENT_HOME%`)

### 2. Publicar la app
```powershell
# Compilar con MSBuild
msbuild InstanaTestApp.csproj /p:Configuration=Release /p:DeployOnBuild=true /p:PublishUrl=C:\inetpub\instana-test
```

### 3. Configurar IIS y variables Instana
```powershell
# Ejecutar como Administrador
.\setup-iis.ps1 -AgentHost "127.0.0.1" -AgentPort 42699
```

### 4. Verificar
Abrir `http://localhost:8099/` — la tabla de estado muestra si las variables del profiler están presentes.

Hacer clic en los botones de prueba y buscar las trazas en **Instana UI > Applications**.

---

## Variables de entorno requeridas

| Variable | Valor | Nota |
|---|---|---|
| `COR_ENABLE_PROFILING` | `1` | Para CLR v4.0 (.NET Framework) |
| `COR_PROFILER` | `{CF0D821E-299B-5307-A3D8-B283C03916DD}` | GUID del profiler Instana |
| `COR_PROFILER_PATH` | `<agente>\profiler\x64\Instana.Profiler.dll` | Ruta a la DLL |
| `INSTANA_AGENT_HOST` | IP del host del agente | Default: `127.0.0.1` |
| `INSTANA_AGENT_PORT` | `42699` | Puerto default del agente |

> **Importante:** Para .NET Framework (CLR v4.0) se usan `COR_*` (sin CORE). Las variables `CORECLR_*` son para .NET Core / .NET 5+.

Ver [`docs/variables-instana.md`](docs/variables-instana.md) para referencia completa.
