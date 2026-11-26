import Foundation

/// Guarda una lista de elementos en un fichero JSON de la carpeta Documentos.
/// Es el almacenamiento de los plugins: cada característica usa su propio fichero
/// (`favorites.json`, `sessions.json`...) y nunca toca `books.json`.
struct JSONListStorage<Item: Codable> {
    let fileURL: URL

    init(filename: String) {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        fileURL = documents.appendingPathComponent(filename)
    }

    /// Para pruebas: un fichero concreto, por ejemplo en una carpeta temporal.
    init(fileURL: URL) {
        self.fileURL = fileURL
    }

    /// La lista guardada. Si todavía no hay fichero, la lista está vacía.
    func load() async throws -> [Item] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return [] }
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode([Item].self, from: data)
    }

    func save(_ items: [Item]) async throws {
        let data = try JSONEncoder().encode(items)
        // La carpeta Documentos no existe en todos los sistemas (por ejemplo, un Linux mínimo).
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try data.write(to: fileURL, options: .atomic)
    }
}
