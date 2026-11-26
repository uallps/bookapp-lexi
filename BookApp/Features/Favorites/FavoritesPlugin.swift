#if Favoritos
import Foundation
import Observation

/// Plugin O1 (Favoritos). Guarda qué libros son favoritos en su propio fichero, filtra
/// la lista si se pide y, como plugin de datos, olvida el favorito cuando se borra el libro.
@Observable
final class FavoritesPlugin: DataPlugin {
    let name = "Favoritos"

    /// Los favoritos guardados. Cada cambio se guarda.
    private(set) var items: [FavoriteBook] = [] {
        didSet { save() }
    }

    /// Mostrar solo los favoritos. Es estado de pantalla: no se guarda.
    var onlyFavorites = false

    @ObservationIgnored private let storage: JSONListStorage<FavoriteBook>
    @ObservationIgnored private var loaded = false

    /// Por defecto guarda en favorites.json; en pruebas se le pasa otro fichero.
    init(storage: JSONListStorage<FavoriteBook>? = nil) {
        self.storage = storage ?? JSONListStorage(filename: "favorites.json")
        _Concurrency.Task { await loadFavorites() }
    }

    /// Carga los favoritos guardados, solo la primera vez.
    func loadFavorites() async {
        guard !loaded else { return }
        loaded = true
        do {
            items = try await storage.load()
        } catch {
            print("\(name): no se han cargado los favoritos: \(error)")
        }
    }

    func isFavorite(_ bookID: UUID) -> Bool {
        items.contains { $0.bookID == bookID }
    }

    /// Marca el libro si no lo era y lo desmarca si lo era.
    func toggle(_ bookID: UUID) {
        setFavorite(!isFavorite(bookID), for: bookID)
    }

    /// Marca o desmarca un libro. Marcar dos veces no lo duplica.
    func setFavorite(_ favorite: Bool, for bookID: UUID) {
        guard favorite != isFavorite(bookID) else { return }
        if favorite {
            items.append(FavoriteBook(bookID: bookID))
        } else {
            items.removeAll { $0.bookID == bookID }
        }
    }

    /// Filtro de la lista: con «Solo favoritos» activo, solo pasan los favoritos.
    func matches(_ book: Book) -> Bool {
        !onlyFavorites || isFavorite(book.id)
    }

    /// Cuántos de esos libros son favoritos (para el botón del filtro).
    func count(in books: [Book]) -> Int {
        books.filter { isFavorite($0.id) }.count
    }

    // MARK: - DataPlugin: el registro nos avisa al borrar un libro

    func willDeleteBook(_ book: Book) {
        guard isFavorite(book.id) else { return }
        items.removeAll { $0.bookID == book.id }
        print("\(name): quitado «\(book.title)» de favoritos")
    }

    func didDeleteBook(id: UUID) {}

    private func save() {
        let items = items
        _Concurrency.Task {
            do {
                try await storage.save(items)
            } catch {
                print("\(name): no se han guardado los favoritos: \(error)")
            }
        }
    }
}
#endif
