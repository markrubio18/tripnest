import SwiftUI

struct ProfileView: View {
    // Assuming a user object is available. For now, we'll use mock data.
    let user = User(id: 1, firebaseUid: "user1_uid", email: "user1@example.com", fullName: "You", isActive: true, fcmToken: nil)

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray)

                Text(user.fullName ?? "Anonymous")
                    .font(.title)
                    .fontWeight(.bold)

                Text(user.email)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Divider()

                Section(header: Text("Achievements").font(.headline)) {
                    HStack {
                        AchievementBadge(icon: "star.fill", name: "Early Saver")
                        AchievementBadge(icon: "flame.fill", name: "Streak Hero")
                        AchievementBadge(icon: "leaf.fill", name: "Green Saver")
                    }
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Profile")
        }
    }
}

struct AchievementBadge: View {
    let icon: String
    let name: String

    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundColor(.yellow)
            Text(name)
                .font(.caption)
        }
        .padding()
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
