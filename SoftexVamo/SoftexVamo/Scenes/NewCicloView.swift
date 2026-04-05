//
//  NewCicloView.swift
//  SoftexVamo
//
//  Created by Gabriel fontes on 26/03/26.
//

import SwiftUI
import Combine

struct NewCicloView: View {
    @EnvironmentObject var viewModel: NewCicloViewModel
    
    @State var startDate: Date = Date()
    @State var endDate: Date = Date()
    @State var totalValue: Float = 2500
    @State var titulo: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Titulo", text: $titulo)
                    TextField("Valor do Gasto", value: $totalValue, format: .currency(code: "BRL"))
                        .keyboardType(.decimalPad)
                    DatePicker("Dia de Inicio", selection: $startDate, displayedComponents: .date)
                    DatePicker("Dia de Inicio", selection: $endDate, displayedComponents: .date)
                }
                if !viewModel.textResult.isEmpty {
                    Section {
                        HStack {
                            Spacer()
                            Text(viewModel.textResult)
                                .multilineTextAlignment(.center)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Criar Novo Ciclo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("", systemImage: "checkmark.circle") {
                    Task{
                        await viewModel.createNewCiclo(startDate: startDate, endDate: endDate, totalValue: totalValue, titulo: titulo)
                    }
                }
            }
        }
    }
}

#Preview {
    NewCicloView()
        .environmentObject(NewCicloViewModel())
}

final class NewCicloViewModel: ObservableObject {
    @Published var textResult = ""
    
    func createNewCiclo(startDate: Date, endDate: Date, totalValue: Float, titulo: String) async {
        let dayCount = Calendar.current.datesBetween(startDate, and: endDate)
        let saldo = totalValue / Float(dayCount)
        var days: [DiaSoftex] = createAllDays(dayCount: dayCount, startDate: startDate, saldo: saldo)
        let periodo = createPeriodoString(from: startDate, to: endDate)
        
        let newCiclo = CicloSoftex(valor_total: totalValue, gasto_total: 0, periodo: periodo, diaria: saldo, titulo: titulo, dias: days, id_usuario: 1)
 
        await postToNetwork(newCiclo: newCiclo, daysCount: dayCount)
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
        // Network
        do {
            try await NetworkManager.shared.postCiclo(newCiclo: newCiclo )

        } catch {
            print("Erro ao criar o ciclo:", error)
        }
        printNewCicloData(newCiclo, numberOfDays: daysCount)
    }
    
    private func printNewCicloData(_ newCiclo: CicloSoftex, numberOfDays: Int) {
        let text = """
            \(newCiclo.periodo)
            Quantidade de Dias: \(numberOfDays)
            Valor Total: \(newCiclo.valor_total.formatted(.currency(code: "BRL")))
            Valor por Dia: \(newCiclo.diaria.formatted(.currency(code: "BRL")))
            """
        textResult = text
    }
}
