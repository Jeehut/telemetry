//
//  APIRepresentative.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 05.09.20.
//

import Foundation

final class APIRepresentative: ObservableObject {
    @Published var userToken: UserToken?
    @Published var user: OrganizationUser?
    @Published var userNotLoggedIn: Bool = true
    
    @Published var apps: [TelemetryApp] = [MockData.app1, MockData.app2]
    
    @Published var signals: [TelemetryApp: [Signal]] = MockData.signalsMockData
    @Published var userCounts: [TelemetryApp: [UserCountGroup]] = MockData.userCounts
    
    @Published var statistics: [TelemetryApp: [DerivedStatisticGroup]] = MockData.statistics
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
                    self.userToken = decodedResponse
                    
                    DispatchQueue.main.async {
                        self.userNotLoggedIn = false
                    }
                    
                }
            }
        }.resume()
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
}
