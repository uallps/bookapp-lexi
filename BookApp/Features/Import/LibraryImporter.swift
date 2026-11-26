#if Importar
import Foundation

/// O8 (Importar). Lee un CSV con el mismo formato que O7 y devuelve los libros que se añaden
/// y cuántos se han ignorado. Es Swift puro: no depende de vistas ni del ViewModel.
enum LibraryImporter {
    /// Nombre del fichero que se lee de Documentos.
    static let filename = "books-import.csv"

    struct Result: Equatable {
        let books: [Book]
        let ignored: Int
    }

    enum ImportError: Error { case fileNotFound }

    /// Lee Documentos/books-import.csv y devuelve los libros parseados, filtrando contra `existing`.
    static func importFromDocuments(existing: [Book]) throws -> Result {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let url = documents.appendingPathComponent(filename)
        guard FileManager.default.fileExists(atPath: url.path) else { throw ImportError.fileNotFound }
        let text = try String(contentsOf: url, encoding: .utf8)
        return parse(text, existing: existing)
    }

    /// Parsea el texto CSV. Reglas:
    /// - Se ignoran las líneas sin título.
    /// - Un estado desconocido pasa a *Pendiente*.
    /// - Un libro con el mismo título y autor (sin distinguir mayúsculas) que otro ya existente o recién añadido se ignora.
    /// - La primera línea es la cabecera si coincide con el formato de O7, y no se cuenta como ignorada.
    static func parse(_ text: String, existing: [Book] = []) -> Result {
        var rows = splitRows(text)
        guard !rows.isEmpty else { return Result(books: [], ignored: 0) }
        // La cabecera no cuenta como línea ignorada.
        if isHeader(rows[0]) { rows.removeFirst() }

        var added: [Book] = []
        var ignored = 0
        var seen: Set<String> = Set(existing.map(dedupeKey))

        for row in rows {
            let fields = parseFields(row)
            let title = fields.count > 1 ? fields[1].trimmingCharacters(in: .whitespaces) : ""
            guard !title.isEmpty else {
                ignored += 1
                continue
            }
            let author = fields.count > 2 ? fields[2].trimmingCharacters(in: .whitespaces) : ""
            let statusText = fields.count > 3 ? fields[3].trimmingCharacters(in: .whitespaces) : ""
            let status = ReadingStatus(rawValue: statusText) ?? .pending

            let book = Book(title: title, author: author, status: status)
            let key = dedupeKey(book)
            if seen.contains(key) {
                ignored += 1
                continue
            }
            seen.insert(key)
            added.append(book)
        }
        return Result(books: added, ignored: ignored)
    }

    // MARK: - Internals

    /// Clave para detectar duplicados: título + autor, sin distinguir mayúsculas ni espacios al borde.
    private static func dedupeKey(_ book: Book) -> String {
        book.title.trimmingCharacters(in: .whitespaces).lowercased()
            + "\u{1F}"
            + book.author.trimmingCharacters(in: .whitespaces).lowercased()
    }

    private static func isHeader(_ row: String) -> Bool {
        let fields = parseFields(row).map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
        return fields == ["id", "titulo", "autor", "estado"]
    }

    /// Divide el texto en filas respetando los saltos de línea dentro de campos entrecomillados.
    private static func splitRows(_ text: String) -> [String] {
        var rows: [String] = []
        var current = ""
        var inQuotes = false
        for char in text {
            if char == "\"" { inQuotes.toggle() }
            if (char == "\n" || char == "\r") && !inQuotes {
                if !current.isEmpty { rows.append(current) }
                current = ""
                continue
            }
            current.append(char)
        }
        if !current.isEmpty { rows.append(current) }
        return rows
    }

    /// Parsea una fila CSV en campos, respetando comillas y comillas internas duplicadas.
    private static func parseFields(_ row: String) -> [String] {
        var fields: [String] = []
        var current = ""
        var inQuotes = false
        var i = row.startIndex
        while i < row.endIndex {
            let char = row[i]
            if inQuotes {
                if char == "\"" {
                    let next = row.index(after: i)
                    if next < row.endIndex && row[next] == "\"" {
                        current.append("\"")
                        i = row.index(after: next)
                        continue
                    }
                    inQuotes = false
                } else {
                    current.append(char)
                }
            } else {
                if char == "\"" {
                    inQuotes = true
                } else if char == "," {
                    fields.append(current)
                    current = ""
                } else {
                    current.append(char)
                }
            }
            i = row.index(after: i)
        }
        fields.append(current)
        return fields
    }
}
#endif
