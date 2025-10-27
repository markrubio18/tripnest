import SwiftUI

struct InviteFriendsView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Invite Your Friends!")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Share this link with your friends to invite them to your group.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                VStack {
                    Text("https://tripnest.app/invite/A7B3C9")
                        .font(.body)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)

                    Button(action: {
                        // In a real app, this would copy the link to the clipboard.
                    }) {
                        Text("Copy Link")
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()

                Spacer()
            }
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct InviteFriendsView_Previews: PreviewProvider {
    static var previews: some View {
        InviteFriendsView()
    }
}
