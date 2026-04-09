//
//  CiclosListView.swift
//  SoftexVamo
//
//  Created by Gabriel fontes on 25/03/26.
//

import SwiftUI
import Combine

struct CiclosListView: View {
    @EnvironmentObject var viewModel: CiclosListViewModel
    
    @State var addNewGastoSheet: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            
            CardMainView()
            
            CicloGastosView() {
                addNewGastoSheet.toggle()
            } deleteAction: { diaId, gastoID in
                Task { try await viewModel.deleteGasto(gastoID: gastoID) }
            }
            .id(viewModel.actualCiclo.id)
            .environmentObject(CicloGastosViewModel(ciclo: viewModel.actualCiclo))
        }
        .task {
            await viewModel.fetchAllCiclos1()
        }
        .navigationBarBackButtonHidden(true)
    }
}

final class CiclosListViewModel: ObservableObject {
    @Published var allCiclos: [CicloSoftex] = []
    @Published var actualCiclo: CicloSoftex
    @Published var gastosInfo: GastosDia = GastosDia.example
    @Published var availableInfo: GastosDia = GastosDia.example
    @Published var isLoading: Bool = true
    @Published var selectedTab: Int = 0
    
    private var hasLoadedOnce = false
    var index: Int = 0
    
    init() {
        self.actualCiclo = CicloSoftex.example
    }
    
    @MainActor
    func fetchAllCiclos1() async {
        
        if hasLoadedOnce { return }
        
        let cacheData = UserDefaults.standard.data(forKey: "ultimo_ciclo_cache")
        
        if let data = cacheData {
            if let cache = try? await Task.detached(priority: .userInitiated, operation: {
                try JSONDecoder().decode(CicloSoftex.self, from: data)
            }).value {
                self.actualCiclo = cache
                print("Cache carregado em background")
            }
        }
        
        do {
            let ciclos = try await NetworkManager.shared.fetchAllCiclos()
            
            if ciclos.isEmpty {
                self.allCiclos = CicloSoftex.examples
            } else {
                self.allCiclos = ciclos
            }
            
            self.index = self.allCiclos.count - 1
            
            if self.index >= 0 {
                let cicloParaSalvar = self.allCiclos[self.index]
                self.actualCiclo = cicloParaSalvar
                
                self.salvarNoCache(ciclo: cicloParaSalvar)
            }
            
            if self.index >= 0 {
                self.actualCiclo = self.allCiclos[self.index]
            }
            
            if self.actualCiclo.backendId != nil || ciclos.isEmpty {
                self.isLoading = false
            }
            
            self.hasLoadedOnce = true
            
        } catch {
            print("Erro ao buscar ciclos:", error)
            
            self.allCiclos = CicloSoftex.examples
            self.actualCiclo = self.allCiclos[0]
            self.hasLoadedOnce = true
        }
    }
    
    func createNewCiclo(startDate: Date, endDate: Date, totalValue: Float, titulo: String) async {
        let dayCount = Calendar.current.datesBetween(startDate, and: endDate)
        let saldo = totalValue / Float(dayCount)
        let days: [DiaSoftex] = createAllDays(dayCount: dayCount, startDate: startDate, saldo: saldo)
        let periodo = createPeriodoString(from: startDate, to: endDate)
        
        let newCiclo = CicloSoftex(valor_total: totalValue, gasto_total: 0, periodo: periodo, diaria: saldo, titulo: titulo, dias: days, id_usuario: 1)
 
        await postToNetwork(newCiclo: newCiclo, daysCount: dayCount)
    }
    
    func nextCiclo() {
        guard index <= allCiclos.count - 2 else { return }
        index += 1
        actualCiclo = allCiclos[index]
    }
    
    func previousCiclo() {
        guard index > 0 else { return }
        index -= 1
        actualCiclo = allCiclos[index]
    }
    
    private func salvarNoCache(ciclo: CicloSoftex) {
        if ciclo.backendId != nil {
            if let encoded = try? JSONEncoder().encode(ciclo) {
                UserDefaults.standard.set(encoded, forKey: "ultimo_ciclo_cache")
            }
        }
    }
    
    private func createAllDays(dayCount: Int, startDate: Date, saldo: Float) -> [DiaSoftex] {
        var days: [DiaSoftex] = []
        for i in 0...dayCount - 1 {
            let time = 86400 * i
            let date = startDate.addingTimeInterval(TimeInterval(time))
            days.append(DiaSoftex(gastos: [], data: date, saldo: saldo))
        }
        return days
    }
    
    private func createPeriodoString(from: Date, to: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM"
        return "\(dateFormatter.string(from: from)) - \(dateFormatter.string(from: to))"
    }
    
    private func postToNetwork(newCiclo: CicloSoftex, daysCount: Int) async {
        do {
            let novoCiclo = try await NetworkManager.shared.postCiclo(newCiclo: newCiclo )
            
            DispatchQueue.main.async {
                        self.allCiclos.append(novoCiclo)
                        self.actualCiclo = novoCiclo
                        self.index = self.allCiclos.count - 1
                    }

        } catch {
            print("Erro ao criar o ciclo:", error)
        }
    }
    
    func createNewGasto( title: String, value: Decimal, dia: DiaSoftex, categoria: Categoria) async throws {
        let valueFloat = Float(value.description) ?? 0.0
        
        do {
            let gasto = GastosDia(valor: valueFloat, titulo: title, categoria: categoria)
            
            let novoGasto = try await NetworkManager.shared.postGasto(newGasto: gasto, diaId: dia.backendId!)
            
            await MainActor.run {
                if let diaIndex = actualCiclo.dias.firstIndex(where: { $0.backendId == dia.backendId }) {
                    
                    self.actualCiclo.dias[diaIndex].gastos.append(novoGasto)
                    self.actualCiclo.gasto_total += novoGasto.valor
                    self.allCiclos[index] = self.actualCiclo
                }
            }
            
            await fetchAllCiclos1()
            
        } catch {
            print("Erro ao criar gasto:", error)
        }
    }
    
    func deleteGasto(gastoID: Int) async throws{
        do{
            try await NetworkManager.shared.deleteGasto(gastoId: gastoID)
        }catch{
            print("Erro ao deletar gasto", error)
        }
    }
}

#Preview {
    CiclosListView()
        .environmentObject(CiclosListViewModel())
}
