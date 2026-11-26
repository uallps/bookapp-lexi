#if Busqueda
import SwiftUI

/// Controles de búsqueda y orden, pensados para ir dentro del List de BookListView.
/// Recibe el LibraryQuery como @Bindable para que los cambios en texto y orden
/// se propaguen reactivamente a visibleBooks.
struct SearchBarView: View {
    @Bindable var query: LibraryQuery

    var body: some View {
        HStack(spacing: 12) {
            TextField("Buscar por título o autor", text: $query.text)
                .textFieldStyle(.roundedBorder)

            Button(query.order.label) {
                query.order = query.order.next
            }
            .buttonStyle(.bordered)
        }
        .padding(.vertical, 4)
    }
}
#endif
