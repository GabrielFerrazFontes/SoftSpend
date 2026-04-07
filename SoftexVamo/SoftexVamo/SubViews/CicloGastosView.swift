//
//  CicloGastosView.swift
//  SoftexVamo
//
//  Created by Gabriel fontes on 25/03/26.
//

import SwiftUI
import Combine

struct CicloGastosView: View {
    @EnvironmentObject var viewModel: CicloGastosViewModel
    
    let action: () -> Void
    let deleteAction: (UUID, Int) -> Void
    
    func removerGastoEspecifico(dia: DiaSoftex, index: Int) {
        let indexSet = IndexSet(integer: index)
        let gastoID = viewModel.deleteGasto(dia: dia, offsets: indexSet)
        deleteAction(dia.id, gastoID)
    }
    
    var body: some View {
        ScrollView{
            VStack(alignment: .leading) {
                
                Text("Gastos Registrados")
                    .font(.system(size: 20, weight: .bold))
                HStack{
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Procurar gasto...", text: $viewModel.searchGastoText)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(
                        color: Color.black.opacity(0.1),
                        radius: 10,
                    )
                    .overlay{
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(.gray, lineWidth: 0.2)
                    }
                    
                    
                    Image(systemName: "line.3.horizontal.decrease")
                        .padding(.vertical, 16)
                        .padding(.horizontal, 12)
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(
                            color: Color.black.opacity(0.1),
                            radius: 10,
                        )
                        .overlay{
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(.gray, lineWidth: 0.2)
                        }
                }
                ForEach(viewModel.secoesExibidas) { dia in
                    Section(header: createSectionHeader(dia: dia)) {
                        ZStack{
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .shadow(radius: 2)
                            VStack{
                                ForEach(Array(dia.gastos.enumerated()), id: \.element.id) { index, gasto in
                                    createGastoCell(gasto: gasto) {
                                        removerGastoEspecifico(dia: dia, index: index)
                                    }
                                }
                                .onDelete { indexSet in
                                    let gastoID = viewModel.deleteGasto(dia: dia, offsets: indexSet)
                                    deleteAction(dia.id, gastoID)
                                }
                                
                            }
                            .padding()
                        }
                    }
                }
                
            }
            .padding()
        }
    }
    
    @ViewBuilder func createSectionHeader(dia: DiaSoftex) -> some View {
        HStack {
            if Calendar.current.isDateInToday(dia.data) {
                Text("HOJE")
                
            } else if Calendar.current.isDateInYesterday(dia.data) {
                Text("ONTEM")
                
            } else {
                Text(viewModel.dateToString(date: dia.data))
            }
            
            Spacer()
        }
        .font(.system(size: 16, weight: .medium))
        .foregroundStyle(Color.black.opacity(0.55))
        
    }
    
    @ViewBuilder func createGastoCell(gasto: GastosDia, onDelete: @escaping () -> Void) -> some View {
        HStack {
            
            Image(systemName: "car")
                .font(.system(size: 25, weight: .bold))
                .padding()
                .foregroundStyle(Color.white)
                .background(Color.orange)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            
            VStack(alignment: .leading){
                Text(gasto.titulo)
                    .font(.system(size: 18, weight: .bold))
                    .padding(.bottom, 10)
                
                Text("Locomoção")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.black.opacity(0.35))
            }
            .padding(6)
            
            Spacer()
            VStack(alignment:.trailing){
                Text(gasto.valor, format: .currency(code: "BRL"))
                    .font(.system(size: 18, weight: .bold))
                Button {
                    onDelete()
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 70)
    }
}

#Preview {
    CicloGastosView() {
        print("ok")
    } deleteAction: { _,_ in
        print("")
    }
    .environmentObject(CicloGastosViewModel(ciclo: CicloSoftex.example))
}

final class CicloGastosViewModel: ObservableObject {
    
    @Published var ciclo: CicloSoftex = CicloSoftex.example
    @Published var searchGastoText: String = ""
    
    let cicloViewModel: CiclosListViewModel = CiclosListViewModel()
    
    init(ciclo: CicloSoftex) {
        self.ciclo = cicloViewModel.actualCiclo
    }
    
    
    
    func dateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.string(from: date)
    }
    
    var secoesExibidas: [DiaSoftex] {
        if searchGastoText.isEmpty { return ciclo.dias }
        
        return ciclo.dias.compactMap { dia in
            let gastosQueBatem = dia.gastos.filter {
                $0.titulo.localizedCaseInsensitiveContains(searchGastoText)
            }
            
            if gastosQueBatem.isEmpty { return nil }
            
            var diaFiltrado = dia
            diaFiltrado.gastos = gastosQueBatem
            return diaFiltrado
        }
    }
    
    func deleteGasto(dia: DiaSoftex, offsets: IndexSet) -> Int {
        
        let gastosExibidos = dia.gastos.filter {
            $0.titulo.localizedCaseInsensitiveContains(searchGastoText)
        }
        
        guard let firstOffset = offsets.first,
              firstOffset < gastosExibidos.count else { return 0 }
        
        let gastoParaRemover = gastosExibidos[firstOffset]
        let backendID = gastoParaRemover.backendId ?? 0
        
        if let diaIndex = ciclo.dias.firstIndex(where: { $0.id == dia.id }) {
            ciclo.dias[diaIndex].gastos.removeAll(where: { $0.id == gastoParaRemover.id })
        }
        
        return backendID
    }
}
