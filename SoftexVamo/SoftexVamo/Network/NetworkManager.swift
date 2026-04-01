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
    
    func fetchAllCiclos() async throws -> [CicloSoftex] {
        
        guard let url = URL(string: "https://henley-schedular-sufferably.ngrok-free.dev/usuario/ciclos/1") else { return [] }
        
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
    
    
    func postCiclo(newCiclo: CicloSoftex) async throws -> Void {
        
        guard let url = URL(string: "https://henley-schedular-sufferably.ngrok-free.dev/ciclos") else { return }
        
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
        
    }
    
    
    func postGasto(newGasto: GastosDia, diaId: Int) async throws -> GastosDia {
        
        guard let url = URL(string: "https://henley-schedular-sufferably.ngrok-free.dev/dias/\(diaId)/gastos") else { throw URLError(.badURL) }
        
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
    
    func deleteGasto(gastoId: Int) async throws {
        
        guard let url = URL(string: "https://henley-schedular-sufferably.ngrok-free.dev/gastos/\(gastoId)") else { return }
        
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
