import Foundation

/// Codable: el libro se puede guardar y leer en JSON.
struct Book: Identifiable, Codable {
    var id = UUID()
    var title: String
    var author: String = ""
    var status: ReadingStatus = .pending
}
