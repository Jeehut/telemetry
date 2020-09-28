//
//  APIRepresentative.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 05.09.20.
//

import Foundation

final class APIRepresentative: ObservableObject {
    private static let userTokenStandardsKey = "org.breakthesystem.telemetry.viewer.userToken"
    
    init() {
        if let encodedUserToken = UserDefaults.standard.data(forKey: APIRepresentative.userTokenStandardsKey),
           let userToken = try? JSONDecoder.telemetryDecoder.decode(UserToken.self, from: encodedUserToken) {
            self.userToken = userToken
            getUserInformation()
            getApps()
        }
    }
    
    @Published var userToken: UserToken? {
        didSet {
            let encodedUserToken = try! JSONEncoder().encode(userToken)
            UserDefaults.standard.setValue(encodedUserToken, forKey: APIRepresentative.userTokenStandardsKey)
            
            userNotLoggedIn = userToken == nil
        }
    }
    
    @Published var user: OrganizationUser?
    @Published var userNotLoggedIn: Bool = true
    
    @Published var apps: [TelemetryApp] = [MockData.app1, MockData.app2]
    
    @Published var signals: [TelemetryApp: [Signal]] = [:]
    @Published var insightGroups: [TelemetryApp: [InsightGroup]] = [:]
    
    
    @Published var userCountGroups: [TelemetryApp: [UserCountGroup]] = [:]
    @Published var derivedStatisticGroups: [TelemetryApp: [DerivedStatisticGroup]] = [:]
}

extension APIRepresentative {
    func login(loginRequestBody: LoginRequestBody, callback: @escaping () -> ()) {
        
        guard let url = URL(string: "http://localhost:8080/api/v1/users/login") else {
            print("Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(loginRequestBody.basicHTMLAuthString, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            callback()
            
            if let data = data {
                print(String(decoding: data, as: UTF8.self))
                
                if let decodedResponse = try? JSONDecoder.telemetryDecoder.decode(UserToken.self, from: data) {
                    DispatchQueue.main.async {
                        self.userToken = decodedResponse
                        
                        self.getUserInformation()
                        self.getApps()
                    }
                } else {
                    fatalError("Could not decode a user token")
                }
            }
        }.resume()
    }
    
    func logout() {
        userToken = nil
        apps = []
        user = nil
    }
    
    func register(registrationRequestBody: RegistrationRequestBody, callback: @escaping () -> ()) {
        guard let url = URL(string: "http://localhost:8080/api/v1/users/register") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONEncoder().encode(registrationRequestBody)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            callback()
            
            if let data = data {
                print(String(decoding: data, as: UTF8.self))
                
                if let decodedResponse = try? JSONDecoder.telemetryDecoder.decode(UserToken.self, from: data) {
                    print(decodedResponse)
                }
            }
        }.resume()
    }
    
    func getUserInformation() {
        guard let url = URL(string: "http://localhost:8080/api/v1/users/me") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(userToken?.bearerTokenAuthString, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                print(String(decoding: data, as: UTF8.self))
                
                let decodedResponse = try! JSONDecoder.telemetryDecoder.decode(OrganizationUser.self, from: data)
                
                DispatchQueue.main.async {
                    self.user = decodedResponse
                }
                
            }
        }.resume()
    }
    
    func getApps() {
        guard let url = URL(string: "http://localhost:8080/api/v1/apps/") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(userToken?.bearerTokenAuthString, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                print(String(decoding: data, as: UTF8.self))
                
                let decodedResponse = try! JSONDecoder.telemetryDecoder.decode([TelemetryApp].self, from: data)
                
                DispatchQueue.main.async {
                    self.apps = decodedResponse
                }
                
            }
        }.resume()
    }
    
    func create(appNamed name: String) {
        guard let url = URL(string: "http://localhost:8080/api/v1/apps/") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(userToken?.bearerTokenAuthString, forHTTPHeaderField: "Authorization")
        request.httpBody = try! JSONEncoder().encode(["name": name])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                print(String(decoding: data, as: UTF8.self))
                
                let decodedResponse = try! JSONDecoder.telemetryDecoder.decode(TelemetryApp.self, from: data)
                print(decodedResponse)
                
                DispatchQueue.main.async {
                    self.getApps()
                }
                
            }
        }.resume()
    }
    
    func update(app: TelemetryApp, newName: String) {
        guard
            let url = URL(string: "http://localhost:8080/api/v1/apps/\(app.id.uuidString)/") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(userToken?.bearerTokenAuthString, forHTTPHeaderField: "Authorization")
        request.httpBody = try! JSONEncoder().encode(["name": newName])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                print(String(decoding: data, as: UTF8.self))
                
                let decodedResponse = try! JSONDecoder.telemetryDecoder.decode(TelemetryApp.self, from: data)
                print(decodedResponse)
                
                DispatchQueue.main.async {
                    self.getApps()
                }
                
            }
        }.resume()
    }
    
    func delete(app: TelemetryApp) {
        guard let url = URL(string: "http://localhost:8080/api/v1/apps/\(app.id.uuidString)/") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(userToken?.bearerTokenAuthString, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async {
                self.getApps()
            }
        }.resume()
    }
    
    func getSignals(for app: TelemetryApp) {
        guard let url = URL(string: "http://localhost:8080/api/v1/apps/\(app.id.uuidString)/signals/") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(userToken?.bearerTokenAuthString, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                print(String(decoding: data, as: UTF8.self))
                
                let decodedResponse = try! JSONDecoder.telemetryDecoder.decode([Signal].self, from: data)
                
                DispatchQueue.main.async {
                    self.signals[app] = decodedResponse
                }
                
            }
        }.resume()
    }
    
    func create(userCountGroup: UserCountGroupCreateRequestBody, for app: TelemetryApp) {
        guard let url = URL(string: "http://localhost:8080/api/v1/apps/\(app.id.uuidString)/usercountgroups/") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(userToken?.bearerTokenAuthString, forHTTPHeaderField: "Authorization")
        
        let requestBody = userCountGroup
        request.httpBody = try! JSONEncoder().encode(requestBody)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                print(String(decoding: data, as: UTF8.self))
                self.getUserCountGroups(for: app)
            }
        }.resume()
    }
    
    func getUserCountGroups(for app: TelemetryApp) {
        guard let url = URL(string: "http://localhost:8080/api/v1/apps/\(app.id.uuidString)/usercountgroups/") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(userToken?.bearerTokenAuthString, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                print(String(decoding: data, as: UTF8.self))

                let decodedResponse = try! JSONDecoder.telemetryDecoder.decode([UserCountGroup].self, from: data)
                
                DispatchQueue.main.async {
                    self.userCountGroups[app] = decodedResponse
                }
                
            }
        }.resume()
    }
    
    func delete(userCountGroup: UserCountGroup, from app: TelemetryApp) {
        guard let url = URL(string: "http://localhost:8080/api/v1/apps/\(app.id.uuidString)/usercountgroups/\(userCountGroup.id.uuidString)/") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(userToken?.bearerTokenAuthString, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                print(String(decoding: data, as: UTF8.self))
            }
            
            DispatchQueue.main.async {
                self.getUserCountGroups(for: app)
            }
        }.resume()
    }
    
    func getDerivedStatisticGroups(for app: TelemetryApp) {
        guard let url = URL(string: "http://localhost:8080/api/v1/apps/\(app.id.uuidString)/derivedstatisticgroups/") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(userToken?.bearerTokenAuthString, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                print(String(decoding: data, as: UTF8.self))

                let decodedResponse = try! JSONDecoder.telemetryDecoder.decode([DerivedStatisticGroup].self, from: data)
                
                DispatchQueue.main.async {
                    self.derivedStatisticGroups[app] = decodedResponse
                }
                
            }
        }.resume()
    }
    
    func getAdditionalData(for statistic: DerivedStatistic, in derivedStatisticGroup: DerivedStatisticGroup, in app: TelemetryApp, callback: @escaping ([String: Int]) -> ()) {
        guard let url = URL(string: "http://localhost:8080/api/v1/apps/\(app.id)/derivedstatisticgroups/\(derivedStatisticGroup.id)/derivedstatistics/\(statistic.id)/") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(userToken?.bearerTokenAuthString, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                print(String(decoding: data, as: UTF8.self))

                let decodedResponse = try! JSONDecoder.telemetryDecoder.decode(DerivedStatisticDataTransferObject.self, from: data)
                
                DispatchQueue.main.async {
                    callback(decodedResponse.rollingCurrentStatistics)
                }
                
            }
        }.resume()
    }
    
    func create(derivedStatisticGroupNamed: String, for app: TelemetryApp) {
        guard let url = URL(string: "http://localhost:8080/api/v1/apps/\(app.id.uuidString)/derivedstatisticgroups/") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(userToken?.bearerTokenAuthString, forHTTPHeaderField: "Authorization")
        
        let requestBody = ["title": derivedStatisticGroupNamed]
        request.httpBody = try! JSONEncoder().encode(requestBody)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                print(String(decoding: data, as: UTF8.self))
                self.getDerivedStatisticGroups(for: app)
            }
        }.resume()
    }
    
    func create(derivedStatistic: DerivedStatisticCreateRequestBody, for derivedStatisticGroup: DerivedStatisticGroup, in app: TelemetryApp) {
        guard let url = URL(string: "http://localhost:8080/api/v1/apps/\(app.id.uuidString)/derivedstatisticgroups/\(derivedStatisticGroup.id)/derivedstatistics/") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(userToken?.bearerTokenAuthString, forHTTPHeaderField: "Authorization")
        
        let requestBody = derivedStatistic
        request.httpBody = try! JSONEncoder().encode(requestBody)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                print(String(decoding: data, as: UTF8.self))
                self.getDerivedStatisticGroups(for: app)
            }
        }.resume()
    }
    
    func delete(derivedStatistic: DerivedStatistic, in derivedStatisticGroup: DerivedStatisticGroup, in app: TelemetryApp) {
        guard let url = URL(string: "http://localhost:8080/api/v1/apps/\(app.id.uuidString)/derivedstatisticgroups/\(derivedStatisticGroup.id)/derivedstatistics/\(derivedStatistic.id)/") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(userToken?.bearerTokenAuthString, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async {
                self.getDerivedStatisticGroups(for: app)
            }
        }.resume()
    }
    
    
    func delete(derivedStatisticGroup: DerivedStatisticGroup, in app: TelemetryApp) {
        guard let url = URL(string: "http://localhost:8080/api/v1/apps/\(app.id.uuidString)/derivedstatisticgroups/\(derivedStatisticGroup.id)/") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(userToken?.bearerTokenAuthString, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async {
                self.getDerivedStatisticGroups(for: app)
            }
        }.resume()
    }
    
    
    
    func getInsightGroups(for app: TelemetryApp) {
        guard let url = URL(string: "http://localhost:8080/api/v1/apps/\(app.id.uuidString)/insightgroups/") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(userToken?.bearerTokenAuthString, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                print(String(decoding: data, as: UTF8.self))
                
                let decodedResponse = try! JSONDecoder.telemetryDecoder.decode([InsightGroup].self, from: data)
                
                DispatchQueue.main.async {
                    self.insightGroups[app] = decodedResponse
                }
                
            }
        }.resume()
    }
    
    func create(insightGroupNamed: String, for app: TelemetryApp) {
        guard let url = URL(string: "http://localhost:8080/api/v1/apps/\(app.id.uuidString)/insightgroups/") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(userToken?.bearerTokenAuthString, forHTTPHeaderField: "Authorization")
        
        let requestBody = ["title": insightGroupNamed]
        request.httpBody = try! JSONEncoder().encode(requestBody)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                print(String(decoding: data, as: UTF8.self))
                self.getInsightGroups(for: app)
            }
        }.resume()
    }
    
    func delete(insightGroup: InsightGroup, in app: TelemetryApp) {
        guard let url = URL(string: "http://localhost:8080/api/v1/apps/\(app.id.uuidString)/insightgroups/\(insightGroup.id)/") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(userToken?.bearerTokenAuthString, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async {
                self.getInsightGroups(for: app)
            }
        }.resume()
    }
    
    func getInsightData(for insight: Insight, in insightGroup: InsightGroup, in app: TelemetryApp, completion: @escaping (InsightDataTransferObject) -> ()) {
        guard let url = URL(string: "http://localhost:8080/api/v1/apps/\(app.id)/insightgroups/\(insightGroup.id)/insights/\(insight.id)/") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(userToken?.bearerTokenAuthString, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                print(String(decoding: data, as: UTF8.self))
                
                let decodedResponse = try! JSONDecoder.telemetryDecoder.decode(InsightDataTransferObject.self, from: data)
                
                DispatchQueue.main.async {
                    completion(decodedResponse)
                }
                
            }
        }.resume()
    }
    
    func create(insightWith requestBody: InsightCreateRequestBody, in insightGroup: InsightGroup, for app: TelemetryApp) {
        guard let url = URL(string: "http://localhost:8080/api/v1/apps/\(app.id)/insightgroups/\(insightGroup.id)/insights/") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(userToken?.bearerTokenAuthString, forHTTPHeaderField: "Authorization")
        
        request.httpBody = try! JSONEncoder().encode(requestBody)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                print(String(decoding: data, as: UTF8.self))
                self.getInsightGroups(for: app)
            }
        }.resume()
    }
    
    func delete(insight: Insight, in insightGroup: InsightGroup, in app: TelemetryApp) {
        guard let url = URL(string: "http://localhost:8080/api/v1/apps/\(app.id.uuidString)/insightgroups/\(insightGroup.id)/insights/\(insight.id)/") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(userToken?.bearerTokenAuthString, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async {
                self.getInsightGroups(for: app)
            }
        }.resume()
    }
}
