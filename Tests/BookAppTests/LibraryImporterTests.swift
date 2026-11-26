#if Importar
import Foundation
import Testing
@testable import BookApp

@MainActor
@Suite("O8 · Importar biblioteca")
struct LibraryImporterTests {
    @Test("Cabecera y una fila: un libro, cero ignorados")
    func singleBook() {
        let csv = "id,titulo,autor,estado\nxx,Rayuela,Julio Cortázar,Leyendo\n"
        let result = LibraryImporter.parse(csv)
        #expect(result.books.count == 1)
        #expect(result.books[0].title == "Rayuela")
        #expect(result.books[0].author == "Julio Cortázar")
        #expect(result.books[0].status == .reading)
        #expect(result.ignored == 0)
    }

    @Test("Una línea sin título se ignora")
    func ignoresMissingTitle() {
        let csv = "id,titulo,autor,estado\n,,Juan Rulfo,Pendiente\nxx,Pedro Páramo,Juan Rulfo,Leído\n"
        let result = LibraryImporter.parse(csv)
        #expect(result.books.count == 1)
        #expect(result.books[0].title == "Pedro Páramo")
        #expect(result.ignored == 1)
    }

    @Test("Un estado desconocido pasa a Pendiente")
    func unknownStatusFallsBackToPending() {
        let csv = "id,titulo,autor,estado\nxx,1984,George Orwell,marciano\n"
        let result = LibraryImporter.parse(csv)
        #expect(result.books[0].status == .pending)
    }

    @Test("Un título y autor repetidos (sin mayúsculas) se ignoran")
    func ignoresDuplicates() {
        let existing = [Book(title: "Ficciones", author: "Jorge Luis Borges", status: .finished)]
        let csv = "id,titulo,autor,estado\nxx, FICCIONES ,jorge luis borges,Pendiente\n"
        let result = LibraryImporter.parse(csv, existing: existing)
        #expect(result.books.isEmpty)
        #expect(result.ignored == 1)
    }

    @Test("Un duplicado dentro del propio CSV también se ignora")
    func ignoresDuplicatesWithinCSV() {
        let csv = """
        id,titulo,autor,estado
        a,1984,George Orwell,Pendiente
        b,1984,George Orwell,Leído
        """
        let result = LibraryImporter.parse(csv)
        #expect(result.books.count == 1)
        #expect(result.ignored == 1)
    }

    @Test("Un título con comas entrecomillado se parsea bien")
    func parsesQuotedField() {
        let csv = "id,titulo,autor,estado\nxx,\"Love, Death, and Robots\",,Pendiente\n"
        let result = LibraryImporter.parse(csv)
        #expect(result.books[0].title == "Love, Death, and Robots")
    }

    @Test("Las comillas duplicadas se vuelven una sola")
    func parsesEscapedQuotes() {
        let csv = "id,titulo,autor,estado\nxx,\"«Ficciones» dice \"\"él\"\"\",,Pendiente\n"
        let result = LibraryImporter.parse(csv)
        #expect(result.books[0].title == "«Ficciones» dice \"él\"")
    }

    @Test("Viaje de ida y vuelta: exportar + parse devuelve lo mismo")
    func roundTripIsIdempotent() {
        let originals = [
            Book(title: "Rayuela", author: "Julio Cortázar", status: .reading),
            Book(title: "Pedro Páramo, el libro", author: "Juan \"el\" Rulfo", status: .finished)
        ]
        let csv = exportCSV(originals)
        let result = LibraryImporter.parse(csv)
        #expect(result.books.count == originals.count)
        for (parsed, original) in zip(result.books, originals) {
            #expect(parsed.title == original.title)
            #expect(parsed.author == original.author)
            #expect(parsed.status == original.status)
        }
    }

    @Test("Un CSV corrupto no rompe: devuelve lo parseable e ignora el resto")
    func garbageIsSafelyIgnored() {
        let csv = "no es CSV\n\n@#$%^&*\n,,,\n"
        let result = LibraryImporter.parse(csv)
        #expect(result.books.isEmpty)
        #expect(result.ignored >= 1)
    }

    // Reimplementa el escapado de O7 aquí para no acoplar los tests al trait Exportar.
    private func exportCSV(_ books: [Book]) -> String {
        func escape(_ field: String) -> String {
            guard field.contains(",") || field.contains("\"") || field.contains("\n") || field.contains("\r") else {
                return field
            }
            return "\"" + field.replacingOccurrences(of: "\"", with: "\"\"") + "\""
        }
        var lines = ["id,titulo,autor,estado"]
        for book in books {
            lines.append([book.id.uuidString, escape(book.title), escape(book.author), escape(book.status.rawValue)].joined(separator: ","))
        }
        return lines.joined(separator: "\n") + "\n"
    }
}
#endif
