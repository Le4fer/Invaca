# =========================================================================
# INVACA TOOLS - VERSIÓN FINAL UNIFICADA
# =========================================================================
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$esAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $esAdmin) {
    Write-Host "`n[!] INVACA Tools requiere permisos de Administrador." -ForegroundColor Yellow
    Write-Host "[*] Solicitando elevación de privilegios de Windows..." -ForegroundColor Cyan
    
    $scriptPath = $MYINVOCATION.MyCommand.Path
    if ($scriptPath) {
        Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoExit", "-ExecutionPolicy", "Bypass", "-File", $scriptPath
    } else {
        Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoExit", "-ExecutionPolicy", "Bypass"
    }
    exit
}

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
    Write-Host "10. Analizar SRVFVICAS01 (Servidor Principal)"
    Write-Host "S. Salir"
    Write-Host "=========================================" -ForegroundColor Cyan
}

function Ejecutar-Activador {
    Write-Host "`n[+] Lanzando Microsoft Activation Script (MAS)..." -ForegroundColor Green
    irm https://get.activated.win | iex
}

function Ejecutar-Optimizador {
    Write-Host "`n[+] Lanzando Herramienta de Optimización..." -ForegroundColor Green
    $cmd = '[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iwr -useb https://christitus.com/win | iex'
    Start-Process powershell.exe -Verb RunAs -ArgumentList '-NoExit', '-ExecutionPolicy', 'Bypass', '-Command', $cmd
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
        $urlOffice = ''
        $nombreVersion = ''

        switch ($subOpcion) {
            '1' {
                $nombreVersion = "Microsoft 365 ProPlus (x64)"
                $urlOffice = 'https://c2rsetup.officeapps.live.com/c2r/download.aspx?ProductreleaseID=O365ProPlusRetail&platform=x64&language=es-mx&version=O16GA'
            }
            '2' {
                $nombreVersion = "Office 2021 Professional Plus (x64)"
                $urlOffice = 'https://c2rsetup.officeapps.live.com/c2r/download.aspx?ProductreleaseID=Professional2021Retail&platform=x64&language=es-mx&version=O16GA'
            }
            '3' {
                $nombreVersion = "Office 2019 Professional Plus (x64)"
                $urlOffice = 'https://c2rsetup.officeapps.live.com/c2r/download.aspx?ProductreleaseID=Professional2019Retail&platform=x64&language=es-mx&version=O16GA'
            }
            '4' {
                $urlOffice = Read-Host "`nPegar URL directa del ejecutable (.exe)"
                $nombreVersion = "Versión Personalizada"
            }
            '5' {
                Write-Host "`n[*] Abriendo Massgrave C2R Links en el navegador predeterminado..." -ForegroundColor Green
                Start-Process "https://massgrave.dev/office_c2r_links"
                Start-Sleep -Seconds 2
                continue
            }
            '6' { return }
            default {
                Write-Host "`nOpción no válida." -ForegroundColor Red
                Start-Sleep -Seconds 1
                continue
            }
        }

        if (-not [string]::IsNullOrWhiteSpace($urlOffice)) {
            $destino = "$env:TEMP\SetupOffice.exe"
            if (Test-Path $destino) { Remove-Item $destino -Force -ErrorAction SilentlyContinue }

            try {
                Write-Host "`n[+] Preparando descarga de: $nombreVersion" -ForegroundColor Green
                Write-Host "[*] Descargando desde servidores oficiales de Microsoft..." -ForegroundColor Gray
                
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
                    Write-Host "[X] Error: El archivo no se pudo descargar correctamente o fue bloqueado." -ForegroundColor Red
                }
            } catch {
                Write-Host "`n[X] Error durante la descarga o ejecución: $_" -ForegroundColor Red
            }
            Write-Host "`nPresiona Enter para continuar..." -ForegroundColor Gray
            Read-Host
        }
    } while ($subOpcion -ne '6')
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
        20 { "DDR" } 21 { "DDR2" } 24 { "DDR3" } 26 { "DDR4" } 34 { "DDR5" } default { "Desconocido/Onboard" }
    }

    $net = Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true -and $_.DefaultIPGateway -ne $null } | Select-Object -First 1
    if (-not $net) { $net = Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true } | Select-Object -First 1 }

    if ($net) {
        $ip = ($net.IPAddress | Where-Object { $_ -match '^\d+\.\d+\.\d+\.\d+$' }) -join ", "
        $gateway = if ($net.DefaultIPGateway) { ($net.DefaultIPGateway) -join ", " } else { "No asignada" }
        $dnsServers = if ($net.DNSServerSearchOrder) { ($net.DNSServerSearchOrder) -join ", " } else { "No asignados" }
        $mac = $net.MACAddress
        $redNombre = $net.Description
    } else {
        $ip, $gateway, $dnsServers, $mac, $redNombre = "Sin Conexión", "Sin Conexión", "Sin Conexión", "Sin Conexión", "N/A"
    }

    $physicalDisks = Get-PhysicalDisk | Select-Object FriendlyName, MediaType, @{N = "SizeGB"; E = { [math]::Round($_.Size / 1GB, 2) } }
    $monitoresRaw = Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorID -ErrorAction SilentlyContinue
    $listaMonitores = @()
    
    if ($monitoresRaw) {
        foreach ($mon in $monitoresRaw) {
            $mfg = ($mon.ManufacturerName | Where-Object { $_ -ne 0 } | ForEach-Object { [char]$_ }) -join ''
            $model = ($mon.UserFriendlyName | Where-Object { $_ -ne 0 } | ForEach-Object { [char]$_ }) -join ''
            if (-not $model) { $model = "Genérico / Estándar" }
            $listaMonitores += "$mfg - $model"
        }
    } else { $listaMonitores += "Pantalla Estándar / No detectado por EDID" }

    $teclados = (Get-CimInstance Win32_Keyboard | Select-Object -ExpandProperty Description) -join " | "
    if (-not $teclados) { $teclados = "No detectado" }
    $mouses = (Get-CimInstance Win32_PointingDevice | Select-Object -ExpandProperty Description) -join " | "
    if (-not $mouses) { $mouses = "No detectado" }

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
        Write-Host "  • Disco             : " -NoNewline; Write-Host "$($disk.FriendlyName) " -NoNewline -ForegroundColor White; Write-Host "[$tipoDisco - $($disk.SizeGB) GB]" -ForegroundColor Yellow
    }
    Write-Host "`n [PERIFÉRICOS Y PANTALLAS]" -ForegroundColor Green
    foreach ($mon in $listaMonitores) { Write-Host "  • Monitor           : " -NoNewline; Write-Host $mon -ForegroundColor White }
    Write-Host "  • Teclado(s)        : " -NoNewline; Write-Host $teclados -ForegroundColor White
    Write-Host "  • Mouse / Puntero   : " -NoNewline; Write-Host $mouses -ForegroundColor White
    Write-Host "==================================================================" -ForegroundColor Cyan

    $exportar = Read-Host "`n¿Deseas exportar esta ficha a un archivo de texto en el Escritorio? (S/N)"
    if ($exportar -eq "S" -or $exportar -eq "s") {
        $rutaDesktop = [System.IO.Path]::Combine($env:USERPROFILE, "Desktop")
        $archivoReporte = "$rutaDesktop\Ficha_INVACA_$nombreEquipo.txt"
        $contenidoReporte = "==================================================================`n               FICHA TÉCNICA DEL SISTEMA - INVACA                 `n==================================================================`n[SISTEMA Y ESPACIO DE TRABAJO]`n• Nombre del Equipo : $nombreEquipo`n• Entorno / Dominio : $espacioTrabajo`n`n[RED Y CONECTIVIDAD]`n• Dirección IP      : $ip`n• Puerta de Enlace  : $gateway`n• Servidores DNS    : $dnsServers`n• Dirección MAC     : $mac`n• Tarjeta de Red    : $redNombre`n`n[HARDWARE PRINCIPAL]`n• Procesador        : $cpu`n• Memoria RAM       : $ramGB GB ($ramType)`n`n[ALMACENAMIENTO FÍSICO]"
        foreach ($disk in $physicalDisks) {
            $tipoDisco = if ($disk.MediaType) { $disk.MediaType } else { "SSD/NVMe/HDD" }
            $contenidoReporte += "`n• Disco             : $($disk.FriendlyName) [$tipoDisco - $($disk.SizeGB) GB]"
        }
        $contenidoReporte += "`n`n[PERIFÉRICOS Y PANTALLAS]"
        foreach ($mon in $listaMonitores) { $contenidoReporte += "`n• Monitor           : $mon" }
        $contenidoReporte += "`n• Teclado(s)        : $teclados`n• Mouse / Puntero   : $mouses`n=================================================================="
        $contenidoReporte | Out-File -FilePath $archivoReporte -Encoding utf8
        Write-Host "[✓] Ficha guardada en: $archivoReporte" -ForegroundColor Green
        Start-Sleep -Seconds 2
    } else {
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
            Write-Host "`n[+] Borrando archivos temporales..." -ForegroundColor Green
            Remove-Item -Path "$env:TEMP\*", "C:\Windows\Temp\*", "C:\Windows\Prefetch\*" -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "[✓] Limpieza completada." -ForegroundColor Yellow; Start-Sleep -Seconds 2
        }
        "2" {
            Write-Host "`n[+] Ejecutando SFC y DISM..." -ForegroundColor Green
            dism /online /cleanup-image /restorehealth
            sfc /scannow
            Write-Host "[✓] Diagnóstico finalizado." -ForegroundColor Yellow; Start-Sleep -Seconds 3
        }
        "3" { return }
    }
}

function Ejecutar-ReparadorRed {
    Clear-Host
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "    REPARACIÓN Y DIAGNÓSTICO DE RED      " -ForegroundColor Yellow
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "`n[1/3] Limpiando caché DNS..." -ForegroundColor Green; ipconfig /flushdns
    Write-Host "`n[2/3] Restableciendo Winsock..." -ForegroundColor Green; netsh winsock reset | Out-Null
    Write-Host "`n[3/3] Probando conectividad..." -ForegroundColor Green
    $net = Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true -and $_.DefaultIPGateway -ne $null } | Select-Object -First 1
    if ($net -and $net.DefaultIPGateway) {
        $gw = $net.DefaultIPGateway[0]
        $pingGW = Test-Connection -ComputerName $gw -Count 1 -Quiet
        Write-Host "  • Puerta de Enlace ($gw): " -NoNewline; Write-Host $(if ($pingGW) { "OK" } else { "FALLO" }) -ForegroundColor $(if ($pingGW) { "Green" } else { "Red" })
    }
    $pingInet = Test-Connection -ComputerName "192.168.0.39" -Count 1 -Quiet
    Write-Host "  • Internet (192.168.0.39) : " -NoNewline; Write-Host $(if ($pingInet) { "OK" } else { "FALLO" }) -ForegroundColor $(if ($pingInet) { "Green" } else { "Red" })
    Write-Host "`n[✓] Proceso finalizado." -ForegroundColor Yellow; Read-Host "Presiona Enter para continuar"
}

function Ejecutar-DestrabarImpresoras {
    Clear-Host
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "   DESTRABAR COLA DE IMPRESIÓN (SPOOLER) " -ForegroundColor Yellow
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "`n[+] Deteniendo Spooler..." -ForegroundColor Green; Stop-Service -Name Spooler -Force -ErrorAction SilentlyContinue
    Write-Host "[+] Limpiando trabajos atascados..." -ForegroundColor Green; Remove-Item -Path "$env:SystemRoot\System32\spool\PRINTERS\*" -Force -Recurse -ErrorAction SilentlyContinue
    Write-Host "[+] Reiniciando Spooler..." -ForegroundColor Green; Start-Service -Name Spooler
    Write-Host "`n[✓] Cola limpiada con éxito." -ForegroundColor Yellow; Start-Sleep -Seconds 3
}

function Localizar-PuntoEthernet {
    Clear-Host
    Write-Host "====================================================" -ForegroundColor Cyan
    Write-Host "   INVACA TOOLS - RASTREADOR DE PUERTO (CON PLAN B) " -ForegroundColor Yellow
    Write-Host "====================================================" -ForegroundColor Cyan

    $nic = Get-NetAdapter | Where-Object { $_.Status -eq "Up" -and $_.HardwareInterface -eq $true -and $_.InterfaceDescription -notmatch "Virtual|Hyper-V|VMware|VirtualBox|vEthernet|TAP|TUN|Loopback" } | Select-Object -First 1
    if (-not $nic) { Write-Host "`n[!] No se detectó interfaz Ethernet física activa." -ForegroundColor Red; Pause; return }

    $rawMac = $nic.MacAddress.Replace("-","").Replace(":","").ToLower()
    $mac3com = "$($rawMac.Substring(0,4))-$($rawMac.Substring(4,4))-$($rawMac.Substring(8,4))"
    $ipLocal = (Get-NetIPAddress -InterfaceAlias $nic.Name -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object {$_.IPAddress -notlike "169.254.*" }).IPAddress

    Write-Host "`n[+] DATOS LOCALES:" -ForegroundColor Green
    Write-Host "    - Interfaz: $($nic.Name) ($($nic.InterfaceDescription))"
    Write-Host "    - IP Local: $ipLocal"
    Write-Host "    - MAC:      $($nic.MacAddress) (3Com: $mac3com)"
    
    $vlanDetectada = if ($ipLocal -match '192\.168\.(\d+)\.\d+') { $Matches[1] } else { "Desconocida" }
    Write-Host "    - VLAN Detectada: $vlanDetectada" -ForegroundColor $(if ($vlanDetectada -eq "101") { "Green" } else { "Yellow" })
    if ($vlanDetectada -ne "101") { Write-Host "    - [!] ALERTA: Debería estar en VLAN 101" -ForegroundColor Red }

    Write-Host "`n[+] [PLAN B1] Generando tráfico broadcast..." -ForegroundColor Yellow
    foreach ($i in 1..5) { Test-Connection -ComputerName "192.168.0.255" -Count 1 -Quiet -ErrorAction SilentlyContinue | Out-Null }

    $listaSwitches = @(
        @{ IP = "192.168.0.103"; Nombre = "PB" }, @{ IP = "192.168.0.104"; Nombre = "Mzz A" }, @{ IP = "192.168.0.105"; Nombre = "Mzz B" },
        @{ IP = "192.168.0.106"; Nombre = "P4" }, @{ IP = "192.168.0.107"; Nombre = "P7" }, @{ IP = "192.168.0.108"; Nombre = "P8" }, @{ IP = "192.168.0.109"; Nombre = "P9" }
    )

    function Send-3ComCommand {
        param ($IP, $Commands)
        try {
            $tcp = New-Object System.Net.Sockets.TcpClient
            $connect = $tcp.BeginConnect($IP, 23, $null, $null)
            if (-not $connect.AsyncWaitHandle.WaitOne(1500, $false)) { return $null }
            $tcp.EndConnect($connect)
            $stream = $tcp.GetStream()
            $buffer = New-Object byte[] 65536
            $output = ""
            foreach ($cmd in $Commands) {
                $bytes = [System.Text.Encoding]::ASCII.GetBytes("$cmd`n")
                $stream.Write($bytes, 0, $bytes.Length)
                Start-Sleep -Milliseconds 400
                while ($stream.DataAvailable) {
                    $read = $stream.Read($buffer, 0, $buffer.Length)
                    $output += [System.Text.Encoding]::ASCII.GetString($buffer, 0, $read)
                }
            }
            $tcp.Close()
            return $output
        } catch { return $null }
    }

    Write-Host "`n[+] Escaneando switches en busca de la MAC/IP..." -ForegroundColor Yellow
    $puertosEncontrados = @()
    $puertoTrunkEncontrado = $null

    foreach ($sw in $listaSwitches) {
        Write-Host "-> Verificando Switch $($sw.Nombre) ($($sw.IP))..." -NoNewline
        if (-not (Test-Connection -ComputerName $sw.IP -Count 1 -Quiet)) { Write-Host " [Inalcanzable]" -ForegroundColor DarkGray; continue }

        $cmdsLogin = @("manager", "manager", "display mac-address $mac3com")
        $resMac = Send-3ComCommand -IP $sw.IP -Commands $cmdsLogin

        if ($resMac -notmatch "(GigabitEthernet|Ethernet)") {
            $cmdsArp = @("manager", "manager", "display arp | include $ipLocal")
            $resArp = Send-3ComCommand -IP $sw.IP -Commands $cmdsArp
            if ($resArp -match "(\w{4}-\w{4}-\w{4})") {
                $macArp = $Matches[1]
                $cmdsLogin = @("manager", "manager", "display mac-address $macArp")
                $resMac = Send-3ComCommand -IP $sw.IP -Commands $cmdsLogin
            }
        }

        if ($resMac -match "(GigabitEthernet\d+/\d+/\d+|Ethernet\d+/\d+/\d+)") {
            $interfazTemp = $Matches[1]
            $cmdsConfig = @("manager", "manager", "display current-configuration interface $interfazTemp")
            $resConfig = Send-3ComCommand -IP $sw.IP -Commands $cmdsConfig

            if ($resConfig -match "port link-type trunk") {
                Write-Host " [TRUNK: $interfazTemp]" -ForegroundColor DarkYellow
                if (-not $puertoTrunkEncontrado) { $puertoTrunkEncontrado = @{ Switch = $sw; Puerto = $interfazTemp; Config = $resConfig } }
            } else {
                Write-Host " [¡ENCONTRADO!: $interfazTemp]" -ForegroundColor Green
                $puertosEncontrados += @{ Switch = $sw; Puerto = $interfazTemp; Config = $resConfig }
            }
        } else { Write-Host " [No registrado]" -ForegroundColor DarkGray }
    }

    if ($puertosEncontrados.Count -gt 0) {
        Write-Host "`n====================================================" -ForegroundColor Cyan
        Write-Host " UBICACIÓN DETECTADA (Puerto de Acceso):" -ForegroundColor Yellow
        Write-Host "====================================================" -ForegroundColor Cyan
        foreach ($puerto in $puertosEncontrados) {
            Write-Host "`n Switch: $($puerto.Switch.Nombre) ($($puerto.Switch.IP))" -ForegroundColor Green
            Write-Host " Puerto: $($puerto.Puerto)" -ForegroundColor Green
            if ($puerto.Config -match "(?s)(interface $($puerto.Puerto -replace '/', '\/').*?(?=#|\r?\nreturn))") {
                Write-Host "`nConfiguración:" -ForegroundColor Cyan
                Write-Host "$($Matches[1].Trim())" -ForegroundColor White
                if ($puerto.Config -match "port access vlan (\d+)") {
                    $vlanPuerto = $Matches[1]
                    Write-Host "`n[INFO] VLAN del puerto: $vlanPuerto" -ForegroundColor Cyan
                    if ($vlanPuerto -ne "101") { Write-Host "[!] ALERTA: Debería estar en VLAN 101, está en VLAN $vlanPuerto" -ForegroundColor Red }
                }
            }
        }
    } elseif ($puertoTrunkEncontrado) {
        Write-Host "`n[!] [ALERTA] Solo se detectó en puerto TRUNK:" -ForegroundColor Yellow
        Write-Host "    Switch: $($puertoTrunkEncontrado.Switch.Nombre)" -ForegroundColor Yellow
        Write-Host "    Puerto: $($puertoTrunkEncontrado.Puerto) (TRUNK)" -ForegroundColor Yellow
        Write-Host "`n[EXPLICACIÓN]:" -ForegroundColor Cyan
        Write-Host "    - El puerto trunk lleva tráfico de múltiples VLANs" -ForegroundColor Gray
        Write-Host "    - Tu equipo NO está conectado físicamente ahí" -ForegroundColor Gray
        Write-Host "    - El tráfico pasa por el trunk porque está en VLAN $vlanDetectada" -ForegroundColor Gray
    } else {
        Write-Host "`n[!] No se detectó el puerto automáticamente." -ForegroundColor Red
    }

    Write-Host "`n[?] ¿Deseas consultar manualmente puertos de acceso?" -ForegroundColor Yellow
    $opc = Read-Host "    (S/N)"
    if ($opc -eq "S" -or $opc -eq "s") {
        $continuar = $true
        while ($continuar) {
            Write-Host "`nSelecciona el Switch:" -ForegroundColor Cyan
            for ($i=0; $i -lt $listaSwitches.Count; $i++) { Write-Host "  $($i+1). $($listaSwitches[$i].Nombre) ($($listaSwitches[$i].IP))" }
            $swIdx = Read-Host "`nOpción (1-7)"
            
            if ($swIdx -match '^\d+$' -and [int]$swIdx -ge 1 -and [int]$swIdx -le 7) {
                $swIdx = [int]$swIdx - 1
                $numPort = Read-Host "Ingresa el número de puerto (ejemplo: 5 o GigabitEthernet1/0/5)"
                if ($numPort -match '^\d+$') { $numPort = "GigabitEthernet1/0/$numPort" }
                $swTarget = $listaSwitches[$swIdx]

                Write-Host "`n[+] Consultando $numPort en Switch $($swTarget.Nombre)..." -ForegroundColor Yellow
                $cmdsManual = @("manager", "manager", "display current-configuration interface $numPort")
                $resManual = Send-3ComCommand -IP $swTarget.IP -Commands $cmdsManual
                
                if ($resManual -match "(?s)(interface $numPort.*?(?=#|\r?\nreturn))") {
                    $configPuerto = $Matches[1].Trim()
                    Write-Host "`n====================================================" -ForegroundColor Cyan
                    Write-Host $configPuerto -ForegroundColor Green
                    Write-Host "====================================================" -ForegroundColor Cyan
                    
                    if ($configPuerto -match "port link-type trunk") {
                        Write-Host "[!] Este es un puerto TRUNK (uplink)" -ForegroundColor Red
                    } else {
                        Write-Host "[✓] Este es un puerto de acceso" -ForegroundColor Green
                        if ($configPuerto -match "port access vlan (\d+)") {
                            $vlanPuerto = $Matches[1]
                            Write-Host "`n[INFO] VLAN configurada: $vlanPuerto" -ForegroundColor Cyan
                            if ($vlanPuerto -ne "101") { Write-Host "[!] ALERTA: Debería ser VLAN 101, es VLAN $vlanPuerto" -ForegroundColor Red }
                        }
                    }
                    Write-Host "`n[?] ¿Es este el puerto correcto?" -ForegroundColor Yellow
                    if ((Read-Host "    (S/N)") -match "^[Ss]$") {
                        Write-Host "`n[✓] Puerto confirmado: $($swTarget.Nombre) - $numPort" -ForegroundColor Green
                        $continuar = $false
                    }
                } else { Write-Host "[!] No se pudo obtener la configuración." -ForegroundColor Red }
                
                if ($continuar) {
                    if ((Read-Host "`n[?] ¿Consultar otro puerto? (S/N)") -notmatch "^[Ss]$") { $continuar = $false }
                }
            } else { Write-Host "`n[!] Opción inválida." -ForegroundColor Red }
        }
    }
    Pause
}

function Ejecutar-InstaladorSoftware {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host "`n[X] Winget no está disponible en este sistema." -ForegroundColor Red; Start-Sleep -Seconds 3; return
    }
    do {
        Clear-Host
        Write-Host "=========================================" -ForegroundColor Cyan
        Write-Host "     INSTALADOR DE SOFTWARE (WINGET)     " -ForegroundColor Yellow
        Write-Host "=========================================" -ForegroundColor Cyan
        Write-Host "1. Google Chrome`n2. 7-Zip`n3. Notepad++`n4. AnyDesk`n5. INSTALAR COMBO COMPLETO`n6. Reparar catálogo Winget`n7. Volver al menú principal"
        Write-Host "=========================================" -ForegroundColor Cyan
        $subSoft = Read-Host "Selecciona una opción (1-7)"
        $params = "--silent --accept-source-agreements --accept-package-agreements --disable-interactivity"
        switch ($subSoft) {
            "1" { winget install --id Google.Chrome $params }
            "2" { winget install --id 7zip.7zip $params }
            "3" { winget install --id Notepad++.Notepad++ $params }
            "4" { winget install --id AnyDeskSoftwareGmbH.AnyDesk $params }
            "5" {
                Write-Host "`n[+] Instalando combo..." -ForegroundColor Green
                winget install --id Google.Chrome, 7zip.7zip, Notepad++.Notepad++, AnyDeskSoftwareGmbH.AnyDesk $params
                Write-Host "[✓] Proceso finalizado." -ForegroundColor Yellow; Start-Sleep -Seconds 2
            }
            "6" { winget source reset --force; winget source update; Write-Host "[✓] Catálogo reparado." -ForegroundColor Yellow; Start-Sleep -Seconds 3 }
            "7" { return }
        }
    } while ($subSoft -ne "7")
}

function Analizar-Servidor-CAS01 {
    Clear-Host
    Write-Host "====================================================" -ForegroundColor Cyan
    Write-Host "   INVACA TOOLS - ANÁLISIS SRVFVICAS01              " -ForegroundColor Yellow
    Write-Host "   SERVIDOR PRINCIPAL Y SUS RELACIONES              " -ForegroundColor Cyan
    Write-Host "====================================================" -ForegroundColor Cyan

    $servidorNombre = "SRVFVICAS01"
    $servidorIP = "192.168.0.13"
    
    # Lista de otros servidores para analizar conexiones
    $otrosServidores = @(
        @{ Nombre = "SRVIVCDC01"; IP = "192.168.0.14" },
        @{ Nombre = "SRVSTIWDS"; IP = "192.168.0.15" },
        @{ Nombre = "SRVSTIBLADE06"; IP = "192.168.0.16" },
        @{ Nombre = "SRVFVIBI04"; IP = "192.168.0.17" },
        @{ Nombre = "IVCQNAP01"; IP = "192.168.0.18" },
        @{ Nombre = "IVCQNAP02"; IP = "192.168.0.19" },
        @{ Nombre = "ENTRAPASS"; IP = "192.168.0.20" }
    )

    Write-Host "`n[+] Objetivo: Analizar $servidorNombre ($servidorIP)" -ForegroundColor Green
    Write-Host "    Fecha: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')" -ForegroundColor Gray
    Write-Host "    Analizado por: $env:USERNAME en $env:COMPUTERNAME" -ForegroundColor Gray

    # =========================================================================
    # FASE 1: Conectividad Básica
    # =========================================================================
    Write-Host "`n[FASE 1] Verificando conectividad..." -ForegroundColor Yellow
    $ping = Test-Connection -ComputerName $servidorIP -Count 4 -Quiet -ErrorAction SilentlyContinue
    
    if ($ping) {
        Write-Host "    [OK] Servidor responde a ping" -ForegroundColor Green
        $latencia = (Test-Connection -ComputerName $servidorIP -Count 1 | Select-Object -ExpandProperty ResponseTime)
        Write-Host "    Latencia: ${latencia}ms" -ForegroundColor Gray
    } else {
        Write-Host "    [FAIL] Servidor no responde a ping" -ForegroundColor Red
        Write-Host "    Posible causa: Firewall bloquea ICMP o servidor apagado" -ForegroundColor Yellow
    }

    # =========================================================================
    # FASE 2: Escaneo de Puertos
    # =========================================================================
    Write-Host "`n[FASE 2] Escaneando puertos..." -ForegroundColor Yellow
    
    $puertosComunes = @{
        21 = "FTP"; 22 = "SSH"; 23 = "Telnet"; 25 = "SMTP"; 53 = "DNS"
        80 = "HTTP"; 110 = "POP3"; 135 = "RPC"; 139 = "NetBIOS"; 143 = "IMAP"
        389 = "LDAP/AD"; 443 = "HTTPS"; 445 = "SMB"; 636 = "LDAPS"
        993 = "IMAPS"; 995 = "POP3S"; 1433 = "SQL Server"; 1521 = "Oracle"
        3306 = "MySQL"; 3389 = "RDP"; 5432 = "PostgreSQL"; 5900 = "VNC"
        8080 = "HTTP Alt"; 8443 = "HTTPS Alt"; 9090 = "Web Admin"
    }

    $puertosAbiertos = @()
    foreach ($puerto in $puertosComunes.Keys) {
        try {
            $tcp = New-Object System.Net.Sockets.TcpClient
            $tcp.ReceiveTimeout = 1000
            $connect = $tcp.BeginConnect($servidorIP, $puerto, $null, $null)
            if ($connect.AsyncWaitHandle.WaitOne(1000, $false)) {
                $tcp.EndConnect($connect)
                $puertosAbiertos += @{ Puerto = $puerto; Servicio = $puertosComunes[$puerto] }
                Write-Host "    [OPEN] Puerto $puerto - $($puertosComunes[$puerto])" -ForegroundColor Green
            }
            $tcp.Close()
        } catch {}
    }

    if ($puertosAbiertos.Count -eq 0) {
        Write-Host "    [!] No se encontraron puertos abiertos" -ForegroundColor Red
    } else {
        Write-Host "    [OK] $($puertosAbiertos.Count) puertos abiertos detectados" -ForegroundColor Green
    }

    # =========================================================================
    # FASE 3: Identificación de Roles
    # =========================================================================
    Write-Host "`n[FASE 3] Roles detectados:" -ForegroundColor Yellow
    $rolesDetectados = @()
    
    if (389 -in $puertosAbiertos.Puerto) { $rolesDetectados += "Active Directory/LDAP" }
    if (1433 -in $puertosAbiertos.Puerto) { $rolesDetectados += "SQL Server" }
    if (80 -in $puertosAbiertos.Puerto -or 443 -in $puertosAbiertos.Puerto -or 8080 -in $puertosAbiertos.Puerto) { 
        $rolesDetectados += "Servidor Web (IIS/Apache/Nginx)" 
    }
    if (445 -in $puertosAbiertos.Puerto -or 139 -in $puertosAbiertos.Puerto) { 
        $rolesDetectados += "Servidor de Archivos (SMB/CIFS)" 
    }
    if (25 -in $puertosAbiertos.Puerto -or 110 -in $puertosAbiertos.Puerto -or 143 -in $puertosAbiertos.Puerto) { 
        $rolesDetectados += "Servidor de Correo" 
    }
    if (3389 -in $puertosAbiertos.Puerto) { $rolesDetectados += "Escritorio Remoto (RDP)" }
    if (53 -in $puertosAbiertos.Puerto) { $rolesDetectados += "Servidor DNS" }
    if (21 -in $puertosAbiertos.Puerto) { $rolesDetectados += "Servidor FTP" }

    foreach ($rol in $rolesDetectados) {
        Write-Host "    • $rol" -ForegroundColor Cyan
    }

    # =========================================================================
    # FASE 4: Conexiones ACTIVAS desde TU máquina hacia SRVFVICAS01
    # =========================================================================
    Write-Host "`n[FASE 4] Tus conexiones activas HACIA $servidorNombre..." -ForegroundColor Yellow
    
    $conexionesLocales = netstat -ano | Select-String $servidorIP
    if ($conexionesLocales) {
        Write-Host "    [OK] Conexiones establecidas desde tu equipo:" -ForegroundColor Green
        foreach ($conn in $conexionesLocales) {
            Write-Host "        $conn" -ForegroundColor Gray
        }
        
        # Identificar qué tipo de conexión es
        foreach ($conn in $conexionesLocales) {
            $connStr = $conn.ToString()
            if ($connStr -match '3389') {
                Write-Host "        → Conexión RDP (Escritorio Remoto)" -ForegroundColor Yellow
            }
            if ($connStr -match '445|139') {
                Write-Host "        → Conexión SMB (Archivos compartidos)" -ForegroundColor Yellow
            }
            if ($connStr -match '80|443|8080') {
                Write-Host "        → Conexión HTTP/HTTPS (Web)" -ForegroundColor Yellow
            }
        }
    } else {
        Write-Host "    [!] No tienes conexiones activas hacia este servidor" -ForegroundColor Yellow
    }

    # =========================================================================
    # FASE 5: ¿Quién MÁS se conecta a SRVFVICAS01? (Desde otros servidores)
    # =========================================================================
    Write-Host "`n[FASE 5] Verificando otros servidores que usan $servidorNombre..." -ForegroundColor Yellow
    Write-Host "    Analizando $($otrosServidores.Count) servidores conocidos..." -ForegroundColor Gray
    
    foreach ($otroSrv in $otrosServidores) {
        Write-Host "`n    Verificando $($otroSrv.Nombre) ($($otroSrv.IP))..." -NoNewline
        
        try {
            # Intentar ver si hay conexión desde ese servidor (requeriría acceso remoto)
            # Por ahora, solo verificamos si responde
            if (Test-Connection -ComputerName $otroSrv.IP -Count 1 -Quiet -ErrorAction SilentlyContinue) {
                Write-Host " [EN LÍNEA]" -ForegroundColor Green
                
                # Verificar si tiene puertos abiertos hacia CAS01
                # Esto es una aproximación - idealmente necesitarías acceso a cada servidor
            } else {
                Write-Host " [OFFLINE]" -ForegroundColor Red
            }
        } catch {
            Write-Host " [ERROR]" -ForegroundColor Red
        }
    }

    # =========================================================================
    # FASE 6: Recursos Compartidos en SRVFVICAS01
    # =========================================================================
    Write-Host "`n[FASE 6] Recursos compartidos EN $servidorNombre..." -ForegroundColor Yellow
    
    # Intentar listar shares (requiere permisos)
    try {
        # Esto requiere credenciales o permisos adecuados
        Write-Host "    [INFO] Para ver recursos compartidos, necesitas:" -ForegroundColor Yellow
        Write-Host "        - Credenciales de administrador del servidor" -ForegroundColor Gray
        Write-Host "        - O permisos de lectura en el servidor" -ForegroundColor Gray
        Write-Host "    Comando manual: net view \\$servidorIP" -ForegroundColor Gray
    } catch {
        Write-Host "    [!] No se pudieron listar recursos compartidos" -ForegroundColor Red
    }

    # =========================================================================
    # FASE 7: Configuración de WinRM para acceso remoto
    # =========================================================================
    Write-Host "`n[FASE 7] Configurando acceso remoto (WinRM)..." -ForegroundColor Yellow
    Write-Host "    [INFO] Para obtener información detallada del servidor:" -ForegroundColor Yellow
    Write-Host "    1. Ejecuta en PowerShell (como Admin) en TU equipo:" -ForegroundColor Gray
    Write-Host "       Set-Item WSMan:\localhost\Client\TrustedHosts -Value '192.168.0.13' -Force" -ForegroundColor White
    Write-Host "    2. Luego responde 'S' cuando pregunte por credenciales" -ForegroundColor Gray
    Write-Host "    3. Usa credenciales de administrador del servidor" -ForegroundColor Gray

    # =========================================================================
    # RESUMEN FINAL
    # =========================================================================
    Write-Host "`n====================================================" -ForegroundColor Cyan
    Write-Host "   RESUMEN DEL ANÁLISIS - $servidorNombre" -ForegroundColor Yellow
    Write-Host "====================================================" -ForegroundColor Cyan

    Write-Host "`nSERVIDOR: $servidorNombre ($servidorIP)" -ForegroundColor White
    Write-Host "Estado: $(if ($ping) { 'EN LÍNEA' } else { 'FUERA DE LÍNEA' })" -ForegroundColor $(if ($ping) { 'Green' } else { 'Red' })
    
    Write-Host "`nROLES DETECTADOS:" -ForegroundColor Green
    if ($rolesDetectados.Count -gt 0) {
        foreach ($rol in $rolesDetectados) {
            Write-Host "  • $rol" -ForegroundColor Cyan
        }
    } else {
        Write-Host "  [!] No se pudieron identificar roles específicos" -ForegroundColor Yellow
    }

    Write-Host "`nPUERTOS ABIERTOS: $($puertosAbiertos.Count)" -ForegroundColor White
    foreach ($p in $puertosAbiertos) {
        Write-Host "  • Puerto $($p.Puerto) - $($p.Servicio)" -ForegroundColor Gray
    }

    Write-Host "`n[INTERPRETACIÓN]:" -ForegroundColor Yellow
    Write-Host "  SRVFVICAS01 parece ser un servidor que proporciona:" -ForegroundColor White
    
    if ("Servidor Web (IIS/Apache/Nginx)" -in $rolesDetectados) {
        Write-Host "    ✓ Servicios web (intranet, aplicaciones web)" -ForegroundColor Green
    }
    if ("Servidor de Archivos (SMB/CIFS)" -in $rolesDetectados) {
        Write-Host "    ✓ Almacenamiento de archivos compartidos" -ForegroundColor Green
    }
    if ("Escritorio Remoto (RDP)" -in $rolesDetectados) {
        Write-Host "    ✓ Acceso remoto para administración" -ForegroundColor Green
    }
    if ("Active Directory/LDAP" -in $rolesDetectados) {
        Write-Host "    ✓ Autenticación de dominio" -ForegroundColor Green
    }

    Write-Host "`n[RECOMENDACIONES]:" -ForegroundColor Yellow
    Write-Host "  1. Configurar WinRM (TrustedHosts) para análisis profundo" -ForegroundColor Gray
    Write-Host "  2. Documentar qué aplicaciones web hostea (puertos 80/443)" -ForegroundColor Gray
    Write-Host "  3. Identificar qué carpetas comparte (puerto 445)" -ForegroundColor Gray
    Write-Host "  4. Verificar quién tiene acceso RDP (puerto 3389)" -ForegroundColor Gray
    Write-Host "  5. Revisar logs de IIS para ver qué aplicaciones sirve" -ForegroundColor Gray

    Write-Host "`n====================================================" -ForegroundColor Cyan
    
    # Exportar reporte
    Write-Host "`n[?] ¿Exportar este análisis a archivo?" -ForegroundColor Yellow
    if ((Read-Host "    (S/N)") -match '^[Ss]$') {
        $rutaDesktop = [System.IO.Path]::Combine($env:USERPROFILE, "Desktop")
        $archivoReporte = "$rutaDesktop\Analisis_$servidorNombre_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
        
        $contenido = @"
ANÁLISIS DE SERVIDOR - INVACA TOOLS
Fecha: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')
Analizado por: $env:USERNAME

SERVIDOR: $servidorNombre
IP: $servidorIP
Estado: $(if ($ping) { 'EN LÍNEA' } else { 'FUERA DE LÍNEA' })

ROLES DETECTADOS:
$($rolesDetectados -join "`n")

PUERTOS ABIERTOS:
$($puertosAbiertos | ForEach-Object { "Puerto $($_.Puerto) - $($_.Servicio)" } | Out-String)

RECOMENDACIONES:
1. Configurar WinRM (TrustedHosts) para análisis profundo
2. Documentar qué aplicaciones web hostea (puertos 80/443)
3. Identificar qué carpetas comparte (puerto 445)
4. Verificar quién tiene acceso RDP (puerto 3389)
5. Revisar logs de IIS para ver qué aplicaciones sirve
"@
        
        $contenido | Out-File -FilePath $archivoReporte -Encoding UTF8
        Write-Host "[OK] Reporte guardado en: $archivoReporte" -ForegroundColor Green
    }

    Pause
}

# =========================================================================
# BUCLE PRINCIPAL
# =========================================================================
do {
    Mostrar-Menu
    $opcion = Read-Host "Selecciona una opción (1-10 o S)"
    
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
        "10" { Analizar-Servidor-CAS01 }
        "S" { Write-Host "`nSaliendo de INVACA Tools. ¡Listo por hoy!" -ForegroundColor Yellow; Start-Sleep -Seconds 1; exit }
        "s" { Write-Host "`nSaliendo de INVACA Tools. ¡Listo por hoy!" -ForegroundColor Yellow; Start-Sleep -Seconds 1; exit }
        default { Write-Host "`nOpción no válida, intenta de nuevo." -ForegroundColor Red; Start-Sleep -Seconds 2 }
    }
} while ($true)
