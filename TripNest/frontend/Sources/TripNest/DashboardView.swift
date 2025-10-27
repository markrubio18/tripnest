import SwiftUI

struct DashboardView: View {
    @State private var groups: [Group] = []
    @State private var showingCreateGoalView = false

    var body: some View {
        NavigationView {
            List(groups) { group in
                NavigationLink(destination: GroupDetailView(group: group)) {
                    GoalProgressCard(
                        goalName: group.goal?.name ?? group.name,
                        progress: Float((group.currentBalance ?? 0) / (group.goal?.targetAmount ?? 1)),
                        amountSaved: Int(group.currentBalance ?? 0),
                        totalAmount: Int(group.goal?.targetAmount ?? 1)
                    )
                }
            }
            .navigationTitle("Dashboard")
            .toolbar {
                Button(action: {
                    showingCreateGoalView = true
                }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingCreateGoalView, onDismiss: loadGroups) {
                CreateGoalView()
            }
            .onAppear(perform: loadGroups)
        }
    }

    func loadGroups() {
        NetworkManager.shared.getGroups { fetchedGroups in
            if let fetchedGroups = fetchedGroups {
                DispatchQueue.main.async {
                    self.groups = fetchedGroups
                }
            }
        }
    }
}

struct GoalProgressCard: View {
    var goalName: String
    var progress: Float
    var amountSaved: Int
    var totalAmount: Int

    var body: some View {
        VStack(alignment: .leading) {
            Text(goalName)
                .font(.headline)
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .purple))
            HStack {
                Text("$\(amountSaved)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text("of $\(totalAmount)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
