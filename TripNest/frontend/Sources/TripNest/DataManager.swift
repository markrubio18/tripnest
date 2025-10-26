import Foundation

class DataManager {
    static let shared = DataManager()
    private var groups: [Group] = []
    private var dataURL: URL?

    private init() {
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            dataURL = documentDirectory.appendingPathComponent("MockData.json")
            loadGroups()
        }
    }

    func loadGroups() {
        guard let url = dataURL else { return }

        if !FileManager.default.fileExists(atPath: url.path) {
            if let bundleURL = Bundle.main.url(forResource: "MockData", withExtension: "json") {
                try? FileManager.default.copyItem(at: bundleURL, to: url)
            }
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            groups = try decoder.decode([Group].self, from: data)
        } catch {
            print("Error decoding mock data: \(error)")
        }
    }

    func saveGroups() {
        guard let url = dataURL else { return }
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(groups)
            try data.write(to: url)
        } catch {
            print("Error encoding mock data: \(error)")
        }
    }

    func getGroups(completion: @escaping ([Group]?) -> Void) {
        completion(groups)
    }

    func createGroup(name: String, description: String, completion: @escaping (Group?) -> Void) {
        let newId = (groups.map { $0.id }.max() ?? 0) + 1
        let newGroup = Group(id: newId, name: name, description: description, ownerId: 1)
        groups.append(newGroup)
        saveGroups()
        completion(newGroup)
    }

    func createGoal(name: String, targetAmount: Double, targetDate: Date, groupId: Int, completion: @escaping (Goal?) -> Void) {
        if let index = groups.firstIndex(where: { $0.id == groupId }) {
            let newGoalId = (groups.compactMap { $0.goal?.id }.max() ?? 0) + 1
            let newGoal = Goal(id: newGoalId, name: name, targetAmount: targetAmount, targetDate: targetDate, groupId: groupId)
            groups[index].goal = newGoal
            saveGroups()
            completion(newGoal)
        } else {
            completion(nil)
        }
    }

    func addContribution(goalId: Int, amount: Double) {
        for i in 0..<groups.count {
            if var goal = groups[i].goal, goal.id == goalId {
                let newContributionId = (goal.contributions?.map { $0.id }.max() ?? 0) + 1
                let newContribution = Contribution(id: newContributionId, amount: amount, timestamp: Date(), userId: 1, goalId: goalId)

                if groups[i].goal?.contributions == nil {
                    groups[i].goal?.contributions = []
                }

                groups[i].goal?.contributions?.append(newContribution)

                if groups[i].currentBalance == nil {
                    groups[i].currentBalance = 0
                }
                groups[i].currentBalance! += amount

                saveGroups()
                break
            }
        }
    }
}
