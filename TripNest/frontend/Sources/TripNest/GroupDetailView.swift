import SwiftUI

struct GroupDetailView: View {
    let group: Group

    var body: some View {
        VStack {
            Text(group.name)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            SavingsSummaryView(group: group)

            ChatView()

            MembersListView(members: group.members ?? [])

            Spacer()
        }
        .navigationTitle("Group Details")
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
    var body: some View {
        VStack {
            Text("Group Chat")
                .font(.title2)
                .fontWeight(.semibold)
            // Placeholder for chat
            Text("No messages yet.")
        }
        .padding()
    }
}

struct MembersListView: View {
    let members: [User]

    var body: some View {
        VStack {
            Text("Members")
                .font(.title2)
                .fontWeight(.semibold)
            ForEach(members, id: \.id) { member in
                HStack {
                    Text(member.fullName ?? "No Name")
                    Spacer()
                    // Placeholder for contribution amount
                    Text("$0")
                }
                .padding(.horizontal)
            }
        }
        .padding()
    }
}

struct GroupDetailView_Previews: PreviewProvider {
    static var previews: some View {
        GroupDetailView(group: Group(id: 1, name: "Japan 2026 – Sakura Trip 🌸", description: nil, ownerId: 1))
    }
}
