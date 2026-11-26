#if Busqueda
import Foundation

/// Orden en el que se muestra la lista de libros.
/// El botón de la lista rota entre estos tres valores, en este orden.
enum SortOrder: String, CaseIterable, Codable {
    case title
    case author
    case status

    /// Texto que se muestra en el botón: "Orden: Título", "Orden: Autor", "Orden: Estado".
    var label: String {
        switch self {
        case .title:  return "Orden: Título"
        case .author: return "Orden: Autor"
        case .status: return "Orden: Estado"
        }
    }

    /// Siguiente valor en la rotación Título → Autor → Estado → Título.
    var next: SortOrder {
        switch self {
        case .title:  return .author
        case .author: return .status
        case .status: return .title
        }
    }
}
#endif

