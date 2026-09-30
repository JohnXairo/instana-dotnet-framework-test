# Variables de entorno — Agente Instana para .NET CLR

## Diferencia clave: CLR v4.0 vs .NET Core

| Variable | .NET Framework (CLR v4.0) | .NET Core / .NET 5+ |
|---|---|---|
| Habilitar profiler | `COR_ENABLE_PROFILING=1` | `CORECLR_ENABLE_PROFILING=1` |
| GUID del profiler  | `COR_PROFILER={...}` | `CORECLR_PROFILER={...}` |
| Ruta DLL profiler  | `COR_PROFILER_PATH=...` | `CORECLR_PROFILER_PATH=...` |

> **Este ambiente de prueba usa CLR v4.0 (.NET Framework 4.8) -> usar `COR_*`.**  
> Usar `CORECLR_*` aqui no tiene efecto.

---

## Variables requeridas

### Para .NET Framework / CLR v4.0 (este ambiente)

```
COR_ENABLE_PROFILING  = 1
COR_PROFILER          = {CF0D821E-299B-5307-A3D8-B283C03916DD}
COR_PROFILER_PATH     = C:\Program Files\Instana\instana-agent\profiler\x64\Instana.Profiler.dll
INSTANA_AGENT_HOST    = <IP del host del agente Instana>
INSTANA_AGENT_PORT    = 42699
```

### Opcionales (mejoran el contexto en Instana UI)

```
INSTANA_SERVICE_NAME  = InstanaTestApp   # Nombre que aparece en Instana
INSTANA_ZONE          = zona-pruebas     # Zona de infraestructura
```

---

## Donde configurarlas en IIS

### Opcion A — Setup automatico (recomendado)
```powershell
.\setup-iis.ps1 -AgentHost "192.168.1.50"
```

### Opcion B — IIS Manager (UI)
1. IIS Manager -> Application Pools -> InstanaTest -> Advanced Settings
2. Environment Variables -> Add:
   - `COR_ENABLE_PROFILING` = `1`
   - `COR_PROFILER` = `{CF0D821E-299B-5307-A3D8-B283C03916DD}`
   - `COR_PROFILER_PATH` = ruta a la DLL
   - `INSTANA_AGENT_HOST` = IP del agente
   - `INSTANA_AGENT_PORT` = `42699`
3. Reciclar el App Pool.

### Opcion C — appcmd.exe (compatible WS2012R2)
```cmd
%windir%\system32\inetsrv\appcmd.exe set config ^
  "/section:system.applicationHost/applicationPools" ^
  "/+[name='InstanaTest'].environmentVariables.[name='COR_ENABLE_PROFILING',value='1']" ^
  /commit:apphost
```

---

## Checklist de diagnostico

- [ ] El agente Instana esta corriendo: `Test-NetConnection <host> -Port 42699`
- [ ] La DLL del profiler existe en la ruta configurada: `Test-Path <COR_PROFILER_PATH>`
- [ ] Las variables usan prefijo `COR_*` (no `CORECLR_*`) para CLR v4.0
- [ ] Las variables estan en el App Pool (no solo en variables de sistema/usuario)
- [ ] El App Pool fue reciclado **despues** de configurar las variables
- [ ] El App Pool corre como cuenta con acceso de lectura a la DLL del profiler
- [ ] El agente Instana tiene el sensor de .NET habilitado

---

## Error comun: variables a nivel de sistema vs App Pool

Configurar las variables en "Variables de entorno del sistema" de Windows
**no funciona** para procesos IIS porque los worker processes (`w3wp.exe`)
se inician con su propio contexto de entorno heredado del App Pool.

Las variables **deben estar en el App Pool**, no en el sistema operativo.
