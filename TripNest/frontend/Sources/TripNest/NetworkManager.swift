import Foundation
import FirebaseAuth

class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "http://127.0.0.1:8000"

    private init() {}

    private func createAuthenticatedRequest(url: URL, method: String = "GET", body: Data? = nil, completion: @escaping (URLRequest?) -> Void) {
        Auth.auth().currentUser?.getIDToken { token, error in
            if let error = error {
                print("Error getting Firebase ID token: \(error)")
                completion(nil)
                return
            }
            guard let token = token else {
                completion(nil)
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = method
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.httpBody = body
            completion(request)
        }
    }

    func getGroups(completion: @escaping ([Group]?) -> Void) {
        guard let url = URL(string: "\(baseURL)/groups/") else {
            completion(nil)
            return
        }

        createAuthenticatedRequest(url: url) { request in
            guard let request = request else {
                completion(nil)
                return
            }

            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    completion(nil)
                    return
                }

                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let groups = try? decoder.decode([Group].self, from: data)
                completion(groups)
            }.resume()
        }
    }

    func createGroup(name: String, description: String, completion: @escaping (Group?) -> Void) {
        guard let url = URL(string: "\(baseURL)/groups/") else {
            completion(nil)
            return
        }

        let body = ["name": name, "description": description]
        let encodedBody = try? JSONEncoder().encode(body)

        createAuthenticatedRequest(url: url, method: "POST", body: encodedBody) { request in
            guard let request = request else {
                completion(nil)
                return
            }

            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    completion(nil)
                    return
                }

                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let group = try? decoder.decode(Group.self, from: data)
                completion(group)
            }.resume()
        }
    }

    func createGoal(name: String, targetAmount: Double, targetDate: Date, groupId: Int, completion: @escaping (Goal?) -> Void) {
        guard let url = URL(string: "\(baseURL)/goals/?group_id=\(groupId)") else {
            completion(nil)
            return
        }

        let body = ["name": name, "target_amount": targetAmount, "target_date": targetDate.ISO8601Format()]
        let encodedBody = try? JSONEncoder().encode(body)

        createAuthenticatedRequest(url: url, method: "POST", body: encodedBody) { request in
            guard let request = request else {
                completion(nil)
                return
            }

            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    completion(nil)
                    return
                }

                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let goal = try? decoder.decode(Goal.self, from: data)
                completion(goal)
            }.resume()
        }
    }
}
