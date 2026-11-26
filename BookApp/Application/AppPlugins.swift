import SwiftUI

/// Los plugins de la app. Se crean y se registran una sola vez, al arrancar, y llegan
/// a las vistas por el entorno. Cada característica añade aquí, dentro de su `#if`:
/// una propiedad, su `register(...)` y su `.environment(...)`.
final class AppPlugins {
#if Progreso
    let progress = ProgressPlugin()
#endif
#if Favoritos
    let favorites = FavoritesPlugin()
#endif

    init() {
#if Progreso
        PluginRegistry.shared.register(progress)
#endif
#if Favoritos
        PluginRegistry.shared.register(favorites)
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
#if Favoritos
            .environment(plugins.favorites)
#endif
    }
}
