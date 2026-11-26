import SwiftUI

/// Los plugins de la app. Se crean y se registran una sola vez, al arrancar, y llegan
/// a las vistas por el entorno. Cada característica añade aquí, dentro de su `#if`:
/// una propiedad, su `register(...)` y su `.environment(...)`.
final class AppPlugins {
#if Progreso
    let progress = ProgressPlugin()
#endif

    init() {
#if Progreso
        PluginRegistry.shared.register(progress)
#endif
    }
}

extension View {
    /// Pone cada plugin compilado en el entorno, para que las vistas lo lean con `@Environment`.
    func withPlugins(_ plugins: AppPlugins) -> some View {
        self
#if Progreso
            .environment(plugins.progress)
#endif
    }
}
