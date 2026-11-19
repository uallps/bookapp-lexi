/// Almacenamiento en memoria, para pruebas y vistas previas: no escribe nada en disco.
final class MockStorageProvider: BookStorageProvider {
    private var storedBooks: [Book] = [
        Book(title: "Libro de prueba 1", author: "Autor 1"),
        Book(title: "Libro de prueba 2", author: "Autor 2", status: .finished)
    ]

    func loadBooks() async throws -> [Book] {
        storedBooks
    }

    func saveBooks(books: [Book]) async throws {
        storedBooks = books
    }
}
