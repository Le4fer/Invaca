[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$esAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $esAdmin) {
    Write-Host '`n[!] INVACA Tools requiere permisos de Administrador.' -ForegroundColor Yellow
    Start-Process powershell.exe -Verb RunAs -ArgumentList '-NoExit', '-ExecutionPolicy', 'Bypass', '-File', $MYINVOCATION.MyCommand.Path
    exit
}

$OutputEncoding = [System.Text.Encoding]::UTF8

function Mostrar-Menu {
    Clear-Host
    Write-Host '=========================================' -ForegroundColor Cyan
    Write-Host '             INVACA TOOLS                ' -ForegroundColor Yellow
    Write-Host '=========================================' -ForegroundColor Cyan
    Write-Host '1. Activar Windows / Office (MAS)'
    Write-Host '2. Optimizar Sistema (Chris Titus Tech)'
    Write-Host '3. Especificaciones y Diagnostico del Equipo'
    Write-Host '4. Instalar Microsoft Office'
    Write-Host '5. Mantenimiento y Limpieza del Sistema'
    Write-Host '6. Diagnostico y Reparacion de Red Express'
    Write-Host '7. Destrabar Cola de Impresion (Spooler)'
    Write-Host '8. Instalador de Software Esencial (Winget)'
    Write-Host '9. Localizar Punto Ethernet / Mapear Puerto de Switch'
    Write-Host 'S. Salir'
    Write-Host '=========================================' -ForegroundColor Cyan
}

function Ejecutar-Activador {
    Write-Host '`n[+] Lanzando Microsoft Activation Script (MAS)...' -ForegroundColor Green
    irm https://get.activated.win | iex
}

function Ejecutar-Optimizador {
    Write-Host '`n[+] Lanzando Herramienta de Optimizacion...' -ForegroundColor Green
    $cmd = '[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iwr -useb https://christitus.com/win | iex'
    Start-Process powershell.exe -Verb RunAs -ArgumentList '-NoExit', '-ExecutionPolicy', 'Bypass', '-Command', $cmd
    Start-Sleep -Seconds 2
}

function Ejecutar-InstaladorOffice {
    do {
        Clear-Host
        Write-Host '=========================================' -ForegroundColor Cyan
        Write-Host '      INSTALADOR DE MICROSOFT OFFICE     ' -ForegroundColor Yellow
        Write-Host '=========================================' -ForegroundColor Cyan
        Write-Host '1. Microsoft 365 ProPlus (Espanol x64)'
        Write-Host '2. Office 2021 Professional Plus (Espanol x64)'
        Write-Host '3. Office 2019 Professional Plus (Espanol x64)'
        Write-Host '4. Ingresar URL personalizada de descarga'
        Write-Host '5. Abrir catalogo completo en el navegador (Massgrave)'
        Write-Host '6. Volver al menu principal'
        Write-Host '=========================================' -ForegroundColor Cyan
        
        $subOpcion = Read-Host 'Selecciona una opcion (1-6)'
        $urlOffice = ''
        
        switch ($subOpcion) {
            '1' { $urlOffice = 'https://c2rsetup.officeapps.live.com/c2r/download.aspx?ProductreleaseID=O365ProPlusRetail&platform=x64&language=es-mx&version=O16GA' }
            '2' { $urlOffice = 'https://c2rsetup.officeapps.live.com/c2r/download.aspx?ProductreleaseID=Professional2021Retail&platform=x64&language=es-mx&version=O16GA' }
            '3' { $urlOffice = 'https://c2rsetup.officeapps.live.com/c2r/download.aspx?ProductreleaseID=Professional2019Retail&platform=x64&language=es-mx&version=O16GA' }
            '4' { $urlOffice = Read-Host '`nPegar URL directa del ejecutable (.exe)' }
            '5' { Start-Process 'https://massgrave.dev/office_c2r_links'; Start-Sleep -Seconds 2; continue }
            '6' { return }
            default { Write-Host '`nOpcion no valida.' -ForegroundColor Red; Start-Sleep -Seconds 1; continue }
        }

        if ($urlOffice) {
            $destino = "$env:TEMP\SetupOffice.exe"
            if (Test-Path $destino) { Remove-Item $destino -Force -ErrorAction SilentlyContinue }
            try {
                Write-Host '`n[+] Descargando...' -ForegroundColor Green
                if (Get-Command curl.exe -ErrorAction SilentlyContinue) { 
                    curl.exe -L -s -o $destino $urlOffice 
                } else { 
                    [Net.ServicePointManager]::SecurityProtocol = 'Tls12'
                    (New-Object System.Net.WebClient).DownloadFile($urlOffice, $destino) 
                }
                if ((Test-Path $destino) -and ((Get-Item $destino).Length -gt 0)) {
                    Write-Host '[OK] Descarga completada.' -ForegroundColor Green
                    Start-Process -FilePath $destino
                } else { 
                    Write-Host '[ERROR] Archivo no descargado.' -ForegroundColor Red 
                }
            } catch { 
                Write-Host "`n[ERROR] Error: $_" -ForegroundColor Red 
            }
            Read-Host '`nPresiona Enter para continuar'
        }
    } while ($subOpcion -ne '6')
}

function Mostrar-Especificaciones {
    Clear-Host
    $nombreEquipo = $env:COMPUTERNAME
    $cpu = (Get-CimInstance Win32_Processor).Name.Trim()
    $ramGB = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)
    $net = Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true } | Select-Object -First 1
    $ip = if ($net) { ($net.IPAddress | Where-Object { $_ -match '^\d+\.\d+\.\d+\.\d+$' }) -join ', ' } else { 'Sin Conexion' }
    
    Write-Host '=========================================' -ForegroundColor Cyan
    Write-Host '     FICHA TECNICA DEL SISTEMA           ' -ForegroundColor Yellow
    Write-Host '=========================================' -ForegroundColor Cyan
    Write-Host "  Equipo : $nombreEquipo" -ForegroundColor White
    Write-Host "  CPU    : $cpu" -ForegroundColor White
    Write-Host "  RAM    : $ramGB GB" -ForegroundColor White
    Write-Host "  IP     : $ip" -ForegroundColor White
    Write-Host '=========================================' -ForegroundColor Cyan
    Read-Host 'Presiona Enter para volver'
}

function Ejecutar-Mantenimiento {
    Clear-Host
    Write-Host '1. Limpieza de Temporales'
    Write-Host '2. Reparar Sistema (SFC + DISM)'
    Write-Host '3. Volver'
    $subOp = Read-Host 'Opcion (1-3)'
    if ($subOp -eq '1') {
        Remove-Item -Path "$env:TEMP\*", 'C:\Windows\Temp\*' -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host '[OK] Listo.' -ForegroundColor Green
    } elseif ($subOp -eq '2') {
        Write-Host '[+] Ejecutando DISM y SFC...' -ForegroundColor Green
        dism /online /cleanup-image /restorehealth
        sfc /scannow
        Write-Host '[OK] Finalizado.' -ForegroundColor Green
    }
    Start-Sleep -Seconds 2
}

function Ejecutar-ReparadorRed {
    Clear-Host
    Write-Host '[+] Reparando red...' -ForegroundColor Green
    ipconfig /flushdns | Out-Null
    netsh winsock reset | Out-Null
    Write-Host '[OK] Red reparada.' -ForegroundColor Green
    Start-Sleep -Seconds 2
}

function Ejecutar-DestrabarImpresoras {
    Clear-Host
    Write-Host '[+] Reiniciando Spooler...' -ForegroundColor Green
    Stop-Service -Name Spooler -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:SystemRoot\System32\spool\PRINTERS\*" -Force -Recurse -ErrorAction SilentlyContinue
    Start-Service -Name Spooler
    Write-Host '[OK] Cola de impresion reiniciada.' -ForegroundColor Green
    Start-Sleep -Seconds 2
}

function Localizar-PuntoEthernet {
    Clear-Host
    $nic = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.HardwareInterface -eq $true -and $_.InterfaceDescription -notmatch 'Virtual|Hyper-V|VMware|VirtualBox|vEthernet' } | Select-Object -First 1
    if (-not $nic) { Write-Host '`n[!] No hay interfaz Ethernet fisica.' -ForegroundColor Red; Pause; return }

    $rawMac = $nic.MacAddress.Replace('-','').Replace(':','').ToLower()
    $mac3com = "$($rawMac.Substring(0,4))-$($rawMac.Substring(4,4))-$($rawMac.Substring(8,4))"
    $ipLocal = (Get-NetIPAddress -InterfaceAlias $nic.Name -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object {$_.IPAddress -notlike '169.254.*' }).IPAddress

    Write-Host '`n[+] DATOS LOCALES:' -ForegroundColor Green
    Write-Host "    - Interfaz: $($nic.Name)"
    Write-Host "    - IP Local: $ipLocal"
    Write-Host "    - MAC 3Com: $mac3com"
    
    $vlanDetectada = if ($ipLocal -match '192\.168\.(\d+)\.\d+') { $Matches[1] } else { 'Desconocida' }
    $colorVlan = if ($vlanDetectada -eq '101') { 'Green' } else { 'Yellow' }
    Write-Host "    - VLAN Detectada: $vlanDetectada" -ForegroundColor $colorVlan

    Write-Host '`n[+] Escaneando switches...' -ForegroundColor Yellow
    $listaSwitches = @(
        @{ IP = '192.168.0.103'; Nombre = 'PB' }, @{ IP = '192.168.0.104'; Nombre = 'Mzz A' }, @{ IP = '192.168.0.105'; Nombre = 'Mzz B' },
        @{ IP = '192.168.0.106'; Nombre = 'P4' }, @{ IP = '192.168.0.107'; Nombre = 'P7' }, @{ IP = '192.168.0.108'; Nombre = 'P8' }, @{ IP = '192.168.0.109'; Nombre = 'P9' }
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
            $output = ''
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

    $puertosEncontrados = @()
    $puertoTrunkEncontrado = $null

    foreach ($sw in $listaSwitches) {
        if (-not (Test-Connection -ComputerName $sw.IP -Count 1 -Quiet)) { continue }
        $cmdsLogin = @('manager', 'manager', "display mac-address $mac3com")
        $resMac = Send-3ComCommand -IP $sw.IP -Commands $cmdsLogin

        if ($resMac -notmatch '(GigabitEthernet|Ethernet)') {
            $cmdsArp = @('manager', 'manager', "display arp | include $ipLocal")
            $resArp = Send-3ComCommand -IP $sw.IP -Commands $cmdsArp
            if ($resArp -match '(\w{4}-\w{4}-\w{4})') {
                $macArp = $Matches[1]
                $cmdsLogin = @('manager', 'manager', "display mac-address $macArp")
                $resMac = Send-3ComCommand -IP $sw.IP -Commands $cmdsLogin
            }
        }

        if ($resMac -match '(GigabitEthernet\d+/\d+/\d+|Ethernet\d+/\d+/\d+)') {
            $interfazTemp = $Matches[1]
            $cmdsConfig = @('manager', 'manager', "display current-configuration interface $interfazTemp")
            $resConfig = Send-3ComCommand -IP $sw.IP -Commands $cmdsConfig

            if ($resConfig -match 'port link-type trunk') {
                if (-not $puertoTrunkEncontrado) { $puertoTrunkEncontrado = @{ Switch = $sw; Puerto = $interfazTemp } }
            } else {
                $puertosEncontrados += @{ Switch = $sw; Puerto = $interfazTemp; Config = $resConfig }
            }
        }
    }

    if ($puertosEncontrados.Count -gt 0) {
        Write-Host '`n[OK] UBICACION DETECTADA (Puerto de Acceso):' -ForegroundColor Green
        foreach ($puerto in $puertosEncontrados) {
            Write-Host "  Switch: $($puerto.Switch.Nombre) | Puerto: $($puerto.Puerto)" -ForegroundColor White
            if ($puerto.Config -match 'port access vlan (\d+)') {
                $vlanP = $Matches[1]
                if ($vlanP -ne '101') { Write-Host "  [ALERTA] Esta en VLAN $vlanP, deberia ser 101" -ForegroundColor Red }
            }
        }
    } elseif ($puertoTrunkEncontrado) {
        Write-Host "`n[ALERTA] Solo detectado en TRUNK: $($puertoTrunkEncontrado.Switch.Nombre) -> $($puertoTrunkEncontrado.Puerto)" -ForegroundColor Yellow
    } else {
        Write-Host '`n[!] No detectado automaticamente.' -ForegroundColor Red
    }

    Write-Host '`n[?] Consultar manualmente un puerto?' -ForegroundColor Yellow
    if ((Read-Host '    (S/N)') -match '^[Ss]$') {
        $continuar = $true
        while ($continuar) {
            Write-Host '`nSwitches:' -ForegroundColor Cyan
            for ($i=0; $i -lt $listaSwitches.Count; $i++) { Write-Host "  $($i+1). $($listaSwitches[$i].Nombre)" }
            $swIdx = Read-Host 'Opcion (1-7)'
            
            if ($swIdx -match '^\d+$' -and [int]$swIdx -ge 1 -and [int]$swIdx -le 7) {
                $swTarget = $listaSwitches[[int]$swIdx - 1]
                $numPort = Read-Host 'Numero de puerto (ej: 5)'
                if ($numPort -match '^\d+$') { $numPort = "GigabitEthernet1/0/$numPort" }

                $resManual = Send-3ComCommand -IP $swTarget.IP -Commands @('manager', 'manager', "display current-configuration interface $numPort")
                
                $pattern = '(?s)(interface\s+' + [regex]::Escape($numPort) + '\s+[\s\S]*?)(?=#|\r?\nreturn)'
                if ($resManual -match $pattern) {
                    Write-Host '`n--- CONFIGURACION ---' -ForegroundColor Cyan
                    Write-Host $Matches[1].Trim() -ForegroundColor Green
                    Write-Host '---------------------' -ForegroundColor Cyan
                    
                    if ($Matches[1] -match 'port link-type trunk') {
                        Write-Host '[ALERTA] Es un puerto TRUNK.' -ForegroundColor Red
                    } elseif ($Matches[1] -match 'port access vlan (\d+)') {
                        $vlanP = $Matches[1]
                        Write-Host "INFO: VLAN del puerto: $vlanP" -ForegroundColor Cyan
                        if ($vlanP -ne '101') { Write-Host '[ALERTA] Deberia ser VLAN 101' -ForegroundColor Red }
                    }
                } else {
                    Write-Host '[!] No se pudo leer la configuracion.' -ForegroundColor Red
                }
                
                if ((Read-Host '`n¿Consultar otro? (S/N)') -notmatch '^[Ss]$') { $continuar = $false }
            }
        }
    }
    Pause
}

function Ejecutar-InstaladorSoftware {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host '`n[ERROR] Winget no disponible.' -ForegroundColor Red; Start-Sleep -Seconds 2; return
    }
    do {
        Clear-Host
        Write-Host '1. Google Chrome'
        Write-Host '2. 7-Zip'
        Write-Host '3. Notepad++'
        Write-Host '4. AnyDesk'
        Write-Host '5. COMBO COMPLETO'
        Write-Host '6. Reparar catalogo'
        Write-Host '7. Volver'
        $subSoft = Read-Host 'Opcion (1-7)'
        $params = '--silent --accept-source-agreements --accept-package-agreements --disable-interactivity'
        switch ($subSoft) {
            '1' { winget install --id Google.Chrome $params }
            '2' { winget install --id 7zip.7zip $params }
            '3' { winget install --id Notepad++.Notepad++ $params }
            '4' { winget install --id AnyDeskSoftwareGmbH.AnyDesk $params }
            '5' { winget install --id Google.Chrome, 7zip.7zip, Notepad++.Notepad++, AnyDeskSoftwareGmbH.AnyDesk $params }
            '6' { winget source reset --force; winget source update; Write-Host '[OK] Listo.' -ForegroundColor Green; Start-Sleep -Seconds 2 }
            '7' { return }
        }
    } while ($subSoft -ne '7')
}

do {
    Mostrar-Menu
    $opcion = Read-Host 'Selecciona una opcion (1-9 o S)'
    switch ($opcion) {
        '1' { Ejecutar-Activador }
        '2' { Ejecutar-Optimizador }
        '3' { Mostrar-Especificaciones }
        '4' { Ejecutar-InstaladorOffice }
        '5' { Ejecutar-Mantenimiento }
        '6' { Ejecutar-ReparadorRed }
        '7' { Ejecutar-DestrabarImpresoras }
        '8' { Ejecutar-InstaladorSoftware }
        '9' { Localizar-PuntoEthernet }
        'S' { Write-Host '`nSaliendo...' -ForegroundColor Yellow; Start-Sleep -Seconds 1; exit }
        's' { Write-Host '`nSaliendo...' -ForegroundColor Yellow; Start-Sleep -Seconds 1; exit }
        default { Write-Host '`nOpcion no valida.' -ForegroundColor Red; Start-Sleep -Seconds 1 }
    }
} while ($true)