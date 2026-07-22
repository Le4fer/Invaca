# INVACA Tools

`Tools-invaca.ps1` es una utilidad de PowerShell diseñada para ofrecer un menú interactivo con herramientas de activación, optimización y diagnóstico del sistema en Windows.

## Funcionalidades

- Activar Windows / Office mediante el script MAS (Microsoft Activation Script)
- Ejecutar una herramienta de optimización recomendada por Chris Titus Tech
- Mostrar especificaciones del sistema y diagnóstico de hardware, red y periféricos

## Contenido del script

El script incluye:

- `Mostrar-Menu`: muestra el menú principal con las opciones disponibles.
- `Ejecutar-Activador`: descarga y ejecuta el activador MAS.
- `Ejecutar-Optimizador`: descarga y ejecuta la herramienta de optimización de Chris Titus Tech en una nueva ventana de PowerShell.
- `Mostrar-Especificaciones`: recopila y muestra información del equipo, incluyendo:
  - Nombre del equipo
  - Dominio o grupo de trabajo
  - Procesador
  - Memoria RAM y tipo de módulo
  - Información de red (IP, puerta de enlace, DNS, MAC, adaptador)
  - Discos físicos y tamaño
  - Monitores detectados
  - Teclados y mouse conectados

## Uso

1. Abrir PowerShell como administrador o usuario.
2. Ejecutar:

```powershell
https://tinyurl.com/invacatools
```

4. Elegir una opción del menú:

- `1`: Activar Windows / Office.
- `2`: Optimizar el sistema.
- `3`: Ver especificaciones y diagnóstico.
- `4`: Salir.

## Requisitos

- Windows con PowerShell disponible.
- Conexión a Internet para descargar los scripts externos de activación y optimización.
- Permiso para ejecutar scripts (`ExecutionPolicy` adecuado, por ejemplo `Bypass` o `Unrestricted`).

## Notas

- La opción de activación descarga y ejecuta un script externo. Usar con responsabilidad y revisarlo si es necesario.
- La opción de optimización abre una nueva ventana de PowerShell para ejecutar el instalador de Chris Titus Tech.
- La recopilación de información de hardware usa WMI/CIM; es posible que algunos dispositivos no aparezcan si no están disponibles o si el sistema no provee los datos.

## Licencia

Este archivo de ejemplo no incluye una licencia específica. Puedes añadir una licencia según tus necesidades.
