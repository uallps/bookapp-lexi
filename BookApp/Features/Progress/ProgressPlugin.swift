#if Progreso
import Foundation
import Observation

/// Plugin F1 (Progreso). Guarda el progreso de cada libro en su propio fichero y,
/// como plugin de datos, lo borra cuando se borra el libro.
@Observable
final class ProgressPlugin: DataPlugin {
    let name = "Progreso de lectura"

    /// Los progresos guardados. Cada cambio se guarda.
    private(set) var items: [BookProgress] = [] {
        didSet { save() }
    }

    @ObservationIgnored private let storageProvider: ProgressStorageProvider
    @ObservationIgnored private var loaded = false

    init(storageProvider: ProgressStorageProvider = JSONProgressStorageProvider()) {
        self.storageProvider = storageProvider
        _Concurrency.Task { await loadProgress() }
    }

    /// Carga el progreso guardado, solo la primera vez. Si no hay fichero, no hay progreso.
    func loadProgress() async {
        guard !loaded else { return }
        loaded = true
        do {
            items = try await storageProvider.loadProgress()
        } catch {
            print("No se ha cargado el progreso: \(error)")
        }
    }

    /// El progreso de un libro, si tiene.
    func progress(for bookID: UUID) -> BookProgress? {
        items.first { $0.bookID == bookID }
    }

    /// Empieza a registrar el progreso de un libro, en la página 0.
    func start(bookID: UUID, totalPages: Int = 300) {
        guard progress(for: bookID) == nil else { return }
        items.append(BookProgress(bookID: bookID, totalPages: totalPages, currentPage: 0))
    }

    /// Suma (o resta) páginas, sin salirse de 0...totalPages.
    func advance(bookID: UUID, by pages: Int) {
        guard let index = items.firstIndex(where: { $0.bookID == bookID }) else { return }
        let page = items[index].currentPage + pages
        items[index].currentPage = min(max(page, 0), items[index].totalPages)
    }

    // MARK: - DataPlugin: el registro nos avisa al borrar un libro

    func willDeleteBook(_ book: Book) {
        guard progress(for: book.id) != nil else { return }
        items.removeAll { $0.bookID == book.id }
        print("\(name): borrado el progreso de «\(book.title)»")
    }

    func didDeleteBook(id: UUID) {
        print("\(name): el libro \(id) ya no existe")
    }

    private func save() {
        let items = items
        _Concurrency.Task {
            do {
                try await storageProvider.saveProgress(items)
            } catch {
                print("No se ha guardado el progreso: \(error)")
            }
        }
    }
}
#endif
