#if FechasLectura
import Foundation

/// Dónde guarda el plugin sus datos de fechas. Mismo patrón que `ProgressStorageProvider`.
protocol ReadingDatesStorageProvider {
    func loadDates() async throws -> [ReadingDates]
    func saveDates(_ dates: [ReadingDates]) async throws
}

/// Guarda las fechas de lectura en su propio fichero, reading-dates.json, junto a books.json.
final class JSONReadingDatesStorageProvider: ReadingDatesStorageProvider {
    private let fileURL: URL

    init(filename: String = "reading-dates.json") {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        fileURL = documents.appendingPathComponent(filename)
    }

    func loadDates() async throws -> [ReadingDates] {
        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([ReadingDates].self, from: data)
    }

    func saveDates(_ dates: [ReadingDates]) async throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(dates)
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try data.write(to: fileURL)
    }
}
#endif
