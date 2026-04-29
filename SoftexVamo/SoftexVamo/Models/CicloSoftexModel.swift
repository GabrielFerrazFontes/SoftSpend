//
//  CicloSoftexModel.swift
//  SoftexVamo
//
//  Created by Gabriel fontes on 25/03/26.
//

import Foundation

enum Categoria: String, Codable, CaseIterable, Identifiable {
    case ALIMENTACAO = "ALIMENTACAO"
    case TRANSPORTE = "TRANSPORTE"
    case LAZER = "LAZER"
    case COMPRAS = "COMPRAS"
    case OUTROS = "OUTROS"
    
    
    var id : String {
        self.rawValue
    }
    
    var localizedName: String {
            switch self {
            case .ALIMENTACAO: return "Alimentação"
            case .TRANSPORTE: return "Transporte"
            case .LAZER: return "Lazer"
            case .COMPRAS: return "Compras"
            case .OUTROS: return "Outros"
            
            }
        }
    
    var systemImageName: String {
            switch self {
            case .ALIMENTACAO: return "fork.knife"
            case .TRANSPORTE: return "car.fill"
            case .LAZER: return "gamecontroller.fill"
            case .COMPRAS:
                return "mappin"
            case .OUTROS:
                return "car"
            }
        }
}

struct CicloSoftex: Codable, Identifiable {
    var id = UUID()
    var backendId: Int?
    var valor_total: Float
    var gasto_total: Float
    var periodo: String
    var diaria: Float
    var titulo: String
    var dias: [DiaSoftex]
    var id_usuario: Int?
    
    enum CodingKeys: String, CodingKey {
            case backendId = "id"
            case valor_total
            case gasto_total
            case periodo
            case diaria
            case titulo
            case dias
            case id_usuario
        }
    
    static let examples = [
        CicloSoftex(valor_total: 2145, gasto_total: 214, periodo: "10/03 - 17/03", diaria: 180, titulo: "Fortaleza", dias: DiaSoftex.examples),
        CicloSoftex(valor_total: 2446, gasto_total: 214, periodo: "18/03 - 25/03", diaria: 167, titulo: "Cuiába", dias: DiaSoftex.examples1),
        CicloSoftex(valor_total: 2162, gasto_total: 214, periodo: "26/03 - 01/04", diaria: 172, titulo: "Belém", dias: DiaSoftex.examples),

        ]
    
    static let example = CicloSoftex(valor_total: 2145, gasto_total: 214, periodo: "10/03 - 17/03", diaria: 180, titulo: "Fortaleza", dias: DiaSoftex.examples)
}

struct DiaSoftex: Codable, Identifiable, Hashable {
    var id: Int { backendId ?? 0 }
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
    
    func hash(into hasher: inout Hasher) {
            hasher.combine(backendId)
        }
        
        static func == (lhs: DiaSoftex, rhs: DiaSoftex) -> Bool {
            return lhs.backendId == rhs.backendId
        }
    
    static let examples = [
        DiaSoftex(backendId: 1, gastos: GastosDia.examples, data: Date.now, saldo: 64),
        DiaSoftex(backendId: 2, gastos: GastosDia.examples1, data: Date.now.addingTimeInterval(86400), saldo: 52),
        DiaSoftex(backendId: 3, gastos: GastosDia.examples2, data: Date.now.addingTimeInterval(172800), saldo: 42),
        DiaSoftex(backendId: 4, gastos: [], data: Date.now.addingTimeInterval(259200), saldo: 126),
        DiaSoftex(backendId: 5, gastos: [], data: Date.now.addingTimeInterval(345600), saldo: 126)
    ]
    
    static let examples1 = [
        DiaSoftex(backendId: 6, gastos: GastosDia.examples1, data: Date.now, saldo: 60),
        DiaSoftex(backendId: 7, gastos: GastosDia.examples2, data: Date.now.addingTimeInterval(86400), saldo: 50),
        DiaSoftex(backendId: 8,gastos: GastosDia.examples, data: Date.now.addingTimeInterval(172800), saldo: 72)
    ]
}

struct GastosDia: Codable, Identifiable, Hashable  {
    var id = UUID()
    var backendId: Int?
    let valor: Float
    let titulo: String
    let categoria: Categoria
    
    enum CodingKeys: String, CodingKey {
            case backendId = "id"
            case valor
            case titulo
            case categoria
        }

    static let examples = [ // 60
        GastosDia(valor: 20, titulo: "Almoco", categoria: .ALIMENTACAO),
        GastosDia(valor: 30, titulo: "Jantar", categoria: .ALIMENTACAO),
        GastosDia(valor: 10, titulo: "Uber", categoria: .TRANSPORTE)
    ]
    
    static let examples1 = [ // 72
        GastosDia(valor: 24, titulo: "Almoco", categoria: .ALIMENTACAO),
        GastosDia(valor: 32, titulo: "Uber", categoria: .TRANSPORTE),
        GastosDia(valor: 16, titulo: "Uber", categoria: .TRANSPORTE)
    ]
    
    static let examples2 = [ // 82
        GastosDia(valor: 12, titulo: "Uber", categoria: .TRANSPORTE),
        GastosDia(valor: 26, titulo: "Almoco", categoria: .ALIMENTACAO),
        GastosDia(valor: 33, titulo: "Jantar", categoria: .ALIMENTACAO),
        GastosDia(valor: 11, titulo: "Uber", categoria: .TRANSPORTE)
    ]
    
    static let example = GastosDia(valor: 12, titulo: "Uber", categoria: .TRANSPORTE)
}

