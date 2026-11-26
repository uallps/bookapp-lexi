#if Metas
import SwiftUI

struct GoalSettingsSection: View {
    let plugin: GoalsPlugin

    private var currentGoal: ReadingGoal { plugin.goal() }

    var body: some View {
        Section(header: Text("Meta de lectura")) {
            HStack {
                Text("Objetivo para \(currentGoal.year): \(currentGoal.target) libros")
                Spacer()
                Button("−1") { plugin.setTarget(currentGoal.target - 1, for: currentGoal.year) }
                    .disabled(currentGoal.target == 0)
                Button("+1") { plugin.setTarget(currentGoal.target + 1, for: currentGoal.year) }
            }
        }
    }
}
#endif
