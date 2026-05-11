//
//  NetworkManager.swift
//  SoftexVamo
//
//  Created by Gabriel fontes on 26/03/26.
//

import Foundation
import Combine

final class NetworkManager {
    
    private var cancellables: Set<AnyCancellable> = []
    static let shared = NetworkManager()
    
    func fetchAllCiclos(user: UserModel) async throws -> [CicloSoftex] {
        
        guard let url = URL(string: "\(APIConfig.shared.baseURL)/usuario/ciclos/\(user.id)") else { return [] }
        
        let session = URLSession(
            configuration: .default,
            delegate: InsecureSessionDelegate(),
            delegateQueue: nil
        )
        
        let (data, _) = try await session.data(from: url)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode([CicloSoftex].self, from: data)
    }
    
    func fetchCicloById(cicloId: Int) async throws -> CicloSoftex {
        guard let url = URL(string: "\(APIConfig.shared.baseURL)/ciclos/\(cicloId)") else {
            throw URLError(.badURL)
        }
        
        let session = URLSession(
            configuration: .default,
            delegate: InsecureSessionDelegate(),
            delegateQueue: nil
        )
        
        let (data, response) = try await session.data(from: url)
        
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode(CicloSoftex.self, from: data)
    }
    
    func fetchCicloResumo(user: UserModel) async throws -> [CicloSoftex] {
        
        guard let url = URL(string: "\(APIConfig.shared.baseURL)/usuario/ciclos/resumo/\(user.id)") else { return [] }
        
        let session = URLSession(
            configuration: .default,
            delegate: InsecureSessionDelegate(),
            delegateQueue: nil
        )
        
        let (data, _) = try await session.data(from: url)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode([CicloSoftex].self, from: data)
    }
    
    func postCiclo(newCiclo: CicloSoftex) async throws -> CicloSoftex {
        
        guard let url = URL(string: "\(APIConfig.shared.baseURL)/ciclos") else { throw URLError(.badURL)}
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        request.httpBody = try encoder.encode(newCiclo)
        
        let session = URLSession(
            configuration: .default,
            delegate: InsecureSessionDelegate(),
            delegateQueue: nil
        )
        
        let (data, response) = try await session.data(for: request)
        
        print(String(data: data, encoding: .utf8)!)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let cicloCriado = try decoder.decode(CicloSoftex.self, from: data)
        
        return cicloCriado
        
    }
    
    func postGasto(newGasto: GastosDia, diaId: Int) async throws -> GastosDia {
        
        guard let url = URL(string: "\(APIConfig.shared.baseURL)/dias/\(diaId)/gastos") else { throw URLError(.badURL) }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        request.httpBody = try encoder.encode(newGasto)
        
        let session = URLSession(
            configuration: .default,
            delegate: InsecureSessionDelegate(),
            delegateQueue: nil
        )
        
        let (data, response) = try await session.data(for: request)
        
        print(String(data: data, encoding: .utf8)!)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let gastoCriado = try decoder.decode(GastosDia.self, from: data)
        
        return gastoCriado
        
    }
    
    func extrairGastoDeImagem(imageData: Data) async throws -> GastoExtraidoResponse {
        guard let url = URL(string: "\(APIConfig.shared.baseURL)/gastos/extrair") else {
            throw URLError(.badURL)
        }
        
        let boundary = "Boundary-\(UUID().uuidString)"
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 60
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"imagem\"; filename=\"comprovante.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let session = URLSession(
            configuration: .default,
            delegate: InsecureSessionDelegate(),
            delegateQueue: nil
        )
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            let mensagem = String(data: data, encoding: .utf8) ?? "Erro desconhecido"
            print("Erro extrair gasto:", mensagem)
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(GastoExtraidoResponse.self, from: data)
    }
    
    func deleteGasto(gastoId: Int) async throws {
        
        guard let url = URL(string: "\(APIConfig.shared.baseURL)/gastos/\(gastoId)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
        
        print(String(data: data, encoding: .utf8) ?? "")
    }
    
    
    class InsecureSessionDelegate: NSObject, URLSessionDelegate {
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
