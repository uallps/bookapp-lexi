#if Sesiones && Progreso
import Foundation

/// O5 (Sesiones): un rato de lectura de un libro, con las páginas leídas.
/// Va aparte del libro y se une por su id.
struct ReadingSession: Identifiable, Codable {
    var id = UUID()
    var bookID: UUID
    var date: Date
    var pages: Int
}
#endif
