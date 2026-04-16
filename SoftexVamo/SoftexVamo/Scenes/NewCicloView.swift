//
//  NewCicloView.swift
//  SoftexVamo
//
//  Created by Gabriel fontes on 26/03/26.
//

import SwiftUI
import Combine

struct NewCicloView: View {
    
    private enum Field: Int, CaseIterable {
        case nomeCiclo, orcamento
    }
    
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var cicloViewModel: CiclosListViewModel
    
    @State private var nomeCiclo: String = ""
    @State private var orcamentoString: String = ""
    @State private var orcamento: Float = 0.0
    @State private var dataInicio = Date()
    @State private var dataFim = Date().addingTimeInterval(86400 * 7)
    
    @FocusState private var focusedField: Field?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Button(action: { dismiss() }) {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Voltar")
                }
                .foregroundColor(.purple)
                .font(.system(size: 18, weight: .medium))
            }
            .padding(.top, 10)
            
            Text("Novo Ciclo")
                .font(.system(size: 34, weight: .bold))
                .padding(.bottom, 10)
            
            VStack(spacing: 25) {
                InputField(title: "Nome do Ciclo", icon: "mappin.and.ellipse") {
                    TextField("Ex: São Paulo, SP", text: $nomeCiclo)
                        .font(.system(size: 18, weight: .medium))
                        .focused($focusedField, equals: .nomeCiclo)
                }
                
                Divider()
                
                InputField(title: "Orçamento Total", icon: "briefcase") {
                    HStack {
                        Text("R$")
                            .foregroundStyle(Color(.secondaryLabel).opacity(0.65))
                            .font(.system(size: 18, weight: .medium))
                        TextField("0,00", text: $orcamentoString)
                            .keyboardType(.decimalPad)
                            .onChange(of: orcamentoString) { oldValue, newValue in
                                orcamento = verificarNumeros(orcamento: newValue)
                            }
                            .font(.system(size: 18, weight: .heavy))
                            .focused($focusedField, equals: .orcamento)
                    }
                }
                
                Divider()
                
                VStack(spacing: 20) {
                    DatePickerField(title: "Data de Início", date: $dataInicio)
                    DatePickerField(title: "Data de Fim", date: $dataFim)
                }
            }
            .padding(25)
            .background(Color.white)
            .cornerRadius(30)
            .shadow(color: .black.opacity(0.05), radius: 15, x: 0, y: 10)
            
            Spacer()
            
            Button(action: {
                Task{
                    await cicloViewModel.createNewCiclo(startDate: dataInicio, endDate: dataFim, totalValue: Float(orcamento), titulo: nomeCiclo)
                    
                    await MainActor.run {
                        dismiss()
                    }
                }
            }) {
                HStack {
                    Image(systemName: "checkmark")
                    Text("Criar Ciclo")
                }
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 65)
                .background(Color(red: 0.65, green: 0.55, blue: 1.0))
                .cornerRadius(20)
            }
        }
        .onTapGesture {
            focusedField = nil
        }
        .padding(.horizontal, 25)
        .background(Color(red: 0.98, green: 0.98, blue: 0.98))
        .navigationBarHidden(true)
        
    }
    
    func verificarNumeros(orcamento: String) -> Float{
        
        let orcamentoFiltrado = orcamento.filter { "0123456789,.".contains($0) }
        
        let orcamentoCerto = orcamentoFiltrado.replacingOccurrences(of: ",", with: ".")
        
        if let valorConvertido = Float(orcamentoCerto){
            return valorConvertido
        }
        
        return 0.0
    }
}

struct InputField<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.black)
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.gray)
                content
                    .font(.system(size: 16))
            }
        }
    }
}

struct DatePickerField: View {
    
    let title: String
    @Binding var date: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
            
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.gray)
                
                DatePicker("", selection: $date, displayedComponents: .date)
                    .labelsHidden()
                    .environment(\.locale, Locale(identifier: "pt_BR"))
                //                    .colorMultiply(.clear)
                
                Spacer()
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
    
    
    
    
    
    
    
}
