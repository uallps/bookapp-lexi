#if Deseos
import Foundation
import Observation

/// Datos persistentes de la lista de deseos, independientes de la biblioteca.
@Observable
final class WishlistPlugin {
    private(set) var items: [WishItem] = [] {
        didSet { save() }
    }

    @ObservationIgnored private let fileURL: URL

    init(filename: String = "wishlist.json") {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        fileURL = documents.appendingPathComponent(filename)
        load()
    }

    func add(title: String, author: String, note: String) {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanTitle.isEmpty else { return }
        items.append(WishItem(
            title: cleanTitle,
            author: author.trimmingCharacters(in: .whitespacesAndNewlines),
            note: note.trimmingCharacters(in: .whitespacesAndNewlines)
        ))
    }

    func update(_ item: WishItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index] = item
    }

    func remove(id: UUID) {
        items.removeAll { $0.id == id }
    }

    /// Promueve el deseo a la biblioteca y lo elimina de la lista.
    func promote(id: UUID, addBook: (String, String) -> Void) {
        guard let item = items.first(where: { $0.id == id }) else { return }
        addBook(item.title, item.author)
        remove(id: id)
    }

    private func load() {
        do {
            let data = try Data(contentsOf: fileURL)
            items = try JSONDecoder().decode([WishItem].self, from: data)
        } catch {
            items = []
        }
    }

    private func save() {
        do {
            try FileManager.default.createDirectory(
                at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try JSONEncoder().encode(items).write(to: fileURL, options: .atomic)
        } catch {
            print("No se ha guardado la lista de deseos: \(error)")
        }
    }
}
#endif
