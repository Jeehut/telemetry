//
//  RegisterView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 05.08.20.
//

import SwiftUI

struct RegistrationRequestBody: Codable {
    var organisationName: String = ""
    var userFirstName: String = ""
    var userLastName: String = ""
    var userEmail: String = ""
    var userPassword: String = ""
    var userPasswordConfirm: String = ""
}

struct LoginRequestBody {
    var userEmail: String = ""
    var userPassword: String = ""
    
    var basicHTMLAuthString: String? {
        let loginString = "\(userEmail):\(userPassword)"
        guard let loginData = loginString.data(using: String.Encoding.utf8) else { return nil }
        let base64LoginString = loginData.base64EncodedString()
        return "Basic \(base64LoginString)"
    }
}

struct UserToken: Codable {
    var id: UUID?
    var value: String
    var user: String
}

struct RegisterView: View {
    @State private var isLoading = false
    @State private var shouldLogin = false
    @State private var registrationRequestBody = RegistrationRequestBody()
    @State private var loginRequestBody = LoginRequestBody()
    
    var body: some View {
        Form {
            Section(header: Text("Login")) {
                Toggle("Login instead of register?", isOn: $shouldLogin)
            }
            
            if !shouldLogin {
                Section(header: Text("Your Organization")) {
                    TextField("Organization Name", text: $registrationRequestBody.organisationName)
                }
                
                Section(header: Text("You")) {
                    TextField("First Name", text: $registrationRequestBody.userFirstName)
                    TextField("Last Name", text: $registrationRequestBody.userLastName)
                    TextField("Email", text: $registrationRequestBody.userEmail)
                }
                
                Section(header: Text("Your Password")) {
                    TextField("Password", text: $registrationRequestBody.userPassword)
                    TextField("Confirm Password", text: $registrationRequestBody.userPasswordConfirm)
                }
                
                Section {
                    if isLoading {
                        ProgressView()
                    } else {
                        Button("Register", action: register)
                    }
                }
            }
            
            if shouldLogin {
                Section(header: Text("Login")) {
                    TextField("Email", text: $loginRequestBody.userEmail)
                    TextField("Password", text: $loginRequestBody.userPassword)
                }
                
                Section {
                    if isLoading {
                        ProgressView()
                    } else {
                        Button("Login", action: login)
                    }
                    
                    
                }
            }
        }.disabled(isLoading)
    }
    
    func register() {
        isLoading = true
        
        guard let url = URL(string: "http://localhost:8080/api/v1/users/register") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONEncoder().encode(registrationRequestBody)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            isLoading = false
            
            if let data = data {
                print(String(decoding: data, as: UTF8.self))
                
                if let decodedResponse = try? JSONDecoder().decode(UserToken.self, from: data) {
                    print(decodedResponse)
                }
            }
        }.resume()
    }
    
    func login() {
        isLoading = true
        
        guard let url = URL(string: "http://localhost:8080/api/v1/users/login") else {
            print("Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(loginRequestBody.basicHTMLAuthString, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            isLoading = false
            
            if let data = data {
                print(String(decoding: data, as: UTF8.self))
                
                if let decodedResponse = try? JSONDecoder().decode(UserToken.self, from: data) {
                    print(decodedResponse)
                }
            }
        }.resume()
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
