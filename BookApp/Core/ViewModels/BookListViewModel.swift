import Foundation
import Observation

@Observable
final class BookListViewModel {
    /// Cada cambio en la lista (estado, añadir, borrar o editar en el detalle) se guarda.
    var books: [Book] = [
        Book(title: "Don Quijote de la Mancha", author: "Miguel de Cervantes", status: .reading),
        Book(title: "Cien años de soledad", author: "Gabriel García Márquez", status: .finished),
        Book(title: "1984", author: "George Orwell")
    ] {
        didSet { save() }
    }

    @ObservationIgnored private let storageProvider: BookStorageProvider
    @ObservationIgnored private var loaded = false

    /// Por defecto guarda en JSON; en pruebas se le pasa un MockStorageProvider.
    init(storageProvider: BookStorageProvider = JSONStorageProvider()) {
        self.storageProvider = storageProvider
        _Concurrency.Task { await loadBooks() }
    }

    /// Carga los libros guardados, solo la primera vez que se llama.
    /// Si aún no hay fichero, se quedan los libros de ejemplo.
    func loadBooks() async {
        guard !loaded else { return }
        loaded = true
        do {
            books = try await storageProvider.loadBooks()
        } catch {
            print("No se han cargado libros: \(error)")
        }
    }

    /// Cambia el estado de lectura: Pendiente → Leyendo → Leído.
    func changeStatus(id: UUID) {
        guard let index = books.firstIndex(where: { $0.id == id }) else { return }
        books[index].status = books[index].status.next
    }

    func addBook() {
        books.append(Book(title: "Libro de ejemplo", author: "Autor desconocido"))
    }

    /// Borra un libro. El ViewModel no sabe qué plugins hay: avisa al registro
    /// antes y después, y el registro avisa a cada plugin de datos (observador).
    func removeBook(id: UUID) {
        guard let book = book(id: id) else { return }
        PluginRegistry.shared.notifyBookWillBeDeleted(book)
        books.removeAll { $0.id == id }
        PluginRegistry.shared.notifyBookDidDelete(id: id)
    }

    /// El libro con ese id, si sigue en la lista.
    func book(id: UUID) -> Book? {
        books.first { $0.id == id }
    }

    /// Sustituye el libro que tiene el mismo id (lo usa el detalle al editar).
    func updateBook(_ book: Book) {
        guard let index = books.firstIndex(where: { $0.id == book.id }) else { return }
        books[index] = book
    }

    /// Guarda la lista completa. `_Concurrency.Task` es la tarea asíncrona de Swift.
    private func save() {
        let books = books
        _Concurrency.Task {
            do {
                try await storageProvider.saveBooks(books: books)
            } catch {
                print("No se han guardado los libros: \(error)")
            }
        }
    }
}
