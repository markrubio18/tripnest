import SwiftUI

struct GroupDetailView: View {
    @State var group: Group
    @State private var showingAddContributionView = false

    var body: some View {
        VStack {
            Text(group.name)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            SavingsSummaryView(group: group)

            ChatView()

            MembersListView(group: group)

            Spacer()
        }
        .navigationTitle("Group Details")
        .toolbar {
            Button(action: {
                showingAddContributionView = true
            }) {
                Image(systemName: "plus")
            }
        }
        .sheet(isPresented: $showingAddContributionView, onDismiss: reloadGroup) {
            AddContributionView(goalId: group.goal?.id ?? 0)
        }
        .onAppear(perform: reloadGroup)
    }

    private func reloadGroup() {
        // In a real app, you might fetch the latest group data here.
        // For the local version, we can just reload from the DataManager.
        DataManager.shared.getGroups { groups in
            if let updatedGroup = groups?.first(where: { $0.id == self.group.id }) {
                self.group = updatedGroup
            }
        }
    }
}

struct SavingsSummaryView: View {
    let group: Group

    var body: some View {
        VStack {
            Text("Savings Summary")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Total Saved: $\(group.currentBalance ?? 0, specifier: "%.2f") / $\(group.goal?.targetAmount ?? 0, specifier: "%.2f")")
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct ChatView: View {
    @State private var newMessage = ""

    // Mock messages
    let messages = [
        "Alice: Hey everyone! So excited for this trip!",
        "You: Me too! It's going to be amazing.",
        "Bob: Has anyone started looking at flights yet?"
    ]

    var body: some View {
        VStack {
            Text("Group Chat")
                .font(.title2)
                .fontWeight(.semibold)

            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(messages, id: \.self) { message in
                        Text(message)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)

            HStack {
                TextField("Type a message...", text: $newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button(action: {
                    // Simulate sending a message
                    newMessage = ""
                }) {
                    Text("Send")
                }
            }
        }
        .padding()
    }
}

struct MembersListView: View {
    let group: Group

    var body: some View {
        VStack {
            Text("Members")
                .font(.title2)
                .fontWeight(.semibold)
            ForEach(group.members ?? [], id: \.id) { member in
                HStack {
                    Text(member.fullName ?? "No Name")
                    Spacer()
                    Text("$\(contribution(for: member), specifier: "%.2f")")
                }
                .padding(.horizontal)
            }
        }
        .padding()
    }

    private func contribution(for member: User) -> Double {
        return group.goal?.contributions?.filter { $0.userId == member.id }.reduce(0) { $0 + $1.amount } ?? 0
    }
}

struct GroupDetailView_Previews: PreviewProvider {
    static var previews: some View {
        GroupDetailView(group: Group(id: 1, name: "Japan 2026 – Sakura Trip 🌸", description: nil, ownerId: 1))
    }
}
