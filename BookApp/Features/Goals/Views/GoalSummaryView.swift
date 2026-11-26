#if Metas
import SwiftUI

struct GoalSummaryView: View {
    let goal: ReadingGoal
    let completedBooks: Int

    var body: some View {
        Text(goal.progressText(completedBooks: completedBooks))
            .font(.headline)
            .accessibilityLabel(goal.progressText(completedBooks: completedBooks))
    }
}
#endif
