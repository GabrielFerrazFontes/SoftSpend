//
//  AddNewGastoSheetView.swift
//  SoftexVamo
//
//  Created by Gabriel fontes on 26/03/26.
//

import SwiftUI

struct AddNewGastoSheetView: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var viewModel: CiclosListViewModel
    
    @State var title: String = ""
    @State var value: Decimal = 0
    
    @State private var selectedCategoria: Categoria = .OUTROS
    
    let dias: [DiaSoftex]
    @State var selectedDia: DiaSoftex?
    //    let action: (String, Decimal, DiaSoftex) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Titulo do Gasto", text: $title)
                    TextField("Valor do Gasto", value: $value, format: .currency(code: "BRL"))
                        .keyboardType(.decimalPad)
                    Picker("Dia do Gasto", selection: $selectedDia){
                        ForEach(dias) { dia in
                            Text(formatarData(dia.data)).tag(dia as DiaSoftex?)
                            
                        }
                        
                    }
                    
                    Picker("Categoria", selection: $selectedCategoria) {
                        ForEach(Categoria.allCases) { categoria in
                            Text(categoria.localizedName)
                                .tag(categoria)
                        }
                    }
                }
                
                Button(action: {
                    guard let diaSeguro = selectedDia else { return }
                        Task {
                            do {
                                try await viewModel.createNewGasto(
                                    title: title,
                                    value: value,
                                    dia: diaSeguro,
                                    categoria: selectedCategoria
                                )

                                await MainActor.run {
                                            dismiss()
                                        }
                            } catch {
                                print("Erro ao salvar gasto: \(error.localizedDescription)")
                            }
                        }
                }, label: {
                    VStack{
                        Text("sdajjbdakjs")
                    }
                })
            }
            .onAppear {
                    // Inicializa com o primeiro dia assim que a tela carrega
                    if selectedDia == nil {
                        selectedDia = dias.first
                    }
                }
            .navigationTitle("Adicionar Novo Gasto")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

func formatarData(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd/MM"
    return formatter.string(from: date)
}

//#Preview {
//    AddNewGastoSheetView() { _,_,_ in
//        print("action")
//    }
//}
