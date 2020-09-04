//
//  LoginView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 04.09.20.
//

import SwiftUI

struct LoginView: View {
    @State private var loginRequestBody = LoginRequestBody()
    @State private var isLoading = false
    
    var body: some View {
        Form {
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

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
