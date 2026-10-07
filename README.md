# INVACA Tools (`Tools-invaca.ps1`)

`Tools-invaca.ps1` es una solución integral de automatización y administración de sistemas en **PowerShell**, diseñada para ofrecer una consola interactiva de mantenimiento, diagnóstico de infraestructura de red, aprovisionamiento de software y gestión de equipos en entornos corporativos sobre infraestructura Windows.

---

## 🚀 Novedades y Mejoras Clave en la Última Versión

- **Auto-Elevación de Privilegios y Forzado TLS 1.2:** Verificación automática de derechos de administración al inicio. Si se ejecuta sin privilegios elevados, reinterpreta el comando invocando un nuevo proceso de PowerShell con el verbo `RunAs`, forzando el protocolo TLS 1.2 para asegurar la descarga del script en entornos restrictivos.
- **Mapeo y Rastreo Inteligente de Red (Módulo Switch 3Com / H3C):** Nueva función (`Localizar-PuntoEthernet`) para rastrear automáticamente la dirección MAC física del equipo activo a través de sockets TCP/Telnet (Puerto 23) en la topología de switches de la empresa (PB, Mzz A, Mzz B, P4, P7, P8, P9).
- **Aprovisionamiento Automático de Puertos de Switch:** Capacidad para validar y reconfigurar en caliente el puerto del switch identificado aplicando los estándares técnicos de la infraestructura de INVACA:
  - Activación del puerto (`undo shutdown`).
  - Asignación de modo de acceso (`port link-type access`) y asignación de VLAN dinámica según el direccionamiento IP local[cite: 1].
  - Aplicación de supresión de broadcast (`broadcast-suppression pps 3000`)[cite: 1], mitigación de tramas gigantes (`undo jumboframe enable`)[cite: 1], desactivación de STP global e implementación de Spanning Tree Edged Port (`stp disable`, `stp edged-port enable`)[cite: 1].
  - Persistencia de cambios mediante guardado automático (`save`)[cite: 1].
- **Catálogo C2R Ampliado para Microsoft Office:** Opción integrada para lanzar el catálogo web completo de enlaces C2R desde Massgrave[cite: 1].
- **Soporte y Reparación del Gestor Winget:** Submenú enriquecido con una rutina dedicada para resetear y reparar los repositorios/fuentes del motor Winget (prevención y corrección del error `0x8a15000f`)[cite: 1].
- **Soporte de Codificación UTF-8:** Configuración explícita de `$OutputEncoding` para garantizar una correcta renderización de acentos y caracteres especiales en la consola[cite: 1].

---

## 🛠️ Funcionalidades Principales

1. **Activación de Windows / Office:** Integración directa mediante canal seguro con *Microsoft Activation Script* (MAS)[cite: 1].
2. **Optimización del Sistema:** Lanzamiento de la suite de optimización de *Chris Titus Tech* en proceso separado con política `Bypass`[cite: 1].
3. **Auditoría e Inventario Técnico:** Mapeo detallado de especificaciones (Host, Dominio/Grupo de Trabajo, CPU, memoria RAM con tipo de módulo DDR, interfaces de red activas, discos físicos con formato/capacidad, monitores decodificados por EDID y periféricos PnP)[cite: 1]. Permite la exportación directa de la ficha técnica en formato `.txt` al Escritorio del usuario[cite: 1].
4. **Despliegue C2R de Microsoft Office:** Instalador interactivo que gestiona la descarga desatendida mediante `curl.exe` o `System.Net.WebClient` de instaladores oficiales Click-To-Run (Microsoft 365 ProPlus, Office 2021, Office 2019 o URLs personalizadas)[cite: 1].
5. **Mantenimiento y Limpieza Profunda:** Purga de directorios temporales de usuario y sistema (`Temp`, `Prefetch`), seguida de la ejecución secuencial del comprobador de archivos del sistema y salud de imagen (`DISM /RestoreHealth` y `sfc /scannow`)[cite: 1].
6. **Diagnóstico y Reparación de Red Express:** Vaciado de caché DNS (`ipconfig /flushdns`), restablecimiento del catálogo Winsock (`netsh winsock reset`) y prueba de conectividad hacia el segmento local y servidor interno de verificación (`192.168.0.39`)[cite: 1].
7. **Gestión del Print Spooler:** Detención forzada del servicio de impresión, purga completa del directorio de cola de impresión (`C:\Windows\System32\spool\PRINTERS\`) y reinicio automático del servicio[cite: 1].
8. **Instalador de Software Esencial (Winget):** Despliegue silencioso individual o en combo unificado (Google Chrome, 7-Zip, Notepad++, AnyDesk), junto con la herramienta de reparación de catálogos[cite: 1].
9. **Rastreador de Punto Ethernet y Mapeo de Switch:** Búsqueda automática y manual de MACs en la tabla CAM de switches corporativos, con diagnóstico del estado del puerto y asistente de configuración bajo estándares INVACA[cite: 1].

---

## 📂 Estructura del Script y Funciones Integradora

| Función | Descripción Técnica |
| :--- | :--- |
| `Mostrar-Menu` | Renderiza el menú interactivo principal de 9 opciones + salida[cite: 1]. |
| `Ejecutar-Activador` | Invoca la ejecución remota desatendida de MAS[cite: 1]. |
| `Ejecutar-Optimizador` | Inicia el script de Chris Titus Tech en una nueva consola con elevación[cite: 1]. |
| `Mostrar-Especificaciones` | Consulta instancias WMI/CIM (`Win32_ComputerSystem`, `Win32_Processor`, `Win32_PhysicalMemory`, `Win32_NetworkAdapterConfiguration`, `Get-PhysicalDisk`, `WmiMonitorID`) y genera la ficha en pantalla o archivo[cite: 1]. |
| `Ejecutar-InstaladorOffice` | Submenú para la descarga e instalación silenciosa de entornos C2R de Microsoft u origen personalizado[cite: 1]. |
| `Ejecutar-Mantenimiento` | Ejecuta limpieza de archivos temporales e invoca los comandos de la imagen y sistema (`DISM` / `SFC`)[cite: 1]. |
| `Ejecutar-ReparadorRed` | Purga el resolvedor DNS, resetea la pila de sockets y prueba ping a la Puerta de Enlace y host local[cite: 1]. |
| `Ejecutar-DestrabarImpresoras` | Limpia los archivos `.SHD` / `.SPL` en la ruta del Spooler tras detener el servicio[cite: 1]. |
| `Localizar-PuntoEthernet` | Identifica la NIC física activa, consulta tablas MAC en switches 3Com/H3C mediante sockets TCP (`System.Net.Sockets.TcpClient`) y aplica plantillas de configuración CLI[cite: 1]. |
| `Ejecutar-InstaladorSoftware` | Interfaz Wrapper para el gestor `winget` con parámetros de instalación silenciosa y desatendida[cite: 1]. |

---

## 🖥️ Uso e Instalación

1. Abrir una consola de **PowerShell** (no requiere ejecutarse previamente como Administrador gracias al módulo de auto-elevación incorporado)[cite: 1].
2. Ejecutar el comando de invocación rápida:

```powershell
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; irm [https://tinyurl.com/invacagtic](https://tinyurl.com/invacagtic) | iex
