#if Progreso
import Foundation

/// Dónde guarda el plugin sus datos de progreso. Mismo patrón que `BookStorageProvider`.
protocol ProgressStorageProvider {
    func loadProgress() async throws -> [BookProgress]
    func saveProgress(_ progress: [BookProgress]) async throws
}

/// Guarda el progreso en su propio fichero, progress.json, junto a books.json.
final class JSONProgressStorageProvider: ProgressStorageProvider {
    private let fileURL: URL

    init(filename: String = "progress.json") {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        fileURL = documents.appendingPathComponent(filename)
    }

    func loadProgress() async throws -> [BookProgress] {
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode([BookProgress].self, from: data)
    }

    func saveProgress(_ progress: [BookProgress]) async throws {
        let data = try JSONEncoder().encode(progress)
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try data.write(to: fileURL)
    }
}
#endif
