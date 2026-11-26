#if Favoritos
import SwiftUI

/// O1 (Favoritos): fila de la lista con el botón que muestra solo los favoritos.
struct FavoritesFilterRow: View {
    let plugin: FavoritesPlugin
    /// Cuántos libros de la biblioteca son favoritos.
    let favoriteCount: Int

    var body: some View {
        HStack {
            Button("Solo favoritos: \(plugin.onlyFavorites ? "Sí" : "No")") {
                plugin.onlyFavorites.toggle()
            }
            Text("★ \(favoriteCount)")
                .bookCaption(color: .favoriteStar)
        }
    }
}

extension Color {
    /// Color de la estrella de los favoritos.
    static let favoriteStar = Color(red: 0.85, green: 0.6, blue: 0.1)
}
#endif
