//
//  AddNewGastoSheetView.swift
//  SoftexVamo
//
//  Created by Gabriel fontes on 26/03/26.
//

import SwiftUI

struct AddNewGastoSheetView: View {
    @Environment(\.dismiss) var dismiss
    
    @State var title: String = ""
    @State var value: Decimal = 0
    @State var selectedDia: DiaSoftex
        
    let dias: [DiaSoftex]
    let action: (String, Decimal, DiaSoftex) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Titulo do Gasto", text: $title)
                    TextField("Valor do Gasto", value: $value, format: .currency(code: "BRL"))
                        .keyboardType(.decimalPad)
                    Picker("Dia do Gasto", selection: $selectedDia){
                        ForEach(dias) { dia in
                                    Text(formatarData(dia.data)).tag(dia)
                                }
                    }
                }
            }
            .navigationTitle("Adicionar Novo Gasto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("", systemImage: "checkmark.circle") {
                    action(title, value, selectedDia)
                    dismiss()
                }
            }
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
