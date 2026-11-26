#if Exportar
import Foundation
import Testing
@testable import BookApp

@MainActor
@Suite("O7 · Exportar biblioteca")
struct LibraryExporterTests {
    @Test("La cabecera va primero y hay una línea por libro")
    func headerAndRows() {
        let books = [
            Book(title: "Rayuela", author: "Julio Cortázar", status: .reading),
            Book(title: "1984", author: "George Orwell", status: .finished)
        ]
        let lines = LibraryExporter.csv(for: books).split(separator: "\n", omittingEmptySubsequences: true)
        #expect(lines.first == "id,titulo,autor,estado")
        #expect(lines.count == books.count + 1)
    }

    @Test("Una biblioteca vacía deja solo la cabecera")
    func emptyLibrary() {
        #expect(LibraryExporter.csv(for: []) == "id,titulo,autor,estado\n")
    }

    @Test("Un título con comas se entrecomilla")
    func escapesCommas() {
        let book = Book(title: "Love, Death, and Robots", author: "", status: .pending)
        let csv = LibraryExporter.csv(for: [book])
        #expect(csv.contains("\"Love, Death, and Robots\""))
    }

    @Test("Las comillas internas se duplican y el campo se entrecomilla")
    func escapesQuotes() {
        let book = Book(title: "«Ficciones» dice \"él\"", author: "", status: .pending)
        let csv = LibraryExporter.csv(for: [book])
        #expect(csv.contains("\"«Ficciones» dice \"\"él\"\"\""))
    }

    @Test("Un salto de línea en el título también entrecomilla")
    func escapesNewline() {
        let book = Book(title: "Línea 1\nLínea 2", author: "", status: .pending)
        let csv = LibraryExporter.csv(for: [book])
        #expect(csv.contains("\"Línea 1\nLínea 2\""))
    }

    @Test("Exportar escribe el fichero y devuelve su ruta")
    func exportWritesFile() throws {
        let books = [Book(title: "Pedro Páramo", author: "Juan Rulfo", status: .finished)]
        let url = try LibraryExporter.export(books)
        defer { try? FileManager.default.removeItem(at: url) }

        #expect(url.lastPathComponent == LibraryExporter.filename)
        let written = try String(contentsOf: url, encoding: .utf8)
        #expect(written == LibraryExporter.csv(for: books))
    }
}
#endif
