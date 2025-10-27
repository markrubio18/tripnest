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

            ChatView(group: group)

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
        NetworkManager.shared.getGroups { groups in
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
    @State private var messages: [Message] = []
    let group: Group

    var body: some View {
        VStack {
            Text("Group Chat")
                .font(.title2)
                .fontWeight(.semibold)

            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(messages) { message in
                        Text("\(message.user.fullName ?? "User"): \(message.text)")
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .onAppear(perform: loadMessages)

            HStack {
                TextField("Type a message...", text: $newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button(action: sendMessage) {
                    Text("Send")
                }
            }
        }
        .padding()
    }

    private func loadMessages() {
        NetworkManager.shared.getMessages(groupId: group.id) { fetchedMessages in
            if let fetchedMessages = fetchedMessages {
                DispatchQueue.main.async {
                    self.messages = fetchedMessages
                }
            }
        }
    }

    private func sendMessage() {
        NetworkManager.shared.createMessage(groupId: group.id, text: newMessage) { message in
            if message != nil {
                newMessage = ""
                loadMessages()
            }
        }
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
