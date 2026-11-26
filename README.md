# BookApp 2026

Ejemplo del profesor de la asignatura Líneas de Productos Software (UAL), curso 2026-27.
Cada sesión tiene una etiqueta con el estado del código al terminarla (`sesion-3`, `sesion-4`, ...):

```sh
git clone https://github.com/uallps/BookApp-2026.git
cd BookApp-2026
git checkout sesion-3
```

El mismo código de la carpeta `BookApp/` funciona en los tres sistemas:

| Sistema | Cómo se ejecuta | Interfaz |
|---|---|---|
| macOS | Abrir `BookApp.xcodeproj` en Xcode y pulsar ▶ | SwiftUI de Apple |
| Linux | `swift run BookApp` (necesita `libgtk-4-dev` y `libfontconfig-dev`) | [SwiftOpenUI](https://github.com/uallps/SwiftOpenUI) con GTK 4 |
| Windows | `swift run BookApp` | SwiftOpenUI con Win32 |

En Linux y Windows, `Package.swift` añade un módulo llamado `SwiftUI` (carpeta `Compat/`)
que reexporta SwiftOpenUI, así que `import SwiftUI` funciona sin cambiar el código.

## Productos (desde la sesión 4)

| Producto | Xcode (Mac) | Linux y Windows |
|---|---|---|
| Base | scheme `BookApp` | `swift run BookApp` |
| Con progreso (F1) | scheme `BookApp Progreso` (target con `Progreso` en *Active Compilation Conditions*) | `swift run --traits Progreso BookApp` |
| Con favoritos (O1) | scheme `BookApp Favoritos` | `swift run --traits Favoritos BookApp` |
| Con sesiones de lectura (O5, requiere F1) | scheme `BookApp Sesiones` (`Sesiones Progreso`) | `swift run --traits Sesiones BookApp` |
| Completa (todas) | — | `swift run --traits Completa BookApp` |

Las pruebas de la lógica de las características se lanzan con `swift test --traits Completa`.

## Almacenamiento (desde la sesión 7)

Los libros se guardan detrás del protocolo `BookStorageProvider`, con dos alternativas (solo una activa):

| Alternativa | Dónde | Cómo se elige |
|---|---|---|
| JSON | `books.json` en la carpeta Documentos | Por defecto, en los tres sistemas |
| SwiftData | `BookApp.store` en Application Support | Ajustes → Almacenamiento (solo macOS e iOS) |

SwiftData solo existe en los sistemas de Apple: su código está dentro de `#if canImport(SwiftData)`,
así que en Linux y Windows no se compila y la app guarda siempre en JSON.

## Plugins

F1 (Progreso) es un plugin (`ProgressPlugin`) con sus propios datos y su propio fichero (`progress.json`).
La app lo registra al arrancar en `PluginRegistry`; al borrar un libro, el registro avisa a los
plugins de datos (`DataPlugin`) para que borren también lo suyo.
