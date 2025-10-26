import SwiftUI

struct CreateGoalView: View {
    @State private var groupName = ""
    @State private var goalName = ""
    @State private var goalAmount = ""
    @State private var goalDate = Date()
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Form {
            Section(header: Text("Group Details")) {
                TextField("Group Name", text: $groupName)
            }

            Section(header: Text("Goal Details")) {
                TextField("Goal Name", text: $goalName)
                TextField("Goal Amount", text: $goalAmount)
                    .keyboardType(.decimalPad)
                DatePicker("Target Date", selection: $goalDate, displayedComponents: .date)
            }

            Section(header: Text("Invite Friends")) {
                // Placeholder for inviting friends
                Text("Invite friends via link, contacts, or QR code.")
            }

            Button(action: createGroupAndGoal) {
                Text("Create Goal")
            }
        }
        .navigationTitle("Create New Goal")
    }

    func createGroupAndGoal() {
        DataManager.shared.createGroup(name: groupName, description: "") { group in
            guard let group = group else { return }

            let targetAmount = Double(goalAmount) ?? 0

            DataManager.shared.createGoal(name: goalName, targetAmount: targetAmount, targetDate: goalDate, groupId: group.id) { goal in
                if goal != nil {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}

struct CreateGoalView_Previews: PreviewProvider {
    static var previews: some View {
        CreateGoalView()
    }
}
