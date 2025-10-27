import SwiftUI

struct InviteFriendsView: View {
    @State private var email = ""
    let groupId: Int
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Invite a Friend")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Enter the email of the friend you want to invite.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button(action: inviteFriend) {
                    Text("Invite")
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()

                Spacer()
            }
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }

    private func inviteFriend() {
        NetworkManager.shared.addMemberToGroup(groupId: groupId, email: email) { group in
            if group != nil {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct InviteFriendsView_Previews: PreviewProvider {
    static var previews: some View {
        InviteFriendsView(groupId: 1)
    }
}
