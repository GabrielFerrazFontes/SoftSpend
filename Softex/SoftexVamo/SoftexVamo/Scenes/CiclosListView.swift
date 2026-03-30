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
        VStack {
            HStack {
                Button("", systemImage: "arrow.left") {
                    viewModel.previousCiclo()
                }
                .padding(.leading)
                Spacer()
                Text(viewModel.actualCiclo.periodo)
                Spacer()
                Button("", systemImage: "arrow.right") {
                    viewModel.nextCiclo()
                }
                .padding(.trailing)
            }
            CicloInfoView(gastos: $viewModel.gastosInfo, available: $viewModel.availableInfo)
                .frame(width: 250, height: 250)
            CicloGastosView() {
                addNewGastoSheet.toggle()
            } deleteAction: { diaID, gastoID in
                viewModel.deleteGasto(diaID: diaID, gastoID: gastoID)
            }
                .environmentObject(CicloGastosViewModel(ciclo: viewModel.actualCiclo))
        }
        .onAppear {
            Task{
                await viewModel.fetchAllCiclos1()
            }
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
    }
}

final class CiclosListViewModel: ObservableObject {
    @Published var actualCiclo: CicloSoftex = CicloSoftex.example
    @Published var gastosInfo: GastosDia = GastosDia.example
    @Published var availableInfo: GastosDia = GastosDia.example
    var allCiclos: [CicloSoftex] = []
    var index: Int = 0
    
    @MainActor
    func fetchAllCiclos1() async {
       
        do {
            let ciclos = try await NetworkManager.shared.fetchAllCiclos()

            self.allCiclos = ciclos
            self.actualCiclo = ciclos.last!
            self.index = ciclos.count - 1
            self.updateCicloInfo()

        } catch {
            print("Erro ao buscar ciclos:", error)
        }
    }
    
    func nextCiclo() {
        guard index <= allCiclos.count - 2 else { return }
        index += 1
        actualCiclo = allCiclos[index]
        updateCicloInfo()
    }
    
    func previousCiclo() {
        guard index > 0 else { return }
        index -= 1
        actualCiclo = allCiclos[index]
        updateCicloInfo()
    }
    
    private func updateCicloInfo() {
        let available = actualCiclo.valor_total - actualCiclo.gasto_total
        gastosInfo = GastosDia(valor: actualCiclo.gasto_total, titulo: "Gasto")
        availableInfo = GastosDia(valor: available, titulo: "Disponivel")
    }
    
    func createNewGasto( title: String, value: Decimal, dia: DiaSoftex) async throws {
        let valueFloat = Float(value.description) ?? 0.0
        
        do {
            let gasto = GastosDia(valor: valueFloat, titulo: title)
            
            try await NetworkManager.shared.postGasto(newGasto: gasto, diaId: dia.backendId!)
            
            await fetchAllCiclos1()
                
        } catch {
            print("Erro ao criar gasto:", error)
        }
    }
    
    func deleteGasto(diaID: UUID, gastoID: UUID) {
        // Network
    }
}

#Preview {
    CiclosListView()
        .environmentObject(CiclosListViewModel())
}
