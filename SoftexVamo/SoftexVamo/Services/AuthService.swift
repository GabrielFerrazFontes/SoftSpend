//
//  AuthService.swift
//  SoftexVamo
//
//  Created by Joao Victor on 30/04/26.
//

import Foundation
import Combine

@MainActor
final class AuthService: ObservableObject {
    
    static let shared = AuthService()
    
    @Published var currentUser: UserModel?
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var baseURL: String { APIConfig.shared.baseURL }
    private let tokenKey = "auth_token"
    private let userKey = "user_data"
    
    init() {
        checkAuthentication()
    }
    
    func checkAuthentication() {
        if let _ = UserDefaults.standard.string(forKey: tokenKey),
           let userData = UserDefaults.standard.data(forKey: userKey),
           let user = try? JSONDecoder().decode(UserModel.self, from: userData) {
            self.currentUser = user
            self.isAuthenticated = true
        }
    }
    
    func register(nome: String, username: String, email: String, senha: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let request = RegisterRequest(nome: nome, username: username, email: email, senha: senha)
            let authResponse = try await performAuthRequest(endpoint: "/auth/register", body: request)
            
            await saveUser(authResponse)
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func login(email: String, senha: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let request = LoginRequest(email: email, senha: senha)
            let authResponse = try await performAuthRequest(endpoint: "/auth/login", body: request)
            
            await saveUser(authResponse)
            
        } catch {
            errorMessage = "Email ou senha invalidos"
        }
        
        isLoading = false
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: userKey)
        UserDefaults.standard.removeObject(forKey: "ultimo_ciclo_cache")
        currentUser = nil
        isAuthenticated = false
    }
    
    private func performAuthRequest<T: Codable>(endpoint: String, body: T) async throws -> AuthResponse {
        guard let url = URL(string: baseURL + endpoint) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        
        let session = URLSession(
            configuration: .default,
            delegate: InsecureSessionDelegate(),
            delegateQueue: nil
        )
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if httpResponse.statusCode == 400 {
            throw NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Email ou username ja cadastrado"])
        }
        
        if httpResponse.statusCode == 401 {
            throw NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Credenciais invalidas"])
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(AuthResponse.self, from: data)
    }
    
    private func saveUser(_ response: AuthResponse) async {
        let user = UserModel(
            id: response.id,
            nome: response.nome,
            username: response.username,
            email: response.email,
            token: response.token
        )
        
        DispatchQueue.main.async {
                self.currentUser = user
                self.isAuthenticated = true
                
                // Salvar no disco pode ser logo depois
                UserDefaults.standard.set(response.token, forKey: self.tokenKey)
                if let userData = try? JSONEncoder().encode(user) {
                    UserDefaults.standard.set(userData, forKey: self.userKey)
                }
                
                print("DEBUG: isAuthenticated mudou para true no shared")
            }
    }
    
    final class InsecureSessionDelegate: NSObject, URLSessionDelegate, Sendable {
        func urlSession(_ session: URLSession,
                        didReceive challenge: URLAuthenticationChallenge,
                        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
            
            if let trust = challenge.protectionSpace.serverTrust {
                completionHandler(.useCredential, URLCredential(trust: trust))
            } else {
                completionHandler(.cancelAuthenticationChallenge, nil)
            }
        }
    }
}
