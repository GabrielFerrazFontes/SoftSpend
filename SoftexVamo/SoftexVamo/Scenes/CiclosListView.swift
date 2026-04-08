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
        .sheet(isPresented: $addNewGastoSheet) {
            AddNewGastoSheetView(
                selectedDia: viewModel.actualCiclo.dias.first!,
                dias: viewModel.actualCiclo.dias
            ) { title, value, dia in
                
                Task {
                    try await viewModel.createNewGasto(
                        title: title,
                        value: value,
                        dia: dia
                    )
                }
            }
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
            
            let cicloFinal = ciclos[self.index]
            
            self.index = self.allCiclos.count - 1
            
            if self.index >= 0 {
                self.actualCiclo = self.allCiclos[self.index]
            }
            
            self.salvarNoCache(ciclo: cicloFinal)
            
            if self.actualCiclo.backendId != nil {
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
    
//    private func updateCicloInfo() {
//        let available = self.actualCiclo.valor_total - self.actualCiclo.gasto_total
//        self.gastosInfo = GastosDia(valor: actualCiclo.gasto_total, titulo: "Gasto")
//        self.availableInfo = GastosDia(valor: available, titulo: "Disponivel")
//    }
    
    func createNewGasto( title: String, value: Decimal, dia: DiaSoftex) async throws {
        let valueFloat = Float(value.description) ?? 0.0
        
        do {
            let gasto = GastosDia(valor: valueFloat, titulo: title)
            
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
