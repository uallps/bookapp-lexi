#if Metas
import Foundation
import Observation

/// Mantiene una meta por año en goals.json. No depende de la biblioteca ni modifica Book.
@Observable
final class GoalsPlugin: FeaturePlugin {
    let name = "Metas de lectura"

    private(set) var goals: [ReadingGoal] = [] {
        didSet { save() }
    }

    @ObservationIgnored private let fileURL: URL

    init(filename: String = "goals.json") {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        fileURL = documents.appendingPathComponent(filename)
        load()
    }

    func goal(for year: Int = Calendar.current.component(.year, from: Date())) -> ReadingGoal {
        goals.first(where: { $0.year == year }) ?? ReadingGoal(year: year, target: 12)
    }

    func setTarget(_ target: Int, for year: Int = Calendar.current.component(.year, from: Date())) {
        let safeTarget = max(0, target)
        if let index = goals.firstIndex(where: { $0.year == year }) {
            goals[index].target = safeTarget
        } else {
            goals.append(ReadingGoal(year: year, target: safeTarget))
        }
    }

    private func load() {
        do {
            let data = try Data(contentsOf: fileURL)
            goals = try JSONDecoder().decode([ReadingGoal].self, from: data)
        } catch {
            goals = []
        }
    }

    private func save() {
        do {
            try FileManager.default.createDirectory(
                at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try JSONEncoder().encode(goals).write(to: fileURL, options: .atomic)
        } catch {
            print("No se han guardado las metas: \(error)")
        }
    }
}
#endif
