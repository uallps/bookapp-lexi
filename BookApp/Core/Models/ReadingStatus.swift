/// Estado de lectura de un libro. Es Codable porque forma parte del libro.
enum ReadingStatus: String, CaseIterable, Codable {
    case pending = "Pendiente"
    case reading = "Leyendo"
    case finished = "Leído"

    /// El estado siguiente, para cambiarlo con un botón: Pendiente → Leyendo → Leído → Pendiente.
    var next: ReadingStatus {
        switch self {
        case .pending: return .reading
        case .reading: return .finished
        case .finished: return .pending
        }
    }
}
