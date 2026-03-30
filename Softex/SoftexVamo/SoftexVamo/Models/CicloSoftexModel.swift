//
//  CicloSoftexModel.swift
//  SoftexVamo
//
//  Created by Gabriel fontes on 25/03/26.
//

import Foundation

struct CicloSoftex: Codable, Identifiable {
    var id = UUID() // só pra UI
    var backendId: Int?
    var valor_total: Float
    var gasto_total: Float
    var periodo: String
    var diaria: Float
    var dias: [DiaSoftex]
    var id_usuario: Int?
    
    enum CodingKeys: String, CodingKey {
            case backendId = "id" // 👈 mapeia o id do backend
            case valor_total
            case gasto_total
            case periodo
            case diaria
            case dias
            case id_usuario
        }
    
    static let examples = [
        CicloSoftex(valor_total: 2145, gasto_total: 214, periodo: "10/03 - 17/03", diaria: 180, dias: DiaSoftex.examples),
        CicloSoftex(valor_total: 2446, gasto_total: 214, periodo: "18/03 - 25/03", diaria: 167, dias: DiaSoftex.examples1),
        CicloSoftex(valor_total: 2162, gasto_total: 214, periodo: "26/03 - 01/04", diaria: 172, dias: DiaSoftex.examples),

        ]
    
    static let example = CicloSoftex(valor_total: 2145, gasto_total: 214, periodo: "10/03 - 17/03", diaria: 180, dias: DiaSoftex.examples)
}
    
//
//    
//

struct DiaSoftex: Codable, Identifiable, Hashable {
    var id = UUID() // só pra UI
    var backendId: Int?
    var gastos: [GastosDia]
    let data: Date
    var saldo: Float
    
    enum CodingKeys: String, CodingKey {
            case backendId = "id"
            case gastos
            case data
            case saldo
        }
    
    static let examples = [
        DiaSoftex(gastos: GastosDia.examples, data: Date.now, saldo: 64),
        DiaSoftex(gastos: GastosDia.examples1, data: Date.now.addingTimeInterval(86400), saldo: 52),
        DiaSoftex(gastos: GastosDia.examples2, data: Date.now.addingTimeInterval(172800), saldo: 42),
        DiaSoftex(gastos: [], data: Date.now.addingTimeInterval(259200), saldo: 126),
        DiaSoftex(gastos: [], data: Date.now.addingTimeInterval(345600), saldo: 126)
    ]
    
    static let examples1 = [
        DiaSoftex(gastos: GastosDia.examples1, data: Date.now, saldo: 60),
        DiaSoftex(gastos: GastosDia.examples2, data: Date.now.addingTimeInterval(86400), saldo: 50),
        DiaSoftex(gastos: GastosDia.examples, data: Date.now.addingTimeInterval(172800), saldo: 72)
    ]
}

struct GastosDia: Codable, Identifiable, Hashable  {
    var id = UUID()
    var backendId: Int?
    let valor: Float
    let titulo: String
    
    enum CodingKeys: String, CodingKey {
            case backendId = "id" // 👈 mapeia o id do backend
            case valor
            case titulo
        }
//
    static let examples = [ // 60
        GastosDia(valor: 20, titulo: "Almoco"),
        GastosDia(valor: 30, titulo: "Jantar"),
        GastosDia(valor: 10, titulo: "Uber")
    ]
    
    static let examples1 = [ // 72
        GastosDia(valor: 24, titulo: "Almoco"),
        GastosDia(valor: 32, titulo: "Uber"),
        GastosDia(valor: 16, titulo: "Uber")
    ]
    
    static let examples2 = [ // 82
        GastosDia(valor: 12, titulo: "Uber"),
        GastosDia(valor: 26, titulo: "Almoco"),
        GastosDia(valor: 33, titulo: "Jantar"),
        GastosDia(valor: 11, titulo: "Uber")
    ]
    
    static let example = GastosDia(valor: 12, titulo: "Uber")
}

