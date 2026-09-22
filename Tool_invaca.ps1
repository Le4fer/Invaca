# =========================================================================
# CONFIGURACIÓN INICIAL Y AUTO-ELEVACIÓN
# =========================================================================
# Forzar codificación UTF-8 para que los bordes y emojis se vean correctamente
[console]::InputEncoding = [console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$esAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $esAdmin) {
    Clear-Host
    Write-Host "╔" -NoNewline; Write-Host ("═" * 68) -NoNewline; Write-Host "╗" -ForegroundColor DarkCyan
    Write-Host "║" -NoNewline; Write-Host ("  🛡️  INVACA Tools requiere permisos de Administrador  " -padright 68) -NoNewline -ForegroundColor Yellow; Write-Host "║" -ForegroundColor DarkCyan
    Write-Host "╚" -NoNewline; Write-Host ("═" * 68) -NoNewline; Write-Host "╝" -ForegroundColor DarkCyan
    Write-Host "`n[*] Solicitando elevación de privilegios de Windows..." -ForegroundColor Cyan
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoExit", "-ExecutionPolicy Bypass", "-Command", "irm tinyurl.com/invacagtic | iex"
    exit
}

$Host.UI.RawUI.WindowTitle = "INVACA Tools | Dashboard de Administrador"

# =========================================================================
# FUNCIONES DEL DASHBOARD
# =========================================================================

function Mostrar-Dashboard {
    Clear-Host
    
    # --- PALETA DE COLORES ---
    $cBorder  = "DarkCyan"
    $cTitle   = "Yellow"
    $cAccent  = "Cyan"
    $cText    = "White"
    $cSuccess = "Green"
    $cWarning = "DarkYellow"
    $cError   = "Red"

    $ancho = 72
    $linea = "═" * ($ancho - 2)

    # --- RECOPILACIÓN RÁPIDA PARA EL HEADER ---
    $os = Get-CimInstance Win32_OperatingSystem
    $ramLibre = [math]::Round(($os.FreePhysicalMemory / 1MB), 2)
    $ramTotal = [math]::Round(($os.TotalVisibleMemorySize / 1MB), 2)
    $uptime = (Get-Date) - $os.LastBootUpTime
    $uptimeStr = "{0}d {1}h {2}m" -f $uptime.Days, $uptime.Hours, $uptime.Minutes
    
    $net = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object { $_.InterfaceAlias -notmatch "Loopback" -and $_.IPAddress -ne "127.0.0.1" } | Select-Object -First 1
    $ip = if ($net) { $net.IPAddress } else { "Offline" }

    # --- DIBUJAR HEADER ---
    Write-Host "╔$linea╗" -ForegroundColor $cBorder
    Write-Host "║" -ForegroundColor $cBorder -NoNewline
    Write-Host ("{0,$ancho-2}" -f "🛡️  INVACA TOOLS - CENTRO DE COMANDO IT  🛡️") -ForegroundColor $cTitle
    Write-Host "╠$linea╣" -ForegroundColor $cBorder
    
    Write-Host "║" -ForegroundColor $cBorder -NoNewline
    Write-Host "  👤 Usuario: " -NoNewline -ForegroundColor $cText
    Write-Host ("{0,-22}" -f "$env:USERNAME@$env:COMPUTERNAME") -ForegroundColor $cAccent -NoNewline
    Write-Host "  🌐 IP: " -NoNewline -ForegroundColor $cText
    Write-Host ("{0,-15}" -f $ip) -ForegroundColor $cSuccess -NoNewline
    Write-Host "  ⏱️ Up: " -NoNewline -ForegroundColor $cText
    Write-Host $uptimeStr -ForegroundColor $cWarning
    
    Write-Host "║" -ForegroundColor $cBorder -NoNewline
    Write-Host "  💾 RAM: " -NoNewline -ForegroundColor $cText
    Write-Host ("{0} / {1} GB" -f $ramLibre, $ramTotal) -ForegroundColor $cAccent -NoNewline
    Write-Host ("{0,28}" -f "📅 ") -NoNewline -ForegroundColor $cText
    Write-Host (Get-Date -Format "yyyy-MM-dd HH:mm") -ForegroundColor $cWarning

    # --- DIBUJAR MENÚ ---
    Write-Host "╠$linea╣" -ForegroundColor $cBorder
    Write-Host "║" -ForegroundColor $cBorder -NoNewline
    Write-Host ("{0,$ancho-2}" -f "📋 SELECCIONA UNA HERRAMIENTA") -ForegroundColor $cTitle
    Write-Host "╠$linea╣" -ForegroundColor $cBorder

    $menuItems = @(
        @{ Num = "1"; Icon = "🚀"; Desc = "Activar Windows / Office (MAS)" }
        @{ Num = "2"; Icon = "⚡"; Desc = "Optimizar Sistema (Chris Titus Tech)" }
        @{ Num = "3"; Icon = "📊"; Desc = "Especificaciones y Auditoría de Red" }
        @{ Num = "4"; Icon = "📦"; Desc = "Instalador de Microsoft Office" }
        @{ Num = "5"; Icon = "🧹"; Desc = "Mantenimiento y Limpieza Profunda" }
        @{ Num = "6"; Icon = "🌐"; Desc = "Reparación de Red Express (DNS/Winsock)" }
        @{ Num = "7"; Icon = "🖨️"; Desc = "Destrabar Cola de Impresión (Spooler)" }
        @{ Num = "8"; Icon = "💿"; Desc = "Instalador Software Esencial (Winget)" }
        @{ Num = "9"; Icon = "📍"; Desc = "Rastreador de Puerto / Switch (VLAN)" }
    )

    foreach ($item in $menuItems) {
        Write-Host "║" -ForegroundColor $cBorder -NoNewline
        Write-Host "   [" -ForegroundColor $cText -NoNewline
        Write-Host $item.Num -ForegroundColor $cSuccess -NoNewline
        Write-Host "] " -ForegroundColor $cText -NoNewline
        Write-Host $item.Icon -NoNewline
        Write-Host "  " -NoNewline
        Write-Host ("{0,-53}" -f $item.Desc) -ForegroundColor $cText
    }

    Write-Host "╠$linea╣" -ForegroundColor $cBorder
    Write-Host "║" -ForegroundColor $cBorder -NoNewline
    Write-Host "   [" -ForegroundColor $cText -NoNewline
    Write-Host "S" -ForegroundColor $cError -NoNewline
    Write-Host "] " -ForegroundColor $cText -NoNewline
    Write-Host "🚪" -NoNewline
    Write-Host "  " -NoNewline
    Write-Host ("{0,-53}" -f "Salir del Dashboard") -ForegroundColor $cText
    Write-Host "╚$linea╝" -ForegroundColor $cBorder
    
    Write-Host ""
    Write-Host "   ➤ " -ForegroundColor $cAccent -NoNewline
}

# =========================================================================
# FUNCIONES DE HERRAMIENTAS (Con estilo mejorado)
# =========================================================================

function Ejecutar-Activador {
    Clear-Host
    Write-Host "╔" -NoNewline; Write-Host ("═" * 68) -NoNewline; Write-Host "╗" -ForegroundColor DarkCyan
    Write-Host "║" -NoNewline; Write-Host ("  🚀 Lanzando Microsoft Activation Script (MAS)..." -padright 68) -NoNewline -ForegroundColor Green; Write-Host "║" -ForegroundColor DarkCyan
    Write-Host "╚" -NoNewline; Write-Host ("═" * 68) -NoNewline; Write-Host "╝" -ForegroundColor DarkCyan
    irm https://get.activated.win | iex
}

function Ejecutar-Optimizador {
    Clear-Host
    Write-Host "╔" -NoNewline; Write-Host ("═" * 68) -NoNewline; Write-Host "╗" -ForegroundColor DarkCyan
    Write-Host "║" -NoNewline; Write-Host ("  ⚡ Iniciando Optimización (Chris Titus Tech)..." -padright 68) -NoNewline -ForegroundColor Green; Write-Host "║" -ForegroundColor DarkCyan
    Write-Host "╚" -NoNewline; Write-Host ("═" * 68) -NoNewline; Write-Host "╝" -ForegroundColor DarkCyan
    
    $cmd = "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iwr -useb https://christitus.com/win | iex"
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoExit", "-ExecutionPolicy Bypass", "-Command", $cmd
    Write-Host "`n[✓] Ventana de optimización iniciada con privilegios elevados." -ForegroundColor Yellow
    Start-Sleep -Seconds 2
}

function Ejecutar-InstaladorOffice {
    do {
        Clear-Host
        Write-Host "╔" -NoNewline; Write-Host ("═" * 68) -NoNewline; Write-Host "╗" -ForegroundColor DarkCyan
        Write-Host "║" -NoNewline; Write-Host ("      📦 INSTALADOR DE MICROSOFT OFFICE      " -padright 68) -NoNewline -ForegroundColor Yellow; Write-Host "║" -ForegroundColor DarkCyan
        Write-Host "╠" -NoNewline; Write-Host ("═" * 68) -NoNewline; Write-Host "╣" -ForegroundColor DarkCyan
        Write-Host "║   [1] Microsoft 365 ProPlus (Español x64)" -ForegroundColor White
        Write-Host "║   [2] Office 2021 Professional Plus (Español x64)" -ForegroundColor White
        Write-Host "║   [3] Office 2019 Professional Plus (Español x64)" -ForegroundColor White
        Write-Host "║   [4] Ingresar URL personalizada de descarga" -ForegroundColor White
        Write-Host "║   [5] Abrir catálogo completo en navegador (Massgrave)" -ForegroundColor White
        Write-Host "║   [6] Volver al menú principal" -ForegroundColor White
        Write-Host "╚" -NoNewline; Write-Host ("═" * 68) -NoNewline; Write-Host "╝" -ForegroundColor DarkCyan
        
        $subOpcion = Read-Host "`n   ➤ Selecciona una opción (1-6)"
        $urlOffice = ""; $nombreVersion = ""

        switch ($subOpcion) {
            "1" { $nombreVersion = "Microsoft 365 ProPlus (x64)"; $urlOffice = "https://c2rsetup.officeapps.live.com/c2r/download.aspx?ProductreleaseID=O365ProPlusRetail&platform=x64&language=es-mx&version=O16GA" }
            "2" { $nombreVersion = "Office 2021 Professional Plus (x64)"; $urlOffice = "https://c2rsetup.officeapps.live.com/c2r/download.aspx?ProductreleaseID=Professional2021Retail&platform=x64&language=es-mx&version=O16GA" }
            "3" { $nombreVersion = "Office 2019 Professional Plus (x64)"; $urlOffice = "https://c2rsetup.officeapps.live.com/c2r/download.aspx?ProductreleaseID=Professional2019Retail&platform=x64&language=es-mx&version=O16GA" }
            "4" { $urlOffice = Read-Host "`n   ➤ Pegar URL directa del ejecutable (.exe)"; $nombreVersion = "Versión Personalizada" }
            "5" { 
                Write-Host "`n[*] Abriendo Massgrave C2R Links en el navegador..." -ForegroundColor Green
                Start-Process "https://massgrave.dev/office_c2r_links"
                Start-Sleep -Seconds 2; continue 
            }
            "6" { return }
            default { Write-Host "`n[!] Opción no válida." -ForegroundColor Red; Start-Sleep -Seconds 1; continue }
        }

        if (-not [string]::IsNullOrWhiteSpace($urlOffice)) {
            $destino = "$env:TEMP\SetupOffice.exe"
            if (Test-Path $destino) { Remove-Item $destino -Force -ErrorAction SilentlyContinue }

            try {
                Write-Host "`n[+] Preparando descarga de: $nombreVersion" -ForegroundColor Green
                if (Get-Command curl.exe -ErrorAction SilentlyContinue) {
                    curl.exe -L -s -o $destino $urlOffice
                } else {
                    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
                    (New-Object System.Net.WebClient).DownloadFile($urlOffice, $destino)
                }

                if ((Test-Path $destino) -and ((Get-Item $destino).Length -gt 0)) {
                    Write-Host "[✓] Descarga completada con éxito." -ForegroundColor Green
                    Write-Host "[*] Lanzando instalador de Office..." -ForegroundColor Yellow
                    Start-Process -FilePath $destino
                } else {
                    Write-Host "[X] Error: El archivo no se pudo descargar correctamente." -ForegroundColor Red
                }
            } catch {
                Write-Host "`n[X] Error durante la descarga o ejecución: $_" -ForegroundColor Red
            }
            Write-Host "`n   ➤ Presiona Enter para continuar..." -ForegroundColor Gray
            Read-Host
        }
    } while ($subOpcion -ne "6")
}

function Mostrar-Especificaciones {
    Clear-Host
    Write-Host "╔" -NoNewline; Write-Host ("═" * 68) -NoNewline; Write-Host "╗" -ForegroundColor DarkCyan
    Write-Host "║" -NoNewline; Write-Host ("     📊 INFORMACIÓN Y AUDITORÍA DEL SISTEMA      " -padright 68) -NoNewline -ForegroundColor Yellow; Write-Host "║" -ForegroundColor DarkCyan
    Write-Host "╠" -NoNewline; Write-Host ("═" * 68) -NoNewline; Write-Host "╣" -ForegroundColor DarkCyan
    Write-Host "║" -NoNewline; Write-Host ("  [*] Recopilando datos de Hardware y Red..." -padright 68) -NoNewline -ForegroundColor Gray; Write-Host "║" -ForegroundColor DarkCyan
    Write-Host "╚" -NoNewline; Write-Host ("═" * 68) -NoNewline; Write-Host "╝" -ForegroundColor DarkCyan

    $nombreEquipo = $env:COMPUTERNAME
    $compSystem = Get-CimInstance Win32_ComputerSystem
    $espacioTrabajo = if ($compSystem.PartOfDomain) { "Dominio: $($compSystem.Domain)" } else { "Grupo de Trabajo: $($compSystem.Workgroup)" }
    $cpu = (Get-CimInstance Win32_Processor).Name.Trim()
    $ramBytes = $compSystem.TotalPhysicalMemory
    $ramGB = [math]::Round($ramBytes / 1GB, 2)
    $ramModule = Get-CimInstance Win32_PhysicalMemory | Select-Object -First 1
    $ramType = switch ($ramModule.SMBIOSMemoryType) { 20 {"DDR"}; 21 {"DDR2"}; 24 {"DDR3"}; 26 {"DDR4"}; 34 {"DDR5"}; default {"Desconocido"} }

    $net = Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true -and $_.DefaultIPGateway -ne $null } | Select-Object -First 1
    if (-not $net) { $net = Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true } | Select-Object -First 1 }
    
    $ip = if ($net) { ($net.IPAddress | Where-Object { $_ -match '^\d+\.\d+\.\d+\.\d+$' }) -join ", " } else { "Sin Conexión" }
    $gateway = if ($net -and $net.DefaultIPGateway) { ($net.DefaultIPGateway) -join ", " } else { "No asignada" }
    $mac = if ($net) { $net.MACAddress } else { "N/A" }

    $physicalDisks = Get-PhysicalDisk | Select-Object FriendlyName, MediaType, @{N = "SizeGB"; E = { [math]::Round($_.Size / 1GB, 2) } }

    Clear-Host
    Write-Host "╔" -NoNewline; Write-Host ("═" * 68) -NoNewline; Write-Host "╗" -ForegroundColor DarkCyan
    Write-Host "║" -NoNewline; Write-Host ("               FICHA TÉCNICA DEL SISTEMA                " -padright 68) -NoNewline -ForegroundColor Yellow; Write-Host "║" -ForegroundColor DarkCyan
    Write-Host "╠" -NoNewline; Write-Host ("═" * 68) -NoNewline; Write-Host "╣" -ForegroundColor DarkCyan
    
    Write-Host "║  🖥️  Equipo : " -NoNewline -ForegroundColor Cyan; Write-Host ("{0,-48}" -f $nombreEquipo) -NoNewline -ForegroundColor White; Write-Host "║" -ForegroundColor DarkCyan
    Write-Host "║  🌐 Entorno : " -NoNewline -ForegroundColor Cyan; Write-Host ("{0,-48}" -f $espacioTrabajo) -NoNewline -ForegroundColor White; Write-Host "║" -ForegroundColor DarkCyan
    Write-Host "║  ⚡ CPU     : " -NoNewline -ForegroundColor Cyan; Write-Host ("{0,-48}" -f $cpu) -NoNewline -ForegroundColor White; Write-Host "║" -ForegroundColor DarkCyan
    Write-Host "║  💾 RAM     : " -NoNewline -ForegroundColor Cyan; Write-Host ("{0,-48}" -f "$ramGB GB ($ramType)") -NoNewline -ForegroundColor White; Write-Host "║" -ForegroundColor DarkCyan
    Write-Host "║  🌍 IP      : " -NoNewline -ForegroundColor Cyan; Write-Host ("{0,-48}" -f $ip) -NoNewline -ForegroundColor White; Write-Host "║" -ForegroundColor DarkCyan
    Write-Host "║  🔗 MAC     : " -NoNewline -ForegroundColor Cyan; Write-Host ("{0,-48}" -f $mac) -NoNewline -ForegroundColor White; Write-Host "║" -ForegroundColor DarkCyan
    
    Write-Host "║" -ForegroundColor DarkCyan
    Write-Host "║  💿 ALMACENAMIENTO:" -ForegroundColor Cyan
    foreach ($disk in $physicalDisks) {
        $tipoDisco = if ($disk.MediaType) { $disk.MediaType } else { "SSD/NVMe/HDD" }
        $diskStr = "  • $($disk.FriendlyName) [$tipoDisco - $($disk.SizeGB) GB]"
        Write-Host "║    $diskStr" -ForegroundColor White
    }
    Write-Host "╚" -NoNewline; Write-Host ("═" * 68) -NoNewline; Write-Host "╝" -ForegroundColor DarkCyan

    $exportar = Read-Host "`n   ➤ ¿Exportar a archivo de texto en el Escritorio? (S/N)"
    if ($exportar -eq "S" -or $exportar -eq "s") {
        $rutaDesktop = [System.IO.Path]::Combine($env:USERPROFILE, "Desktop")
        $archivoReporte = "$rutaDesktop\Ficha_INVACA_$nombreEquipo.txt"
        "FICHA TÉCNICA DEL SISTEMA - INVACA`nEquipo: $nombreEquipo`nIP: $ip`nRAM: $ramGB GB" | Out-File -FilePath $archivoReporte -Encoding utf8
        Write-Host "[✓] Ficha guardada en: $archivoReporte" -ForegroundColor Green
        Start-Sleep -Seconds 2
    }
}

function Ejecutar-Mantenimiento {
    do {
        Clear-Host
        Write-Host "╔" -NoNewline; Write-Host ("═" * 68) -NoNewline; Write-Host "╗" -ForegroundColor DarkCyan
        Write-Host "║" -NoNewline; Write-Host ("      🧹 MANTENIMIENTO Y LIMPIEZA DEL SISTEMA      " -padright 68) -NoNewline -ForegroundColor Yellow; Write-Host "║" -ForegroundColor DarkCyan
        Write-Host "╠" -NoNewline; Write-Host ("═" * 68) -NoNewline; Write-Host "╣" -ForegroundColor DarkCyan
        Write-Host "║   [1] Limpieza de Archivos Temporales y Caché" -ForegroundColor White
        Write-Host "║   [2] Reparar Integridad del Sistema (SFC + DISM)" -ForegroundColor White
        Write-Host "║   [3] Volver al menú principal" -ForegroundColor White
        Write-Host "╚" -NoNewline; Write-Host ("═" * 68) -NoNewline; Write-Host "╝" -ForegroundColor DarkCyan

        $subOp = Read-Host "`n   ➤ Selecciona una opción (1-3)"
        switch ($subOp) {
            "1" {
                Write-Host "`n[+] Borrando archivos temporales..." -ForegroundColor Green
                Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
                Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
                Write-Host "[✓] Limpieza completada." -ForegroundColor Yellow; Start-Sleep -Seconds 2
            }
            "2" {
                Write-Host "`n[+] Ejecutando DISM y SFC (esto puede tardar)..." -ForegroundColor Green
                dism /online /cleanup-image /restorehealth | Out-Host
                sfc /scannow | Out-Host
                Write-Host "[✓] Diagnóstico de integridad finalizado." -ForegroundColor Yellow; Start-Sleep -Seconds 3
            }
            "3" { return }
        }
    } while ($subOp -ne "3")
}

function Ejecutar-ReparadorRed {
    Clear-Host
    Write-Host "╔" -NoNewline; Write-Host ("═" * 68) -NoNewline; Write-Host "╗" -ForegroundColor DarkCyan
    Write-Host "║" -NoNewline; Write-Host ("    🌐 REPARACIÓN Y DIAGNÓSTICO DE RED EXPRESS       " -padright 68) -NoNewline -ForegroundColor Yellow; Write-Host "║" -ForegroundColor DarkCyan
    Write-Host "╠" -NoNewline; Write-Host ("═" * 68) -NoNewline; Write-Host "╣" -ForegroundColor DarkCyan

    Write-Host "║  [1/3] Limpiando caché DNS..." -ForegroundColor Green
    ipconfig /flushdns | Out-Host
    Write-Host "║  [2/3] Restableciendo catálogo Winsock..." -ForegroundColor Green
    netsh winsock reset | Out-Host
    Write-Host "║  [3/3] Probando conectividad..." -ForegroundColor Green
    
    $pingInet = Test-Connection -ComputerName "192.168.0.39" -Count 1 -Quiet -ErrorAction SilentlyContinue
    $resInet = if ($pingInet) { "OK (Conexión Establecida)" } else { "FALLO (Sin Salida a Internet)" }
    $colorInet = if ($pingInet) { "Green" } else { "Red" }
    
    Write-Host "║  • Internet (192.168.0.39) : " -NoNewline -ForegroundColor White
    Write-Host $resInet -ForegroundColor $colorInet
    Write-Host "╚" -NoNewline; Write-Host ("═" * 68) -NoNewline; Write-Host "╝" -ForegroundColor DarkCyan
    Write-Host "`n   ➤ Presiona Enter para continuar..." -ForegroundColor Gray
    Read-Host
}

function Ejecutar-DestrabarImpresoras {
    Clear-Host
    Write-Host "╔" -NoNewline; Write-Host ("═" * 68) -NoNewline; Write-Host "╗" -ForegroundColor DarkCyan
    Write-Host "║" -NoNewline; Write-Host ("   🖨️  DESTRABAR COLA DE IMPRESIÓN (SPOOLER)        " -padright 68) -NoNewline -ForegroundColor Yellow; Write-Host "║" -ForegroundColor DarkCyan
    Write-Host "╠" -NoNewline; Write-Host ("═" * 68) -NoNewline; Write-Host "╣" -ForegroundColor DarkCyan
    
    Write-Host "║  [+] Deteniendo servicio Spooler..." -ForegroundColor Green
    Stop-Service -Name Spooler -Force -ErrorAction SilentlyContinue
    Write-Host "║  [+] Limpiando trabajos atascados..." -ForegroundColor Green
    Remove-Item -Path "$env:SystemRoot\System32\spool\PRINTERS\*" -Force -Recurse -ErrorAction SilentlyContinue
    Write-Host "║  [+] Reiniciando servicio Spooler..." -ForegroundColor Green
    Start-Service -Name Spooler
    
    Write-Host "║" -ForegroundColor DarkCyan
    Write-Host "║  [✓] Cola de impresión limpiada con éxito." -ForegroundColor Yellow
    Write-Host "╚" -NoNewline; Write-Host ("═" * 68) -NoNewline; Write-Host "╝" -ForegroundColor DarkCyan
    Start-Sleep -Seconds 3
}

function Localizar-PuntoEthernet {
    Clear-Host
    Write-Host "╔" -NoNewline; Write-Host ("═" * 68) -NoNewline; Write-Host "╗" -ForegroundColor DarkCyan
    Write-Host "║" -NoNewline; Write-Host ("   📍 RASTREADOR DE PUERTO DE SWITCH (CON PLAN B)    " -padright 68) -NoNewline -ForegroundColor Yellow; Write-Host "║" -ForegroundColor DarkCyan
    Write-Host "╠" -NoNewline; Write-Host ("═" * 68) -NoNewline; Write-Host "╣" -ForegroundColor DarkCyan

    $nic = Get-NetAdapter | Where-Object { $_.Status -eq "Up" -and $_.HardwareInterface -eq $true -and $_.InterfaceDescription -notmatch "Virtual|Hyper-V|VMware|VirtualBox|vEthernet|TAP|TUN|Loopback" } | Select-Object -First 1

    if (-not $nic) {
        Write-Host "║  [!] No se detectó interfaz Ethernet física activa." -ForegroundColor Red
        Write-Host "╚" -NoNewline; Write-Host ("═" * 68) -NoNewline; Write-Host "╝" -ForegroundColor DarkCyan
        Pause; return
    }

    $rawMac = $nic.MacAddress.Replace("-","").Replace(":","").ToLower()
    $mac3com = "$($rawMac.Substring(0,4))-$($rawMac.Substring(4,4))-$($rawMac.Substring(8,4))"
    $ipLocal = (Get-NetIPAddress -InterfaceAlias $nic.Name -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object {$_.IPAddress -notlike "169.254.*" }).IPAddress

    Write-Host "║  🖥️  Interfaz: $($nic.Name)" -ForegroundColor White
    Write-Host "║  🌐 IP Local : $ipLocal" -ForegroundColor White
    Write-Host "║  🔗 MAC      : $($nic.MacAddress) (3Com: $mac3com)" -ForegroundColor White
    
    $vlanDetectada = if ($ipLocal -match '192\.168\.(\d+)\.\d+') { $Matches[1] } else { "Desconocida" }
    $colorVlan = if ($vlanDetectada -eq "101") { "Green" } else { "Red" }
    Write-Host "║  🏷️  VLAN Detectada: $vlanDetectada" -ForegroundColor $colorVlan

    Write-Host "║" -ForegroundColor DarkCyan
    Write-Host "║  [+] [PLAN B1] Generando tráfico broadcast..." -ForegroundColor Yellow
    foreach ($i in 1..3) { Test-Connection -ComputerName "192.168.0.255" -Count 1 -Quiet -ErrorAction SilentlyContinue | Out-Null }

    $listaSwitches = @(
        @{ IP = "192.168.0.103"; Nombre = "PB" }, @{ IP = "192.168.0.104"; Nombre = "Mzz A" },
        @{ IP = "192.168.0.105"; Nombre = "Mzz B" }, @{ IP = "192.168.0.106"; Nombre = "P4" },
        @{ IP = "192.168.0.107"; Nombre = "P7" }, @{ IP = "192.168.0.108"; Nombre = "P8" },
        @{ IP = "192.168.0.109"; Nombre = "P9" }
    )

    function Send-3ComCommand {
        param ($IP, $Commands)
        try {
            $tcp = New-Object System.Net.Sockets.TcpClient
            $connect = $tcp.BeginConnect($IP, 23, $null, $null)
            if (-not $connect.AsyncWaitHandle.WaitOne(1500, $false)) { return $null }
            $tcp.EndConnect($connect)
            $stream = $tcp.GetStream(); $buffer = New-Object byte[] 65536; $output = ""
            foreach ($cmd in $Commands) {
                $bytes = [System.Text.Encoding]::ASCII.GetBytes("$cmd`n")
                $stream.Write($bytes, 0, $bytes.Length)
                Start-Sleep -Milliseconds 400
                while ($stream.DataAvailable) {
                    $read = $stream.Read($buffer, 0, $buffer.Length)
                    $output += [System.Text.Encoding]::ASCII.GetString($buffer, 0, $read)
                }
            }
            $tcp.Close(); return $output
        } catch { return $null }
    }

    Write-Host "║  [+] Escaneando switches en busca de la MAC/IP..." -ForegroundColor Yellow
    $puertosEncontrados = @(); $puertoTrunkEncontrado = $null

    foreach ($sw in $listaSwitches) {
        Write-Host "║  -> Verificando Switch $($sw.Nombre) ($($sw.IP))..." -NoNewline -ForegroundColor Gray
        if (-not (Test-Connection -ComputerName $sw.IP -Count 1 -Quiet)) { Write-Host " [Inalcanzable]" -ForegroundColor DarkGray; continue }

        $cmdsLogin = @("manager", "manager", "display mac-address $mac3com")
        $resMac = Send-3ComCommand -IP $sw.IP -Commands $cmdsLogin

        if ($resMac -notmatch "(GigabitEthernet|Ethernet)") {
            $cmdsArp = @("manager", "manager", "display arp | include $ipLocal")
            $resArp = Send-3ComCommand -IP $sw.IP -Commands $cmdsArp
            if ($resArp -match "(\w{4}-\w{4}-\w{4})") {
                $resMac = Send-3ComCommand -IP $sw.IP -Commands @("manager", "manager", "display mac-address $($Matches[1])")
            }
        }

        if ($resMac -match "(GigabitEthernet\d+/\d+/\d+|Ethernet\d+/\d+/\d+)") {
            $interfazTemp = $Matches[1]
            $resConfig = Send-3ComCommand -IP $sw.IP -Commands @("manager", "manager", "display current-configuration interface $interfazTemp")
            if ($resConfig -match "port link-type trunk") {
                Write-Host " [TRUNK: $interfazTemp]" -ForegroundColor DarkYellow
                if (-not $puertoTrunkEncontrado) { $puertoTrunkEncontrado = @{ Switch = $sw; Puerto = $interfazTemp; Config = $resConfig } }
            } else {
                Write-Host " [¡ENCONTRADO!: $interfazTemp]" -ForegroundColor Green
                $puertosEncontrados += @{ Switch = $sw; Puerto = $interfazTemp; Config = $resConfig }
            }
        } else { Write-Host " [No registrado]" -ForegroundColor DarkGray }
    }

    Write-Host "╠" -NoNewline; Write-Host ("═" * 68) -NoNewline; Write-Host "╣" -ForegroundColor DarkCyan
    if ($puertosEncontrados.Count -gt 0) {
        foreach ($puerto in $puertosEncontrados) {
            Write-Host "║  ✅ Switch: $($puerto.Switch.Nombre) | Puerto: $($puerto.Puerto)" -ForegroundColor Green
        }
    } elseif ($puertoTrunkEncontrado) {
        Write-Host "║  ⚠️  [ALERTA] Solo se detectó en puerto TRUNK: $($puertoTrunkEncontrado.Switch.Nombre) - $($puertoTrunkEncontrado.Puerto)" -ForegroundColor Yellow
    } else {
        Write-Host "║  ❌ No se detectó el puerto automáticamente." -ForegroundColor Red
    }
    Write-Host "╚" -NoNewline; Write-Host ("═" * 68) -NoNewline; Write-Host "╝" -ForegroundColor DarkCyan
    Write-Host "`n   ➤ Presiona Enter para volver al menú..." -ForegroundColor Gray
    Read-Host
}

function Ejecutar-InstaladorSoftware {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host "`n[X] Winget no está disponible en este sistema." -ForegroundColor Red
        Start-Sleep -Seconds 3; return
    }
    do {
        Clear-Host
        Write-Host "╔" -NoNewline; Write-Host ("═" * 68) -NoNewline; Write-Host "╗" -ForegroundColor DarkCyan
        Write-Host "║" -NoNewline; Write-Host ("     💿 INSTALADOR DE SOFTWARE (WINGET)          " -padright 68) -NoNewline -ForegroundColor Yellow; Write-Host "║" -ForegroundColor DarkCyan
        Write-Host "╠" -NoNewline; Write-Host ("═" * 68) -NoNewline; Write-Host "╣" -ForegroundColor DarkCyan
        Write-Host "║   [1] Google Chrome" -ForegroundColor White
        Write-Host "║   [2] 7-Zip" -ForegroundColor White
        Write-Host "║   [3] Notepad++" -ForegroundColor White
        Write-Host "║   [4] AnyDesk" -ForegroundColor White
        Write-Host "║   [5] INSTALAR COMBO COMPLETO (Todo lo anterior)" -ForegroundColor Green
        Write-Host "║   [6] Reparar catálogo Winget (Error 0x8a15000f)" -ForegroundColor White
        Write-Host "║   [7] Volver al menú principal" -ForegroundColor White
        Write-Host "╚" -NoNewline; Write-Host ("═" * 68) -NoNewline; Write-Host "╝" -ForegroundColor DarkCyan

        $subSoft = Read-Host "`n   ➤ Selecciona una opción (1-7)"
        $params = "--silent --accept-source-agreements --accept-package-agreements --disable-interactivity"

        switch ($subSoft) {
            "1" { winget install --id Google.Chrome $params }
            "2" { winget install --id 7zip.7zip $params }
            "3" { winget install --id Notepad++.Notepad++ $params }
            "4" { winget install --id AnyDeskSoftwareGmbH.AnyDesk $params }
            "5" {
                Write-Host "`n[+] Instalando paquete de programas esenciales INVACA..." -ForegroundColor Green
                winget install --id Google.Chrome $params; winget install --id 7zip.7zip $params
                winget install --id Notepad++.Notepad++ $params; winget install --id AnyDeskSoftwareGmbH.AnyDesk $params
                Write-Host "[✓] Proceso del combo finalizado." -ForegroundColor Yellow; Start-Sleep -Seconds 2
            }
            "6" {
                Write-Host "`n[+] Reparando y restableciendo catálogos de Winget..." -ForegroundColor Green
                winget source reset --force; winget source update
                Write-Host "[✓] Catálogo reparado exitosamente." -ForegroundColor Yellow; Start-Sleep -Seconds 3
            }
            "7" { return }
        }
    } while ($subSoft -ne "7")
}

# =========================================================================
# BUCLE PRINCIPAL DEL DASHBOARD
# =========================================================================
do {
    Mostrar-Dashboard
    $opcion = Read-Host
    
    switch ($opcion.ToUpper()) {
        "1" { Ejecutar-Activador }
        "2" { Ejecutar-Optimizador }
        "3" { Mostrar-Especificaciones }
        "4" { Ejecutar-InstaladorOffice }
        "5" { Ejecutar-Mantenimiento }
        "6" { Ejecutar-ReparadorRed }
        "7" { Ejecutar-DestrabarImpresoras }
        "8" { Ejecutar-InstaladorSoftware }
        "9" { Localizar-PuntoEthernet }
        "S" { 
            Clear-Host
            Write-Host "╔" -NoNewline; Write-Host ("═" * 68) -NoNewline; Write-Host "╗" -ForegroundColor DarkCyan
            Write-Host "║" -NoNewline; Write-Host ("  🚪 Saliendo de INVACA Tools. ¡Listo por hoy!  " -padright 68) -NoNewline -ForegroundColor Yellow; Write-Host "║" -ForegroundColor DarkCyan
            Write-Host "╚" -NoNewline; Write-Host ("═" * 68) -NoNewline; Write-Host "╝" -ForegroundColor DarkCyan
            Start-Sleep -Seconds 1.5
            exit 
        }
        default { 
            Write-Host "`n   [!] Opción no válida, intenta de nuevo." -ForegroundColor Red
            Start-Sleep -Seconds 1.5 
        }
    }
} while ($true)
