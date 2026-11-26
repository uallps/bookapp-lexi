#if FechasLectura
import Foundation

/// O10 (Fechas de lectura): datos propios de la característica. Van aparte del libro:
/// el libro no sabe que existen, y se enlazan por su id.
struct ReadingDates: Identifiable, Codable {
    var bookID: UUID
    var startedAt: Date?
    var finishedAt: Date?

    var id: UUID { bookID }

    /// Ejemplo: «Empezado el 3 nov · Terminado el 20 nov».
    var summary: String {
        var parts: [String] = []
        if let startedAt {
            parts.append("Empezado el \(startedAt.formatted(date: .abbreviated, time: .omitted))")
        }
        if let finishedAt {
            parts.append("Terminado el \(finishedAt.formatted(date: .abbreviated, time: .omitted))")
        }
        return parts.isEmpty ? "Sin fechas" : parts.joined(separator: " · ")
    }
}
#endif
