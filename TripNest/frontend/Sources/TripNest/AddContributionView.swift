import SwiftUI

struct AddContributionView: View {
    @State private var amount = ""
    let goalId: Int
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Form {
            Section(header: Text("Contribution Details")) {
                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)
            }

            Button(action: saveContribution) {
                Text("Save Contribution")
            }
        }
        .navigationTitle("Add Contribution")
    }

    func saveContribution() {
        let contributionAmount = Double(amount) ?? 0
        NetworkManager.shared.addContribution(goalId: goalId, amount: contributionAmount) { contribution in
            if contribution != nil {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct AddContributionView_Previews: PreviewProvider {
    static var previews: some View {
        AddContributionView(goalId: 1)
    }
}
