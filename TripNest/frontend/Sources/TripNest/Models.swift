import Foundation

struct User: Codable {
    let id: Int
    let firebaseUid: String
    let email: String
    let fullName: String?
    let isActive: Bool
    let fcmToken: String?
}

struct Group: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String?
    let ownerId: Int
    var goal: Goal?
    var members: [User]?
    var currentBalance: Double?
    var projectedYield: Double?
    var estimatedFinalBalance: Double?
}

struct Goal: Codable, Identifiable {
    let id: Int
    let name: String
    let targetAmount: Double
    let targetDate: Date
    let groupId: Int
    var contributions: [Contribution]?
}

struct Contribution: Codable, Identifiable {
    let id: Int
    let amount: Double
    let timestamp: Date
    let userId: Int
    let goalId: Int
}
