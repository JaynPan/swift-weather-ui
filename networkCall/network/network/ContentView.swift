//
//  ContentView.swift
//  network
//
//  Created by 潘傑恩 on 2023/6/28.
//

import SwiftUI

struct ContentView: View {
    @State private var user: GithubUser?
    
    var body: some View {
        VStack(spacing: 20) {
            AsyncImage(url: URL(string: user?.avatarUrl ?? "")) { image in
                image
                    .resizable()
                    .frame(width: 120, height: 120)
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
            } placeholder: {
                Circle()
                    .foregroundColor(.secondary)
                    .frame(width: 120, height: 120)
            }
            
            Text(user?.login ?? "Login Placeholder")
                .bold()
                .font(.title3)
            
            Text(user?.bio ?? "placeholder")
            
            Spacer()
        }
        .padding()
        .task {
            do {
                user = try await getUser()
            } catch {
                print("something went wrong")
            }
        }
    }
    
    func getUser() async throws -> GithubUser {
        let endpoint = "https://api.github.com/users/JaynPan"
        guard let url = URL(string: endpoint) else {
            throw GHError.invalidURL
        }
    
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw GHError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()

            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(GithubUser.self, from : data)
        } catch {
            throw GHError.invalidData
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct GithubUser: Codable {
    let login: String
    let avatarUrl: String
    let bio: String
}

enum GHError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}