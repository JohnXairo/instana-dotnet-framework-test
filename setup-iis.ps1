<#
.SYNOPSIS
    Configura IIS para la app de prueba Instana en .NET Framework 4.8.
    Crea el site, el App Pool con CLR v4.0 y setea las variables de entorno
    del CLR Profiler de Instana directamente en el App Pool.

.DESCRIPTION
    Emula el ambiente del cliente:
      - Windows Server 2012 R2 / IIS 8.5
      - .NET Framework 4.8 / CLR v4.0
      - App Pool en modo integrado

    IMPORTANTE:
      Para .NET Framework (CLR v4.0) las variables son COR_* (NO CORECLR_*).
      CORECLR_* es para .NET Core / .NET 5+.

.PARAMETER AppPath
    Ruta fisica de los archivos de la app. Default: C:\inetpub\instana-test

.PARAMETER Port
    Puerto del sitio IIS. Default: 8099

.PARAMETER AgentHost
    Host del agente Instana. Default: 127.0.0.1

.PARAMETER AgentPort
    Puerto del agente Instana. Default: 42699

.PARAMETER ProfilerPath
    Ruta a la DLL del CLR Profiler de Instana.
    Default: C:\Program Files\Instana\instana-agent\profiler\x64\Instana.Profiler.dll

.EXAMPLE
    # Configuracion basica (agente local)
    .\setup-iis.ps1

.EXAMPLE
    # Agente en otro host
    .\setup-iis.ps1 -AgentHost "192.168.1.50" -AgentPort 42699
#>
[CmdletBinding()]
param(
    [string] $AppPath      = "C:\inetpub\instana-test",
    [int]    $Port         = 8099,
    [string] $AgentHost    = "127.0.0.1",
    [int]    $AgentPort    = 42699,
    [string] $ProfilerPath = "C:\Program Files\Instana\instana-agent\profiler\x64\Instana.Profiler.dll"
)

#Requires -RunAsAdministrator
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Import-Module WebAdministration -ErrorAction Stop

$PoolName = "InstanaTest"
$SiteName = "InstanaTest"

Write-Host "=== Instana Test App - Setup IIS ===" -ForegroundColor Cyan
Write-Host ""

# -- 1. Crear App Pool -------------------------------------------------------
if (Test-Path "IIS:\AppPools\$PoolName") {
    Write-Host "[INFO] App Pool '$PoolName' ya existe - se actualizara." -ForegroundColor Yellow
} else {
    New-WebAppPool -Name $PoolName | Out-Null
    Write-Host "[OK]   App Pool '$PoolName' creado." -ForegroundColor Green
}

# CLR v4.0 + modo integrado (igual que el cliente real)
Set-ItemProperty "IIS:\AppPools\$PoolName" -Name managedRuntimeVersion -Value "v4.0"
Set-ItemProperty "IIS:\AppPools\$PoolName" -Name managedPipelineMode   -Value "Integrated"
Set-ItemProperty "IIS:\AppPools\$PoolName" -Name startMode             -Value "AlwaysRunning"
Write-Host "[OK]   App Pool configurado: CLR v4.0 / Integrated / AlwaysRunning" -ForegroundColor Green

# -- 2. Variables de entorno del CLR Profiler de Instana ---------------------
# CRITICO: Para .NET Framework se usan COR_* (no CORECLR_*)
$envVars = @{
    "COR_ENABLE_PROFILING" = "1"
    "COR_PROFILER"         = "{CF0D821E-299B-5307-A3D8-B283C03916DD}"
    "COR_PROFILER_PATH"    = $ProfilerPath
    "INSTANA_AGENT_HOST"   = $AgentHost
    "INSTANA_AGENT_PORT"   = $AgentPort.ToString()
}

$appcmd = "$env:windir\system32\inetsrv\appcmd.exe"

foreach ($kv in $envVars.GetEnumerator()) {
    # Limpiar entrada previa si existe (evita duplicados)
    & $appcmd set config "/section:system.applicationHost/applicationPools" `
        "/-[name='$PoolName'].environmentVariables.[name='$($kv.Key)']" `
        /commit:apphost 2>$null | Out-Null

    # Agregar la variable
    & $appcmd set config "/section:system.applicationHost/applicationPools" `
        "/+[name='$PoolName'].environmentVariables.[name='$($kv.Key)',value='$($kv.Value)']" `
        /commit:apphost | Out-Null

    Write-Host "[OK]   $($kv.Key) = $($kv.Value)" -ForegroundColor Green
}

# -- 3. Crear directorio fisico ----------------------------------------------
if (!(Test-Path $AppPath)) {
    New-Item -ItemType Directory -Path $AppPath -Force | Out-Null
    Write-Host "[OK]   Directorio creado: $AppPath" -ForegroundColor Green
} else {
    Write-Host "[INFO] Directorio ya existe: $AppPath" -ForegroundColor Yellow
}

# Copiar archivos de la app al directorio fisico (excluir scripts y docs)
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Copy-Item -Path "$scriptDir\*" -Destination $AppPath -Recurse -Force `
    -Exclude "*.ps1","*.md","*.csproj",".gitignore","docs"
Write-Host "[OK]   Archivos copiados a $AppPath" -ForegroundColor Green

# -- 4. Crear Site IIS -------------------------------------------------------
if (Get-Website -Name $SiteName -ErrorAction SilentlyContinue) {
    Write-Host "[INFO] Site '$SiteName' ya existe - se actualizara." -ForegroundColor Yellow
    Set-ItemProperty "IIS:\Sites\$SiteName" -Name physicalPath    -Value $AppPath
    Set-ItemProperty "IIS:\Sites\$SiteName" -Name applicationPool -Value $PoolName
} else {
    New-Website -Name $SiteName `
                -PhysicalPath $AppPath `
                -ApplicationPool $PoolName `
                -Port $Port `
                -Force | Out-Null
    Write-Host "[OK]   Site '$SiteName' creado en puerto $Port." -ForegroundColor Green
}

# -- 5. Verificar DLL del profiler -------------------------------------------
Write-Host ""
Write-Host "=== Verificaciones ==" -ForegroundColor Cyan

if (Test-Path $ProfilerPath) {
    Write-Host "[OK]   Profiler DLL encontrada: $ProfilerPath" -ForegroundColor Green
} else {
    Write-Host "[WARN] Profiler DLL NO encontrada: $ProfilerPath" -ForegroundColor Red
    Write-Host "       Instala el agente Instana y verifica la ruta." -ForegroundColor Red
}

# -- 6. Verificar conectividad con el agente ---------------------------------
$conn = Test-NetConnection -ComputerName $AgentHost -Port $AgentPort -WarningAction SilentlyContinue
if ($conn.TcpTestSucceeded) {
    Write-Host "[OK]   Agente Instana accesible en ${AgentHost}:${AgentPort}" -ForegroundColor Green
} else {
    Write-Host "[WARN] No se puede conectar al agente en ${AgentHost}:${AgentPort}" -ForegroundColor Red
    Write-Host "       Verifica que el agente Instana este corriendo." -ForegroundColor Red
}

# -- 7. Reciclar App Pool ----------------------------------------------------
Write-Host ""
Write-Host "Reciclando App Pool para que tome las nuevas variables..." -ForegroundColor Cyan
Restart-WebAppPool -Name $PoolName
Write-Host "[OK]   App Pool reciclado." -ForegroundColor Green

Write-Host ""
Write-Host "=== Listo ==" -ForegroundColor Cyan
Write-Host "Abre en el navegador: http://localhost:$Port/" -ForegroundColor White
Write-Host ""
Write-Host "Diagnostico rapido si no ves trazas en Instana:" -ForegroundColor Yellow
Write-Host "  1. La tabla en Default.aspx muestra si las variables estan activas en el proceso." -ForegroundColor Yellow
Write-Host "  2. Revisa los logs del agente en: C:\ProgramData\Instana\logs" -ForegroundColor Yellow
Write-Host "  3. Para CLR v4.0 (.NET Framework) se usan COR_* (no CORECLR_*)." -ForegroundColor Yellow
Write-Host "  4. El App Pool debe reciclarse DESPUES de setear las variables." -ForegroundColor Yellow
