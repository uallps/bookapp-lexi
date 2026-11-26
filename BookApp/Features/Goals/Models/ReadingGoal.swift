#if Metas
import Foundation

struct ReadingGoal: Identifiable, Codable {
    var year: Int
    var target: Int

    var id: Int { year }

    func progressText(completedBooks: Int) -> String {
        let percent = target > 0 ? completedBooks * 100 / target : 0
        return "Meta \(year): \(completedBooks)/\(target) libros (\(percent) %)"
    }
}
#endif
