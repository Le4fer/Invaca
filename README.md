# INVACA Tools

`Tools-invaca.ps1` es una utilidad integral de PowerShell diseñada para ofrecer un menú interactivo con herramientas de activación, optimización, mantenimiento, despliegue de software y diagnóstico del sistema en entornos Windows.

## Funcionalidades

- **Activación de Windows / Office:** Integración directa con Microsoft Activation Script (MAS).
- **Optimización del sistema:** Lanzamiento del kit de herramientas de Chris Titus Tech.
- **Auditoría e inventario técnico:** Recopilación detallada de hardware, red, discos, monitores y periféricos, con opción de exportación de ficha técnica a archivo `.txt`.
- **Despliegue de Microsoft Office:** Submenú interactivo para descargar e instalar versiones C2R oficiales (Microsoft 365, Office 2021, Office 2019 o URLs personalizadas) mediante servidores oficiales de Microsoft.
- **Mantenimiento y limpieza:** Eliminación de archivos temporales de sistema y usuario, caché y reparación de integridad del sistema (`SFC` y `DISM`).
- **Diagnóstico y reparación de red express:** Limpieza de caché DNS (`flushdns`), reseteo del catálogo Winsock y pruebas de conectividad en tiempo real (Puerta de enlace e Internet).
- **Gestión de impresión:** Limpieza y reseteo automático de la cola de impresión (Spooler) atascada.
- **Instalador de software esencial (Winget):** Instalación desatendida en lote o individual de programas estándar (Google Chrome, 7-Zip, Notepad++, AnyDesk).

---

## Contenido y Funciones del Script

- `Mostrar-Menu`: Presenta el menú principal interactivo de 9 opciones.
- `Ejecutar-Activador`: Descarga y ejecuta el activador MAS mediante enlace seguro.
- `Ejecutar-Optimizador`: Inicia la suite de optimización de Chris Titus Tech en una nueva ventana con política de ejecución bypass.
- `Mostrar-Especificaciones`: Audita y muestra la ficha técnica en pantalla:
  - Nombre del equipo, dominio o grupo de trabajo.
  - Procesador y memoria RAM (capacidad y tipo de módulo DDR).
  - Configuración IP, puerta de enlace, DNS, MAC y adaptador de red activo.
  - Almacenamiento físico (modelo, tipo de medio y tamaño en GB).
  - Monitores conectados (decodificación EDID).
  - Teclados y mouses PnP detectados.
  - *Opción opcional para exportar el reporte a `Ficha_INVACA_<Equipo>.txt` directamente en el Escritorio.*
- `Ejecutar-InstaladorOffice`: Submenú interactivo para descargar e instalar ejecutables C2R oficiales de Microsoft Office desde servidores CDN o enlaces personalizados.
- `Ejecutar-Mantenimiento`: Purga carpetas Temp/Prefetch y ejecuta secuencialmente `DISM /RestoreHealth` y `sfc /scannow`.
- `Ejecutar-ReparadorRed`: Restablece componentes de red y realiza verificación de conectividad con la puerta de enlace e IP externa (`8.8.8.8`).
- `Ejecutar-DestrabarImpresoras`: Reinicia el servicio `Spooler` y elimina archivos atascados en `C:\Windows\System32\spool\PRINTERS\`.
- `Ejecutar-InstaladorSoftware`: Gestiona instalaciones silenciosas mediante `winget` (individuales o en combo completo de un clic).

---

## Uso

1. Abrir **PowerShell** como **Administrador**.
2. Ejecutar el comando rápido (vía acortador o enlace raw):

```powershell```
`irm [tinyurl.com/invacatools](https://tinyurl.com/invacatools) | iex`

## Elegir una opción del menú principal:

1: Activar Windows / Office (MAS)

2: Optimizar Sistema (Chris Titus Tech)

3: Especificaciones y Diagnóstico del Equipo

4: Instalar Microsoft Office

5: Mantenimiento y Limpieza del Sistema

6: Diagnóstico y Reparación de Red Express

7: Destrabar Cola de Impresión (Spooler)

8: Instalador de Software Esencial (Winget)

9: Salir

## Requisitos
Windows 10/11 o Windows Server con PowerShell 5.1 o superior.

Privilegios de Administrador para ejecutar tareas de mantenimiento, red e instalación de programas.

Conexión a Internet para la descarga de scripts, herramientas externas y paquetes via winget / CDN.

Permisos de ejecución (ExecutionPolicy) habilitados para scripts.

## Notas
Las funciones de instalación de software requieren que el sistema cuente con el gestor de paquetes winget (App Installer).

Las descargas de Office se realizan directamente desde los servidores oficiales de distribución Click-To-Run (C2R) de Microsoft.

Se recomienda ejecutar el mantenimiento y reparación de red con la consola iniciada como Administrador para garantizar el correcto funcionamiento de los comandos del sistema (sfc, dism, netsh).
