#if Deseos
import SwiftUI

struct WishlistView: View {
    @Environment(WishlistPlugin.self) private var wishlist
    let addBook: (String, String) -> Void

    @State private var title = ""
    @State private var author = ""
    @State private var note = ""

    var body: some View {
        List {
            Section("Añadir a deseos") {
                TextField("Título", text: $title)
                TextField("Autor (opcional)", text: $author)
                TextField("Nota", text: $note)
                Button("Añadir deseo", action: addWish)
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            Section("Libros que quiero leer") {
                ForEach(wishlist.items) { item in
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Título", text: binding(for: item, keyPath: \.title))
                            .font(.headline)
                        TextField("Autor", text: binding(for: item, keyPath: \.author))
                        TextField("Nota", text: binding(for: item, keyPath: \.note))
                        HStack {
                            Button("Pasar a la biblioteca") {
                                wishlist.promote(id: item.id, addBook: addBook)
                            }
                            Spacer()
                            Button("Eliminar") { wishlist.remove(id: item.id) }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Deseos")
    }

    private func addWish() {
        wishlist.add(title: title, author: author, note: note)
        title = ""
        author = ""
        note = ""
    }

    private func binding(for item: WishItem, keyPath: WritableKeyPath<WishItem, String>) -> Binding<String> {
        Binding(
            get: { wishlist.items.first(where: { $0.id == item.id })?[keyPath: keyPath] ?? item[keyPath: keyPath] },
            set: { value in
                var updated = wishlist.items.first(where: { $0.id == item.id }) ?? item
                updated[keyPath: keyPath] = value
                wishlist.update(updated)
            }
        )
    }
}
#endif
