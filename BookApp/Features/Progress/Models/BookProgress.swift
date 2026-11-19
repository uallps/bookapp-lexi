#if Progreso
import Foundation

/// F1 (Progreso): datos propios de la característica. Van aparte del libro:
/// el libro no sabe que existen, y se enlazan por su id.
struct BookProgress: Identifiable, Codable {
    var bookID: UUID
    var totalPages: Int
    var currentPage: Int

    var id: UUID { bookID }

    /// Ejemplo: «Progreso: 120/300 págs. (40%)».
    var summary: String {
        let percent = totalPages > 0 ? currentPage * 100 / totalPages : 0
        return "Progreso: \(currentPage)/\(totalPages) págs. (\(percent)%)"
    }
}
#endif
