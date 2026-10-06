# =========================================================================
# VALIDACIÓN DE PERMISOS Y AUTO-ELEVACIÓN
# =========================================================================

# 1. FORZAR TLS 1.2 ANTES DE CUALQUIER DESCARGA (Soluciona el error de la 1ra vez)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$esAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $esAdmin) {
    Write-Host "`n[!] INVACA Tools requiere permisos de Administrador." -ForegroundColor Yellow
    Write-Host "[*] Solicitando elevación de privilegios de Windows..." -ForegroundColor Cyan
    
    # 2. Usar la URL correcta y asegurar que la nueva ventana también use TLS 1.2
    $scriptUrl = "https://tinyurl.com/invacagtic"
    $command = "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; irm '$scriptUrl' -UseBasicParsing | iex"
    
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoExit", "-ExecutionPolicy", "Bypass", "-Command", $command
    exit
}

# Ajustar codificación para evitar problemas con caracteres especiales
$OutputEncoding = [System.Text.Encoding]::UTF8

function Mostrar-Menu {
    Clear-Host
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "             INVACA TOOLS                " -ForegroundColor Yellow
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "1. Activar Windows / Office (MAS)"
    Write-Host "2. Optimizar Sistema (Chris Titus Tech)"
    Write-Host "3. Especificaciones y Diagnóstico del Equipo"
    Write-Host "4. Instalar Microsoft Office"
    Write-Host "5. Mantenimiento y Limpieza del Sistema"
    Write-Host "6. Diagnóstico y Reparación de Red Express"
    Write-Host "7. Destrabar Cola de Impresión (Spooler)"
    Write-Host "8. Instalador de Software Esencial (Winget)"
    Write-Host "9. Localizar Punto Ethernet / Mapear Puerto de Switch"
    Write-Host "S. Salir"
    Write-Host "=========================================" -ForegroundColor Cyan
}

function Ejecutar-Activador {
    Write-Host "`n[+] Lanzando Microsoft Activation Script (MAS)..." -ForegroundColor Green
    irm https://get.activated.win | iex
}

function Ejecutar-Optimizador {
    Write-Host "`n[+] Lanzando Herramienta de Optimización (Chris Titus Tech)..." -ForegroundColor Green
    $cmd = "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iwr -useb https://christitus.com/win | iex"
    
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoExit", "-ExecutionPolicy Bypass", "-Command", $cmd
    Write-Host "[✓] Ventana de optimización iniciada con privilegios elevados." -ForegroundColor Yellow
    Start-Sleep -Seconds 2
}

function Ejecutar-InstaladorOffice {
    do {
        Clear-Host
        Write-Host "=========================================" -ForegroundColor Cyan
        Write-Host "      INSTALADOR DE MICROSOFT OFFICE     " -ForegroundColor Yellow
        Write-Host "=========================================" -ForegroundColor Cyan
        Write-Host "1. Microsoft 365 ProPlus (Español x64)"
        Write-Host "2. Office 2021 Professional Plus (Español x64)"
        Write-Host "3. Office 2019 Professional Plus (Español x64)"
        Write-Host "4. Ingresar URL personalizada de descarga"
        Write-Host "5. Abrir catálogo completo en el navegador (Massgrave)"
        Write-Host "6. Volver al menú principal"
        Write-Host "=========================================" -ForegroundColor Cyan
        
        $subOpcion = Read-Host "Selecciona una opción (1-6)"
        $urlOffice = ""
        $nombreVersion = ""

        switch ($subOpcion) {
            "1" {
                $nombreVersion = "Microsoft 365 ProPlus (x64)"
                $urlOffice = "https://c2rsetup.officeapps.live.com/c2r/download.aspx?ProductreleaseID=O365ProPlusRetail&platform=x64&language=es-mx&version=O16GA"
            }
            "2" {
                $nombreVersion = "Office 2021 Professional Plus (x64)"
                $urlOffice = "https://c2rsetup.officeapps.live.com/c2r/download.aspx?ProductreleaseID=Professional2021Retail&platform=x64&language=es-mx&version=O16GA"
            }
            "3" {
                $nombreVersion = "Office 2019 Professional Plus (x64)"
                $urlOffice = "https://c2rsetup.officeapps.live.com/c2r/download.aspx?ProductreleaseID=Professional2019Retail&platform=x64&language=es-mx&version=O16GA"
            }
            "4" {
                $urlOffice = Read-Host "`nPegar URL directa del ejecutable (.exe)"
                $nombreVersion = "Versión Personalizada"
            }
            "5" {
                Write-Host "`n[*] Abriendo Massgrave C2R Links en el navegador predeterminado..." -ForegroundColor Green
                Start-Process "https://massgrave.dev/office_c2r_links"
                Start-Sleep -Seconds 2
                continue
            }
            "6" { return }
            default {
                Write-Host "`nOpción no válida." -ForegroundColor Red
                Start-Sleep -Seconds 1
                continue
            }
        }

        if (-not [string]::IsNullOrWhiteSpace($urlOffice)) {
            $destino = "$env:TEMP\SetupOffice.exe"
            
            if (Test-Path $destino) {
                Remove-Item $destino -Force -ErrorAction SilentlyContinue
            }

            try {
                Write-Host "`n[+] Preparando descarga de: $nombreVersion" -ForegroundColor Green
                Write-Host "[*] Descargando desde servidores oficiales de Microsoft..." -ForegroundColor Gray
                
                if (Get-Command curl.exe -ErrorAction SilentlyContinue) {
                    curl.exe -L -s -o $destino $urlOffice
                }
                else {
                    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
                    (New-Object System.Net.WebClient).DownloadFile($urlOffice,$destino)
                }

                if ((Test-Path $destino) -and ((Get-Item $destino).Length -gt 0)) {
                    Write-Host "[✓] Descarga completada con éxito." -ForegroundColor Green
                    Write-Host "[*] Lanzando instalador de Office..." -ForegroundColor Yellow
                    Start-Process -FilePath $destino
                }
                else {
                    Write-Host "[X] Error: El archivo no se pudo descargar correctamente o fue bloqueado." -ForegroundColor Red
                }
            }
            catch {
                Write-Host "`n[X] Error durante la descarga o ejecución: $_" -ForegroundColor Red
            }

            Write-Host "`nPresiona Enter para continuar..." -ForegroundColor Gray
            Read-Host
        }

    } while ($subOpcion -ne "6")
}

function Mostrar-Especificaciones {
    Clear-Host
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "     INFORMACIÓN Y AUDITORÍA DE RED      " -ForegroundColor Yellow
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "[*] Recopilando datos de Hardware, Red y Periféricos..." -ForegroundColor Gray

    $nombreEquipo = $env:COMPUTERNAME
    $compSystem = Get-CimInstance Win32_ComputerSystem
    $espacioTrabajo = if ($compSystem.PartOfDomain) { "Dominio: $($compSystem.Domain)" } else { "Grupo de Trabajo: $($compSystem.Workgroup)" }

    $cpu = (Get-CimInstance Win32_Processor).Name.Trim()
    $ramBytes = $compSystem.TotalPhysicalMemory
    $ramGB = [math]::Round($ramBytes / 1GB, 2)
    $ramModule = Get-CimInstance Win32_PhysicalMemory | Select-Object -First 1
    $ramType = switch ($ramModule.SMBIOSMemoryType) {
        20 { "DDR" }
        21 { "DDR2" }
        24 { "DDR3" }
        26 { "DDR4" }
        34 { "DDR5" }
        default { "Desconocido/Onboard" }
    }

    $net = Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true -and $_.DefaultIPGateway -ne $null } | Select-Object -First 1
    if (-not $net) {
        $net = Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true } | Select-Object -First 1
    }

    if ($net) {
        $ip = ($net.IPAddress | Where-Object { $_ -match '^\d+\.\d+\.\d+\.\d+$' }) -join ", "
        $gateway = if ($net.DefaultIPGateway) { ($net.DefaultIPGateway) -join ", " } else { "No asignada" }
        $dnsServers = if ($net.DNSServerSearchOrder) { ($net.DNSServerSearchOrder) -join ", " } else { "No asignados" }
        $mac = $net.MACAddress
        $redNombre = $net.Description
    }
    else {
        $ip = "Sin Conexión"
        $gateway = "Sin Conexión"
        $dnsServers = "Sin Conexión"
        $mac = "Sin Conexión"
        $redNombre = "N/A"
    }

    $physicalDisks = Get-PhysicalDisk | Select-Object FriendlyName, MediaType, @{N = "SizeGB"; E = { [math]::Round($_.Size / 1GB, 2) } }

    $monitoresRaw = Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorID -ErrorAction SilentlyContinue
    $listaMonitores = @()
    if ($monitoresRaw) {
        foreach ($mon in $monitoresRaw) {
            $mfg = ($mon.ManufacturerName | Where-Object { $_ -ne 0 } | ForEach-Object { [char]$_ }) -join ''
            $model = ($mon.UserFriendlyName | Where-Object { $_ -ne 0 } | ForEach-Object { [char]$_ }) -join ''
            if (-not $model) {
                $model = "Genérico / Estándar"
            }
            $listaMonitores += "$mfg - $model"
        }
    }
    else {
        $listaMonitores += "Pantalla Estándar / No detectado por EDID"
    }

    $teclados = (Get-CimInstance Win32_Keyboard | Select-Object -ExpandProperty Description) -join " | "
    if (-not $teclados) {
        $teclados = "No detectado"
    }

    $mouses = (Get-CimInstance Win32_PointingDevice | Select-Object -ExpandProperty Description) -join " | "
    if (-not $mouses) {
        $mouses = "No detectado"
    }

    Clear-Host
    Write-Host "==================================================================" -ForegroundColor Cyan
    Write-Host "               FICHA TÉCNICA DEL SISTEMA - INVACA                 " -ForegroundColor Yellow
    Write-Host "==================================================================" -ForegroundColor Cyan
    
    Write-Host " [SISTEMA Y ESPACIO DE TRABAJO]" -ForegroundColor Green
    Write-Host "  • Nombre del Equipo : " -NoNewline; Write-Host $nombreEquipo -ForegroundColor White
    Write-Host "  • Entorno / Dominio : " -NoNewline; Write-Host $espacioTrabajo -ForegroundColor White

    Write-Host "`n [RED Y CONECTIVIDAD]" -ForegroundColor Green
    Write-Host "  • Dirección IP      : " -NoNewline; Write-Host $ip -ForegroundColor White
    Write-Host "  • Puerta de Enlace  : " -NoNewline; Write-Host $gateway -ForegroundColor White
    Write-Host "  • Servidores DNS    : " -NoNewline; Write-Host $dnsServers -ForegroundColor White
    Write-Host "  • Dirección MAC     : " -NoNewline; Write-Host $mac -ForegroundColor White
    Write-Host "  • Tarjeta de Red    : " -NoNewline; Write-Host $redNombre -ForegroundColor Gray
    
    Write-Host "`n [HARDWARE PRINCIPAL]" -ForegroundColor Green
    Write-Host "  • Procesador        : " -NoNewline; Write-Host $cpu -ForegroundColor White
    Write-Host "  • Memoria RAM       : " -NoNewline; Write-Host "$ramGB GB ($ramType)" -ForegroundColor White

    Write-Host "`n [ALMACENAMIENTO FÍSICO]" -ForegroundColor Green
    foreach ($disk in $physicalDisks) {
        $tipoDisco = if ($disk.MediaType) { $disk.MediaType } else { "SSD/NVMe/HDD" }
        Write-Host "  • Disco             : " -NoNewline
        Write-Host "$($disk.FriendlyName) " -NoNewline -ForegroundColor White
        Write-Host "[$tipoDisco - $($disk.SizeGB) GB]" -ForegroundColor Yellow
    }

    Write-Host "`n [PERIFÉRICOS Y PANTALLAS]" -ForegroundColor Green
    foreach ($mon in $listaMonitores) {
        Write-Host "  • Monitor           : " -NoNewline; Write-Host $mon -ForegroundColor White
    }
    Write-Host "  • Teclado(s)        : " -NoNewline; Write-Host $teclados -ForegroundColor White
    Write-Host "  • Mouse / Puntero   : " -NoNewline; Write-Host $mouses -ForegroundColor White

    Write-Host "==================================================================" -ForegroundColor Cyan

    $exportar = Read-Host "`n¿Deseas exportar esta ficha a un archivo de texto en el Escritorio? (S/N)"
    if ($exportar -eq "S" -or $exportar -eq "s") {
        $rutaDesktop = [System.IO.Path]::Combine($env:USERPROFILE, "Desktop")
        $archivoReporte = "$rutaDesktop\Ficha_INVACA_$nombreEquipo.txt"

        $contenidoReporte = @"
==================================================================
               FICHA TÉCNICA DEL SISTEMA - INVACA                 
==================================================================
[SISTEMA Y ESPACIO DE TRABAJO]
• Nombre del Equipo : $nombreEquipo
• Entorno / Dominio : $espacioTrabajo

[RED Y CONECTIVIDAD]
• Dirección IP      : $ip
• Puerta de Enlace  : $gateway
• Servidores DNS    : $dnsServers
• Dirección MAC     : $mac
• Tarjeta de Red    : $redNombre

[HARDWARE PRINCIPAL]
• Procesador        : $cpu
• Memoria RAM       : $ramGB GB ($ramType)

[ALMACENAMIENTO FÍSICO]
"@
        foreach ($disk in $physicalDisks) {
            $tipoDisco = if ($disk.MediaType) { $disk.MediaType } else { "SSD/NVMe/HDD" }
            $contenidoReporte += "`n• Disco             : $($disk.FriendlyName) [$tipoDisco - $($disk.SizeGB) GB]"
        }

        $contenidoReporte += "`n`n[PERIFÉRICOS Y PANTALLAS]"
        foreach ($mon in $listaMonitores) {
            $contenidoReporte += "`n• Monitor           : $mon"
        }
        $contenidoReporte += "`n• Teclado(s)        : $teclados"
        $contenidoReporte += "`n• Mouse / Puntero   : $mouses"
        $contenidoReporte += "`n=================================================================="

        $contenidoReporte | Out-File -FilePath $archivoReporte -Encoding utf8
        Write-Host "[✓] Ficha guardada en: $archivoReporte" -ForegroundColor Green
        Start-Sleep -Seconds 2
    }
    else {
        Write-Host "`nPresiona Enter para volver al menú principal..." -ForegroundColor Gray
        Read-Host
    }
}

function Ejecutar-Mantenimiento {
    Clear-Host
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "      MANTENIMIENTO Y LIMPIEZA           " -ForegroundColor Yellow
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "1. Limpieza de Archivos Temporales y Caché"
    Write-Host "2. Reparar Integridad del Sistema (SFC + DISM)"
    Write-Host "3. Volver al menú principal"
    Write-Host "=========================================" -ForegroundColor Cyan

    $subOp = Read-Host "Selecciona una opción (1-3)"

    switch ($subOp) {
        "1" {
            Write-Host "`n[+] Borrando archivos temporales del usuario y del sistema..." -ForegroundColor Green
            Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item -Path "C:\Windows\Prefetch\*" -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "[✓] Limpieza de temporales completada." -ForegroundColor Yellow
            Start-Sleep -Seconds 2
        }
        "2" {
            Write-Host "`n[+] Ejecutando comprobación e integridad con SFC y DISM..." -ForegroundColor Green
            Write-Host "[*] Reparando imagen del sistema (DISM)..." -ForegroundColor Gray
            dism /online /cleanup-image /restorehealth
            Write-Host "[*] Escaneando archivos corruptos de Windows (SFC)..." -ForegroundColor Gray
            sfc /scannow
            Write-Host "[✓] Diagnóstico de integridad finalizado." -ForegroundColor Yellow
            Start-Sleep -Seconds 3
        }
        "3" { return }
    }
}

function Ejecutar-ReparadorRed {
    Clear-Host
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "    REPARACIÓN Y DIAGNÓSTICO DE RED      " -ForegroundColor Yellow
    Write-Host "=========================================" -ForegroundColor Cyan

    Write-Host "`n[1/3] Limpiando caché DNS..." -ForegroundColor Green
    ipconfig /flushdns

    Write-Host "`n[2/3] Restableciendo catálogo Winsock..." -ForegroundColor Green
    netsh winsock reset | Out-Null

    Write-Host "`n[3/3] Probando conectividad de red..." -ForegroundColor Green
    
    $net = Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true -and $_.DefaultIPGateway -ne $null } | Select-Object -First 1
    if ($net -and $net.DefaultIPGateway) {
        $gw = $net.DefaultIPGateway[0]
        $pingGW = Test-Connection -ComputerName $gw -Count 1 -Quiet
        $resGW = if ($pingGW) { "OK (Responde)" } else { "FALLO (No responde)" }
        $colorGW = if ($pingGW) { "Green" } else { "Red" }
        
        Write-Host "  • Puerta de Enlace ($gw): " -NoNewline
        Write-Host $resGW -ForegroundColor $colorGW
    }

    $pingInet = Test-Connection -ComputerName "192.168.0.39" -Count 1 -Quiet
    $resInet = if ($pingInet) { "OK (Conexión Establecida)" } else { "FALLO (Sin Salida a Internet)" }
    $colorInet = if ($pingInet) { "Green" } else { "Red" }
    
    Write-Host "  • Internet (192.168.0.39)      : " -NoNewline
    Write-Host $resInet -ForegroundColor $colorInet

    Write-Host "`n[✓] Proceso de red finalizado." -ForegroundColor Yellow
    Write-Host "Presiona Enter para continuar..." -ForegroundColor Gray
    Read-Host
}

function Ejecutar-DestrabarImpresoras {
    Clear-Host
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "   DESTRABAR COLA DE IMPRESIÓN (SPOOLER) " -ForegroundColor Yellow
    Write-Host "=========================================" -ForegroundColor Cyan

    Write-Host "`n[+] Deteniendo servicio de impresión (Spooler)..." -ForegroundColor Green
    Stop-Service -Name Spooler -Force -ErrorAction SilentlyContinue

    Write-Host "[+] Limpiando trabajos de impresión atascados..." -ForegroundColor Green
    Remove-Item -Path "$env:SystemRoot\System32\spool\PRINTERS\*" -Force -Recurse -ErrorAction SilentlyContinue

    Write-Host "[+] Reiniciando servicio de impresión..." -ForegroundColor Green
    Start-Service -Name Spooler

    Write-Host "`n[✓] Cola de impresión limpiada y servicio restablecido con éxito." -ForegroundColor Yellow
    Start-Sleep -Seconds 3
}

function Localizar-PuntoEthernet {
    Clear-Host
    Write-Host "====================================================" -ForegroundColor Cyan
    Write-Host "   INVACA TOOLS - RASTREADOR Y CONFIGURADOR         " -ForegroundColor Yellow
    Write-Host "====================================================" -ForegroundColor Cyan

    $nic = Get-NetAdapter | Where-Object { 
        $_.Status -eq "Up" -and 
        $_.HardwareInterface -eq $true -and 
        $_.InterfaceDescription -notmatch "Virtual|Hyper-V|VMware|VirtualBox|vEthernet|TAP|TUN|Loopback"
    } | Select-Object -First 1

    if (-not $nic) {
        Write-Host "`n[!] No se detectó interfaz Ethernet física activa." -ForegroundColor Red
        Pause
        return
    }

    $rawMac = $nic.MacAddress.Replace("-","").Replace(":","").ToLower()
    $mac3com = "$($rawMac.Substring(0,4))-$($rawMac.Substring(4,4))-$($rawMac.Substring(8,4))"
    $macCisco = $nic.MacAddress.Replace("-",":").ToLower()
    
    $ipLocal = (Get-NetIPAddress -InterfaceAlias $nic.Name -AddressFamily IPv4 -ErrorAction SilentlyContinue | 
        Where-Object {$_.IPAddress -notlike "169.254.*" -and $_.IPAddress -ne "127.0.0.1"} | 
        Select-Object -First 1).IPAddress
    
    if (-not $ipLocal) {
        $ipLocal = (Get-NetIPAddress -InterfaceAlias $nic.Name -AddressFamily IPv4 -ErrorAction SilentlyContinue | 
            Select-Object -First 1).IPAddress
    }

    Write-Host "`n[+] DATOS LOCALES:" -ForegroundColor Green
    Write-Host "    - Interfaz: $($nic.Name)"
    Write-Host "    - IP Local: $ipLocal"
    Write-Host "    - MAC:      $($nic.MacAddress) (3Com: $mac3com)"
    
    $vlanDetectada = if ($ipLocal -match '192\.168\.(\d+)\.\d+') { $Matches[1] } else { "Desconocida" }
    Write-Host "    - VLAN Detectada: $vlanDetectada" -ForegroundColor Cyan

    $listaSwitches = @(
        @{ IP = "192.168.0.103"; Nombre = "PB" },
        @{ IP = "192.168.0.104"; Nombre = "Mzz A" },
        @{ IP = "192.168.0.105"; Nombre = "Mzz B" },
        @{ IP = "192.168.0.106"; Nombre = "P4" },
        @{ IP = "192.168.0.107"; Nombre = "P7" },
        @{ IP = "192.168.0.108"; Nombre = "P8" },
        @{ IP = "192.168.0.109"; Nombre = "P9" }
    )

    function Send-3ComCommand {
        param ($IP, $Commands, $Esperar = 500)
        try {
            $tcp = New-Object System.Net.Sockets.TcpClient
            $connect = $tcp.BeginConnect($IP, 23, $null, $null)
            if (-not $connect.AsyncWaitHandle.WaitOne(2000, $false)) { return $null }
            $tcp.EndConnect($connect)
            
            $stream = $tcp.GetStream()
            $buffer = New-Object byte[] 65536
            $output = ""

            foreach ($cmd in $Commands) {
                $bytes = [System.Text.Encoding]::ASCII.GetBytes("$cmd`n")
                $stream.Write($bytes, 0, $bytes.Length)
                Start-Sleep -Milliseconds $Esperar
                while ($stream.DataAvailable) {
                    $read = $stream.Read($buffer, 0, $buffer.Length)
                    $output += [System.Text.Encoding]::ASCII.GetString($buffer, 0, $read)
                }
            }
            $tcp.Close()
            return $output
        } catch { return $null }
    }

    # Función para configurar puerto según estándares INVACA
    function Configurar-PuertoINVACA {
        param (
            $SwitchIP,
            $Puerto,
            $VLAN = "101",
            $Descripcion = "INVACA Tools"
        )
        
        Write-Host "`n[+] Configurando puerto $Puerto según estándares INVACA..." -ForegroundColor Yellow
        Write-Host "    Switch: $SwitchIP" -ForegroundColor Gray
        Write-Host "    VLAN:   $VLAN" -ForegroundColor Gray
        Write-Host "    Descripción: $Descripcion" -ForegroundColor Gray
        
        $cmdsConfig = @(
            "system-view",
            "interface $Puerto",
            "undo shutdown",
            "port link-type access",
            "port access vlan $VLAN",
            "broadcast-suppression pps 3000",
            "undo jumboframe enable",
            "description $Descripcion",
            "stp disable",
            "stp edged-port enable",
            "quit",
            "quit",
            "save",
            "Y"
        )
        
        Write-Host "`n    Aplicando configuración..." -ForegroundColor Cyan
        $resultado = Send-3ComCommand -IP $SwitchIP -Commands $cmdsConfig -Esperar 800
        
        if ($resultado) {
            Write-Host "[OK] Puerto configurado exitosamente" -ForegroundColor Green
            Write-Host "    Esperando 10 segundos para que el puerto se active..." -ForegroundColor Gray
            Start-Sleep -Seconds 10
            return $true
        } else {
            Write-Host "[ERROR] No se pudo configurar el puerto" -ForegroundColor Red
            return $false
        }
    }

    # Verificar conectividad con switches
    Write-Host "`n[+] Verificando conectividad con switches..." -ForegroundColor Yellow
    $switchesAlcanzables = @()
    foreach ($sw in $listaSwitches) {
        Write-Host "-> $($sw.Nombre) ($($sw.IP))..." -NoNewline
        if (Test-Connection -ComputerName $sw.IP -Count 1 -Quiet -ErrorAction SilentlyContinue) {
            Write-Host " [OK]" -ForegroundColor Green
            $switchesAlcanzables += $sw
        } else {
            Write-Host " [Inalcanzable]" -ForegroundColor Red
        }
    }

    if ($switchesAlcanzables.Count -eq 0) {
        Write-Host "`n[!] CRÍTICO: Ningún switch es alcanzable." -ForegroundColor Red
        Write-Host "    Causas: IP APIPA (169.254.x.x), VLAN incorrecta, o sin DHCP" -ForegroundColor Yellow
        Pause
        return
    }

    # MÉTODO 1: Buscar MAC en switches
    Write-Host "`n[MÉTODO 1] Buscando MAC en tabla de switches..." -ForegroundColor Yellow
    $puertoEncontrado = $false
    $macEncontrada = $null
    $switchEncontrado = $null
    $interfazEncontrada = $null

    foreach ($sw in $switchesAlcanzables) {
        Write-Host "-> $($sw.Nombre) ($($sw.IP))..." -NoNewline

        $formatosMac = @($mac3com, $macCisco)
        $encontrado = $false

        foreach ($formatoMac in $formatosMac) {
            $cmdsMac = @("manager", "manager", "display mac-address $formatoMac")
            $resMac = Send-3ComCommand -IP $sw.IP -Commands $cmdsMac -Esperar 600

            if ($resMac -match "(GigabitEthernet\d+/\d+/\d+|Ethernet\d+/\d+/\d+)") {
                $interfazTemp = $Matches[1]
                $macEncontrada = $formatoMac
                
                $cmdsConfig = @("manager", "manager", "display current-configuration interface $interfazTemp")
                $resConfig = Send-3ComCommand -IP $sw.IP -Commands $cmdsConfig -Esperar 600

                if ($resConfig -match "port link-type trunk") {
                    Write-Host " [TRUNK]" -ForegroundColor DarkYellow
                } else {
                    # Verificar si el puerto está apagado o mal configurado
                    $puertoDown = $resConfig -match "shutdown"
                    $vlanIncorrecta = $resConfig -notmatch "port access vlan $vlanDetectada"
                    $faltaSTP = $resConfig -notmatch "stp edged-port enable"
                    
                    if ($puertoDown -or $vlanIncorrecta -or $faltaSTP) {
                        Write-Host " [ENCONTRADO pero requiere configuración: $interfazTemp]" -ForegroundColor Yellow
                    } else {
                        Write-Host " [¡ENCONTRADO!: $interfazTemp]" -ForegroundColor Green
                    }
                    
                    $puertoEncontrado = $true
                    $switchEncontrado = $sw
                    $interfazEncontrada = $interfazTemp
                    $encontrado = $true
                    
                    # Mostrar configuración actual
                    Write-Host "`n--- Configuración actual ---" -ForegroundColor Cyan
                    if ($resConfig -match "(?s)(interface\s+[^\s]+[\s\S]*?)(?=\ninterface\s|\n#\s|\z)") {
                        Write-Host $Matches[1].Trim() -ForegroundColor Gray
                    }
                    
                    break
                }
            }
        }

        if (-not $encontrado) {
            Write-Host " [No registrado]" -ForegroundColor DarkGray
        }

        if ($puertoEncontrado) { break }
    }

    # Si encontró el puerto, verificar si necesita configuración
    if ($puertoEncontrado) {
        Write-Host "`n====================================================" -ForegroundColor Cyan
        Write-Host " PUERTO ENCONTRADO" -ForegroundColor Yellow
        Write-Host "====================================================" -ForegroundColor Cyan
        Write-Host " Switch: $($switchEncontrado.Nombre) ($($switchEncontrado.IP))" -ForegroundColor White
        Write-Host " Puerto: $interfazEncontrada" -ForegroundColor White
        Write-Host " MAC:    $macEncontrada" -ForegroundColor White
        
        # Verificar configuración actual
        $cmdsConfig = @("manager", "manager", "display current-configuration interface $interfazEncontrada")
        $resConfig = Send-3ComCommand -IP $switchEncontrado.IP -Commands $cmdsConfig -Esperar 600
        
        $necesitaConfig = $false
        $razones = @()
        
        if ($resConfig -match "shutdown") {
            $necesitaConfig = $true
            $razones += "Puerto está APAGADO (shutdown)"
        }
        
        if ($resConfig -notmatch "port link-type access") {
            $necesitaConfig = $true
            $razones += "No está configurado como puerto de acceso"
        }
        
        if ($vlanDetectada -ne "Desconocida" -and $resConfig -notmatch "port access vlan $vlanDetectada") {
            $necesitaConfig = $true
            $razones += "VLAN incorrecta (debería ser $vlanDetectada)"
        }
        
        if ($resConfig -notmatch "broadcast-suppression pps 3000") {
            $necesitaConfig = $true
            $razones += "Falta broadcast-suppression pps 3000"
        }
        
        if ($resConfig -notmatch "undo jumboframe enable") {
            $necesitaConfig = $true
            $razones += "Falta undo jumboframe enable"
        }
        
        if ($resConfig -notmatch "stp disable") {
            $necesitaConfig = $true
            $razones += "Falta stp disable"
        }
        
        if ($resConfig -notmatch "stp edged-port enable") {
            $necesitaConfig = $true
            $razones += "Falta stp edged-port enable"
        }
        
        if ($necesitaConfig) {
            Write-Host "`n[!] El puerto necesita configuración:" -ForegroundColor Red
            foreach ($razon in $razones) {
                Write-Host "    - $razon" -ForegroundColor Yellow
            }
            
            Write-Host "`n[?] ¿Deseas configurar el puerto automáticamente con estándares INVACA?" -ForegroundColor Yellow
            Write-Host "    Se aplicará:" -ForegroundColor Gray
            Write-Host "      - Encender puerto (undo shutdown)" -ForegroundColor Gray
            Write-Host "      - Modo acceso (port link-type access)" -ForegroundColor Gray
            Write-Host "      - VLAN $vlanDetectada" -ForegroundColor Gray
            Write-Host "      - broadcast-suppression pps 3000" -ForegroundColor Gray
            Write-Host "      - undo jumboframe enable" -ForegroundColor Gray
            Write-Host "      - stp disable" -ForegroundColor Gray
            Write-Host "      - stp edged-port enable" -ForegroundColor Gray
            Write-Host "      - Guardar configuración (save)" -ForegroundColor Gray
            
            $configurar = Read-Host "    (S/N)"
            
            if ($configurar -eq "S" -or $configurar -eq "s") {
                $descripcion = Read-Host "    Descripción del puerto (ejemplo: Puesto-Juan-Perez)"
                $configExitosa = Configurar-PuertoINVACA -SwitchIP $switchEncontrado.IP -Puerto $interfazEncontrada -VLAN $vlanDetectada -Descripcion $descripcion
                
                if ($configExitosa) {
                    Write-Host "`n[OK] Puerto configurado. Verificando conectividad..." -ForegroundColor Green
                    
                    # Esperar a que el puerto se active y obtener nueva IP
                    Start-Sleep -Seconds 5
                    $nuevaIP = (Get-NetIPAddress -InterfaceAlias $nic.Name -AddressFamily IPv4 -ErrorAction SilentlyContinue | 
                        Where-Object {$_.IPAddress -notlike "169.254.*"} | 
                        Select-Object -First 1).IPAddress
                    
                    if ($nuevaIP) {
                        Write-Host "[OK] Nueva IP asignada: $nuevaIP" -ForegroundColor Green
                        Write-Host "[OK] Puerto operativo y configurado correctamente" -ForegroundColor Green
                    } else {
                        Write-Host "[!] Puerto configurado pero sin IP. Verifica el DHCP" -ForegroundColor Yellow
                    }
                }
            }
        } else {
            Write-Host "`n[OK] El puerto está correctamente configurado según estándares INVACA" -ForegroundColor Green
        }
        
        Write-Host "====================================================" -ForegroundColor Cyan
    }

    # Si no encontró automáticamente, búsqueda manual
    if (-not $puertoEncontrado) {
        Write-Host "`n[!] No se detectó automáticamente." -ForegroundColor Red
        Write-Host "    Posibles causas:" -ForegroundColor Yellow
        Write-Host "    - Puerto apagado (shutdown)" -ForegroundColor Gray
        Write-Host "    - Puerto sin configurar" -ForegroundColor Gray
        Write-Host "    - MAC no aprendida aún" -ForegroundColor Gray
    }

    Write-Host "`n[MÉTODO 2] Búsqueda y configuración manual" -ForegroundColor Yellow
    Write-Host "1. Consultar puerto específico"
    Write-Host "2. Escanear todos los puertos de un switch (fuerza bruta)"
    Write-Host "3. Configurar puerto manualmente"
    Write-Host "4. Salir"
    $opcionManual = Read-Host "`nSelecciona opción (1-4)"

    if ($opcionManual -eq "1") {
        Write-Host "`nSelecciona el Switch:" -ForegroundColor Cyan
        for ($i=0; $i -lt $listaSwitches.Count; $i++) {
            Write-Host "  $($i+1). $($listaSwitches[$i].Nombre) ($($listaSwitches[$i].IP))"
        }
        $swIdx = Read-Host "`nOpción (1-7)"
        
        if ($swIdx -match '^\d+$' -and [int]$swIdx -ge 1 -and [int]$swIdx -le 7) {
            $swIdx = [int]$swIdx - 1
            $numPort = Read-Host "Número de puerto (ejemplo: 3 o GigabitEthernet1/0/3)"
            if ($numPort -match '^\d+$') { $numPort = "GigabitEthernet1/0/$numPort" }
            $swTarget = $listaSwitches[$swIdx]

            Write-Host "`n[+] Consultando $numPort en $($swTarget.Nombre)..." -ForegroundColor Yellow
            
            $cmdsMacPuerto = @("manager", "manager", "display mac-address | include $numPort")
            $resMacPuerto = Send-3ComCommand -IP $swTarget.IP -Commands $cmdsMacPuerto -Esperar 600
            
            $cmdsConfig = @("manager", "manager", "display current-configuration interface $numPort")
            $resConfig = Send-3ComCommand -IP $swTarget.IP -Commands $cmdsConfig -Esperar 600
            
            Write-Host "`n--- MACs en este puerto ---" -ForegroundColor Cyan
            if ($resMacPuerto -match "(\w{4}-\w{4}-\w{4})") {
                $macDelPuerto = $Matches[1]
                Write-Host "MAC encontrada: $macDelPuerto" -ForegroundColor White
                
                if ($macDelPuerto -eq $mac3com -or $macDelPuerto -eq $macCisco) {
                    Write-Host "[OK] ¡ESTA ES TU MAC! Puerto confirmado" -ForegroundColor Green
                } else {
                    Write-Host "[!] No es tu MAC (tu MAC: $mac3com)" -ForegroundColor Red
                }
            } else {
                Write-Host "No hay MACs aprendidas" -ForegroundColor Yellow
            }
            
            Write-Host "`n--- Configuración actual ---" -ForegroundColor Cyan
            if ($resConfig -match "(?s)(interface\s+[^\s]+[\s\S]*?)(?=\ninterface\s|\n#\s|\z)") {
                Write-Host $Matches[1].Trim() -ForegroundColor Gray
            }
            
            # Verificar si necesita configuración
            $necesitaConfig = $false
            if ($resConfig -match "shutdown") { $necesitaConfig = $true; Write-Host "`n[!] Puerto está APAGADO" -ForegroundColor Red }
            if ($resConfig -notmatch "port link-type access") { $necesitaConfig = $true; Write-Host "[!] No es puerto de acceso" -ForegroundColor Red }
            if ($resConfig -notmatch "stp edged-port enable") { $necesitaConfig = $true; Write-Host "[!] Falta stp edged-port enable" -ForegroundColor Red }
            
            if ($necesitaConfig) {
                Write-Host "`n[?] ¿Configurar este puerto con estándares INVACA?" -ForegroundColor Yellow
                $configurar = Read-Host "    (S/N)"
                
                if ($configurar -eq "S" -or $configurar -eq "s") {
                    $vlanConfig = Read-Host "    VLAN a asignar (ejemplo: 101)"
                    $descripcion = Read-Host "    Descripción del puerto"
                    Configurar-PuertoINVACA -SwitchIP $swTarget.IP -Puerto $numPort -VLAN $vlanConfig -Descripcion $descripcion
                }
            }
        }
    }
    elseif ($opcionManual -eq "2") {
        Write-Host "`nSelecciona el Switch a escanear:" -ForegroundColor Cyan
        for ($i=0; $i -lt $listaSwitches.Count; $i++) {
            Write-Host "  $($i+1). $($listaSwitches[$i].Nombre) ($($listaSwitches[$i].IP))"
        }
        $swIdx = Read-Host "`nOpción (1-7)"
        
        if ($swIdx -match '^\d+$' -and [int]$swIdx -ge 1 -and [int]$swIdx -le 7) {
            $swIdx = [int]$swIdx - 1
            $swTarget = $listaSwitches[$swIdx]
            
            Write-Host "`n[+] Escaneando puertos 1-48 en $($swTarget.Nombre)..." -ForegroundColor Yellow
            Write-Host "    Esto puede tardar 2-3 minutos..." -ForegroundColor Gray
            
            $encontrado = $false
            for ($p = 1; $p -le 48; $p++) {
                $puerto = "GigabitEthernet1/0/$p"
                Write-Host "    Puerto $p..." -NoNewline
                
                $cmdsMacPuerto = @("manager", "manager", "display mac-address | include $puerto")
                $resMacPuerto = Send-3ComCommand -IP $swTarget.IP -Commands $cmdsMacPuerto -Esperar 400
                
                if ($resMacPuerto -match $mac3com -or $resMacPuerto -match $macCisco) {
                    Write-Host " [¡ENCONTRADO!]" -ForegroundColor Green
                    
                    $cmdsConfig = @("manager", "manager", "display current-configuration interface $puerto")
                    $resConfig = Send-3ComCommand -IP $swTarget.IP -Commands $cmdsConfig -Esperar 600
                    
                    Write-Host "`n====================================================" -ForegroundColor Cyan
                    Write-Host " ¡PUERTO ENCONTRADO!" -ForegroundColor Yellow
                    Write-Host "====================================================" -ForegroundColor Cyan
                    Write-Host " Switch: $($swTarget.Nombre)" -ForegroundColor White
                    Write-Host " Puerto: $puerto" -ForegroundColor White
                    
                    if ($resConfig -match "(?s)(interface\s+[^\s]+[\s\S]*?)(?=\ninterface\s|\n#\s|\z)") {
                        Write-Host "`nConfiguración actual:" -ForegroundColor Cyan
                        Write-Host $Matches[1].Trim() -ForegroundColor Gray
                    }
                    
                    # Ofrecer configurar si está apagado o mal configurado
                    if ($resConfig -match "shutdown" -or $resConfig -notmatch "stp edged-port enable") {
                        Write-Host "`n[!] Puerto requiere configuración" -ForegroundColor Red
                        Write-Host "[?] ¿Configurar con estándares INVACA?" -ForegroundColor Yellow
                        $configurar = Read-Host "    (S/N)"
                        
                        if ($configurar -eq "S" -or $configurar -eq "s") {
                            $vlanConfig = Read-Host "    VLAN a asignar (ejemplo: 101)"
                            $descripcion = Read-Host "    Descripción del puerto"
                            Configurar-PuertoINVACA -SwitchIP $swTarget.IP -Puerto $puerto -VLAN $vlanConfig -Descripcion $descripcion
                        }
                    }
                    
                    Write-Host "====================================================" -ForegroundColor Cyan
                    $encontrado = $true
                    break
                } else {
                    Write-Host " [No]" -ForegroundColor DarkGray
                }
            }
            
            if (-not $encontrado) {
                Write-Host "`n[!] No se encontró tu MAC en ningún puerto (1-48)" -ForegroundColor Red
            }
        }
    }
    elseif ($opcionManual -eq "3") {
        # Configuración manual directa
        Write-Host "`nSelecciona el Switch:" -ForegroundColor Cyan
        for ($i=0; $i -lt $listaSwitches.Count; $i++) {
            Write-Host "  $($i+1). $($listaSwitches[$i].Nombre) ($($listaSwitches[$i].IP))"
        }
        $swIdx = Read-Host "`nOpción (1-7)"
        
        if ($swIdx -match '^\d+$' -and [int]$swIdx -ge 1 -and [int]$swIdx -le 7) {
            $swIdx = [int]$swIdx - 1
            $numPort = Read-Host "Número de puerto (ejemplo: 3 o GigabitEthernet1/0/3)"
            if ($numPort -match '^\d+$') { $numPort = "GigabitEthernet1/0/$numPort" }
            $vlanConfig = Read-Host "VLAN a asignar (ejemplo: 101)"
            $descripcion = Read-Host "Descripción del puerto (ejemplo: Puesto-Juan-Perez)"
            $swTarget = $listaSwitches[$swIdx]
            
            Write-Host "`n[!] Vas a configurar:" -ForegroundColor Yellow
            Write-Host "    Switch: $($swTarget.Nombre) ($($swTarget.IP))" -ForegroundColor White
            Write-Host "    Puerto: $numPort" -ForegroundColor White
            Write-Host "    VLAN:   $vlanConfig" -ForegroundColor White
            Write-Host "    Descripción: $descripcion" -ForegroundColor White
            Write-Host "    Acciones:" -ForegroundColor White
            Write-Host "      - Encender puerto (undo shutdown)" -ForegroundColor Gray
            Write-Host "      - Configurar como acceso (port link-type access)" -ForegroundColor Gray
            Write-Host "      - Asignar VLAN $vlanConfig" -ForegroundColor Gray
            Write-Host "      - broadcast-suppression pps 3000" -ForegroundColor Gray
            Write-Host "      - undo jumboframe enable" -ForegroundColor Gray
            Write-Host "      - stp disable" -ForegroundColor Gray
            Write-Host "      - stp edged-port enable" -ForegroundColor Gray
            Write-Host "      - Guardar configuración (save)" -ForegroundColor Gray
            
            $confirmar = Read-Host "`n¿Confirmar configuración? (S/N)"
            
            if ($confirmar -eq "S" -or $confirmar -eq "s") {
                Configurar-PuertoINVACA -SwitchIP $swTarget.IP -Puerto $numPort -VLAN $vlanConfig -Descripcion $descripcion
            }
        }
    }

    Pause
}

function Ejecutar-InstaladorSoftware {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host "`n[X] Winget no está disponible en este sistema." -ForegroundColor Red
        Write-Host "[*] Asegúrate de tener Windows 10/11 actualizado con App Installer." -ForegroundColor Gray
        Start-Sleep -Seconds 3
        return
    }

    do {
        Clear-Host
        Write-Host "=========================================" -ForegroundColor Cyan
        Write-Host "     INSTALADOR DE SOFTWARE (WINGET)     " -ForegroundColor Yellow
        Write-Host "=========================================" -ForegroundColor Cyan
        Write-Host "1. Google Chrome"
        Write-Host "2. 7-Zip"
        Write-Host "3. Notepad++"
        Write-Host "4. AnyDesk"
        Write-Host "5. INSTALAR COMBO COMPLETO (Todo lo anterior)"
        Write-Host "6. Reparar catálogo Winget (Error 0x8a15000f)"
        Write-Host "7. Volver al menú principal"
        Write-Host "=========================================" -ForegroundColor Cyan

        $subSoft = Read-Host "Selecciona una opción (1-7)"
        $params = "--silent --accept-source-agreements --accept-package-agreements --disable-interactivity"

        switch ($subSoft) {
            "1" { winget install --id Google.Chrome $params }
            "2" { winget install --id 7zip.7zip $params }
            "3" { winget install --id Notepad++.Notepad++ $params }
            "4" { winget install --id AnyDeskSoftwareGmbH.AnyDesk $params }
            "5" {
                Write-Host "`n[+] Instalando paquete de programas esenciales INVACA..." -ForegroundColor Green
                Write-Host "[*] Instalando Google Chrome..." -ForegroundColor Gray
                winget install --id Google.Chrome $params
                Write-Host "[*] Instalando 7-Zip..." -ForegroundColor Gray
                winget install --id 7zip.7zip $params
                Write-Host "[*] Instalando Notepad++..." -ForegroundColor Gray
                winget install --id Notepad++.Notepad++ $params
                Write-Host "[*] Instalando AnyDesk..." -ForegroundColor Gray
                winget install --id AnyDeskSoftwareGmbH.AnyDesk $params
                Write-Host "[✓] Proceso del combo finalizado." -ForegroundColor Yellow
                Start-Sleep -Seconds 2
            }
            "6" {
                Write-Host "`n[+] Reparando y restableciendo catálogos de Winget..." -ForegroundColor Green
                winget source reset --force
                winget source update
                Write-Host "[✓] Catálogo reparado exitosamente. Intenta instalar de nuevo." -ForegroundColor Yellow
                Start-Sleep -Seconds 3
            }
            "7" { return }
        }
    } while ($subSoft -ne "7")
}

# Bucle principal
do {
    Mostrar-Menu
    $opcion = Read-Host "Selecciona una opción (1-9 o S)"
    
    switch ($opcion) {
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
            Write-Host "`nSaliendo de INVACA Tools. ¡Listo por hoy!" -ForegroundColor Yellow
            Start-Sleep -Seconds 1
            exit 
        }
        "s" { 
            Write-Host "`nSaliendo de INVACA Tools. ¡Listo por hoy!" -ForegroundColor Yellow
            Start-Sleep -Seconds 1
            exit 
        }
        default { 
            Write-Host "`nOpción no válida, intenta de nuevo." -ForegroundColor Red
            Start-Sleep -Seconds 2 
        }
    }
} while ($true)
