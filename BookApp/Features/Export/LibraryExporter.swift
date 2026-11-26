#if Exportar
import Foundation

/// O7 (Exportar). Genera un CSV con la biblioteca y lo escribe en la carpeta Documentos.
/// Es Swift puro: no depende de vistas ni plugins, así se puede probar.
enum LibraryExporter {
    /// Nombre del fichero que se escribe en Documentos.
    static let filename = "books-export.csv"

    /// Texto CSV de los libros, con cabecera. Formato que O8 vuelve a leer.
    static func csv(for books: [Book]) -> String {
        var lines = ["id,titulo,autor,estado"]
        for book in books {
            lines.append([
                book.id.uuidString,
                escape(book.title),
                escape(book.author),
                escape(book.status.rawValue)
            ].joined(separator: ","))
        }
        return lines.joined(separator: "\n") + "\n"
    }

    /// Escribe el CSV en Documentos/books-export.csv y devuelve la ruta.
    @discardableResult
    static func export(_ books: [Book]) throws -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        // La carpeta Documentos no existe en todos los sistemas (por ejemplo, un Linux mínimo).
        try FileManager.default.createDirectory(at: documents, withIntermediateDirectories: true)
        let url = documents.appendingPathComponent(filename)
        try csv(for: books).write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    /// Entrecomilla un campo si lleva comas, comillas o saltos de línea; duplica las comillas internas.
    private static func escape(_ field: String) -> String {
        guard field.contains(",") || field.contains("\"") || field.contains("\n") || field.contains("\r") else {
            return field
        }
        return "\"" + field.replacingOccurrences(of: "\"", with: "\"\"") + "\""
    }
}
#endif
