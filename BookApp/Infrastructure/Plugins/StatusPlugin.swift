import Foundation

/// Plugin que reacciona a los cambios de estado de un libro.
/// Separado de DataPlugin para no obligar a todos los plugins a implementarlo.
protocol StatusPlugin: FeaturePlugin {
    /// Se llama después de que el estado de un libro haya cambiado.
    func didChangeStatus(of book: Book, to status: ReadingStatus)
}
