#if Favoritos
import SwiftUI

/// O1 (Favoritos): sección del detalle con el interruptor para marcar el libro.
struct BookFavoriteSection: View {
    let plugin: FavoritesPlugin
    let bookID: UUID

    var body: some View {
        Section(header: Text("Favoritos")) {
            Toggle("Favorito", isOn: Binding(
                get: { plugin.isFavorite(bookID) },
                set: { plugin.setFavorite($0, for: bookID) }
            ))
        }
    }
}
#endif
