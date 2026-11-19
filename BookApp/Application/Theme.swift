import SwiftUI

// El tema de la app: colores y estilos en un solo sitio, añadidos con extensiones.
// Para cambiar el aspecto se toca este fichero, no las vistas.

extension Color {
    /// Color principal de BookApp.
    static let bookAccent = Color(red: 0.19, green: 0.38, blue: 0.58)
}

/// Estilo del texto secundario de las filas (autor, estado, progreso).
struct CaptionStyle: ViewModifier {
    var color: Color = .secondary

    func body(content: Content) -> some View {
        content
            .font(.caption)
            .foregroundColor(color)
    }
}

extension View {
    /// Aplica el estilo de texto secundario: `Text("…").bookCaption()`,
    /// o con otro color: `.bookCaption(color: .red)`.
    func bookCaption(color: Color = .secondary) -> some View {
        modifier(CaptionStyle(color: color))
    }
}

extension ReadingStatus {
    /// Color de cada estado de lectura.
    var color: Color {
        switch self {
        case .pending: return .secondary
        case .reading: return .orange
        case .finished: return .green
        }
    }
}
