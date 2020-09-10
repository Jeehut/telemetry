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
           let userToken = try? JSONDecoder().decode(UserToken.self, from: encodedUserToken) {
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
    @Published var userCounts: [TelemetryApp: [UserCountGroup]] = [:]
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
                
                if let decodedResponse = try? JSONDecoder().decode(UserToken.self, from: data) {
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
                
                if let decodedResponse = try? JSONDecoder().decode(UserToken.self, from: data) {
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
                
                let decodedResponse = try! JSONDecoder().decode(OrganizationUser.self, from: data)
                
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
                
                let decodedResponse = try! JSONDecoder().decode([TelemetryApp].self, from: data)
                
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
                
                let decodedResponse = try! JSONDecoder().decode(TelemetryApp.self, from: data)
                print(decodedResponse)
                
                DispatchQueue.main.async {
                    self.getApps()
                }
                
            }
        }.resume()
    }
    
    func update(app: TelemetryApp, newName: String) {
        guard let uuidString = app.id?.uuidString,
            let url = URL(string: "http://localhost:8080/api/v1/apps/\(uuidString)/") else {
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
                
                let decodedResponse = try! JSONDecoder().decode(TelemetryApp.self, from: data)
                print(decodedResponse)
                
                DispatchQueue.main.async {
                    self.getApps()
                }
                
            }
        }.resume()
    }
    
    func delete(app: TelemetryApp) {
        guard let uuidString = app.id?.uuidString,
            let url = URL(string: "http://localhost:8080/api/v1/apps/\(uuidString)/") else {
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
}
