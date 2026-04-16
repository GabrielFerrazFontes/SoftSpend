//
//  AddNewGastoSheetView.swift
//  SoftexVamo
//
//  Created by Gabriel fontes on 26/03/26.
//

import SwiftUI

struct AddNewGastoSheetView: View {
    @Environment(\.dismiss) var dismiss
    
    private enum Field: Int, CaseIterable {
        case title, value, date
    }
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    @EnvironmentObject var viewModel: CiclosListViewModel
    
    @State var title: String = ""
    @State var valueString: String = ""
    @State private var value: Float = 0.0
    @State private var selectedCategoria: Categoria = .ALIMENTACAO
    
    let dias: [DiaSoftex]
    @State var selectedDia: DiaSoftex
    
    init(dias: [DiaSoftex]) {
        self.dias = dias
        _selectedDia = State(initialValue: dias.first ?? DiaSoftex.examples[0])
    }
    
    let purplePrimary = Color(red: 147/255, green: 51/255, blue: 234/255)
    let purpleBackground = Color(red: 243/255, green: 232/255, blue: 255/255)
    let grayText = Color.black.opacity(0.6)
    let grayBorder = Color.gray.opacity(0.2)
    
    @FocusState private var focusedField: Field?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20){
                
                Text("Novo Gasto")
                    .font(.system(size: 34, weight: .bold))
                
                VStack {
                    Text("VALOR DA DESPESA")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(grayText.opacity(0.7))
                    HStack {
                        Text("R$")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(grayText.opacity(0.4))
                        Spacer()
                        TextField("0,00", text: $valueString)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 30, weight: .bold))
                    }
                }
                .padding(25)
                .background(Color.white)
                .cornerRadius(30)
                .shadow(color: .black.opacity(0.05), radius: 15, x: 0, y: 10)
                
                VStack(alignment: .leading, spacing: 25) {
                    InputField(title: "Descrição", icon: "") {
                        TextField("Ex: Almoço, Uber...", text: $title)
                            .font(.system(size: 18, weight: .medium))
                            .focused($focusedField, equals: .title)
                    }
                    
                    Divider()
                    
                    DatePickerFieldLimitado(title: "Data", diaSelecionado: $selectedDia, diasPermitidos: dias)
                    
                    Text("Categoria")
                        .font(.system(size: 14, weight: .bold))
                    
                    LazyVGrid(columns: columns) {
                        ForEach(Categoria.allCases) { categoria in
                            let isSelected = (categoria == selectedCategoria)
                            VStack(spacing: 12) {
                                Image(systemName: iconName(for: categoria))
                                    .font(.system(size: 20, weight: .regular))
                                    .frame(height: 30)
                                Text(categoria.localizedName.uppercased())
                                    .font(.system(size: 10, weight: .bold))
                                    .lineLimit(1)
                            }
                            .foregroundStyle(isSelected ? purplePrimary : grayText)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background(isSelected ? purpleBackground : Color.white)
                            .cornerRadius(22)
                            .overlay(
                                RoundedRectangle(cornerRadius: 22)
                                    .stroke(isSelected ? purplePrimary : grayBorder, lineWidth: isSelected ? 2 : 1)
                            )
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedCategoria = categoria
                                }
                            }
                        }
                    }
                    .frame(minHeight: 150)
                }
                .padding(25)
                .background(Color.white)
                .cornerRadius(30)
                .shadow(color: .black.opacity(0.05), radius: 15, x: 0, y: 10)
                
                Button(action: {
                    Task {
                        try await viewModel.createNewGasto(title: title, value: value, dia: selectedDia, categoria: selectedCategoria)
                        await MainActor.run { dismiss() }
                    }
                }) {
                    HStack {
                        Image(systemName: "checkmark")
                        Text("Salvar Gasto")
                    }
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 65)
                    .background(Color(red: 0.65, green: 0.55, blue: 1.0))
                    .cornerRadius(20)
                }
                .padding(.top, 10)
            }
            .padding(.horizontal, 25)
            .padding(.bottom, 50)
        }
        .safeAreaInset(edge: .top) {
            VStack(spacing: 0) {
                HStack {
                    Button(action: { dismiss() }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Voltar")
                        }
                        .foregroundColor(.purple)
                        .font(.system(size: 18, weight: .medium))
                    }
                    Spacer()
                }
                .padding(.horizontal, 25)
                .padding(.vertical, 12)
                .background(Color(red: 0.98, green: 0.98, blue: 0.98))
            }
            .background(.white)
        }
        .background(Color(red: 0.98, green: 0.98, blue: 0.98))
        .onTapGesture { focusedField = nil }
    }
    
    func verificarNumeros(orcamento: String) -> Float{
        
        let orcamentoFiltrado = orcamento.filter { "0123456789,.".contains($0) }
        
        let orcamentoCerto = orcamentoFiltrado.replacingOccurrences(of: ",", with: ".")
        
        if let valorConvertido = Float(orcamentoCerto){
            return valorConvertido
        }
        
        return 0.0
    }
    
    func iconName(for categoria: Categoria) -> String {
        switch categoria {
        case .ALIMENTACAO: return "fork.knife"
        case .TRANSPORTE: return "car.fill"
        case .LAZER: return "ticket.fill"
        case .COMPRAS: return "bag.fill"
        case .OUTROS: return "ellipsis"
        }
    }
}

struct DatePickerFieldLimitado: View {
    let title: String
    @Binding var diaSelecionado: DiaSoftex
    let diasPermitidos: [DiaSoftex]
    
    private var dateRange: ClosedRange<Date> {
        let dates = diasPermitidos.map { $0.data }
        let minDate = dates.min() ?? Date()
        let maxDate = dates.max() ?? Date()
        return minDate...maxDate
    }
    
    private var dateProxy: Binding<Date> {
        Binding<Date>(
            get: {
                self.diaSelecionado.data
            },
            set: { newDate in
                if let foundDia = diasPermitidos.first(where: {
                    Calendar.current.isDate($0.data, inSameDayAs: newDate)
                }) {
                    self.diaSelecionado = foundDia
                }
            }
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
            
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.gray)
                
                DatePicker("", selection: dateProxy, in: dateRange, displayedComponents: .date)
                    .labelsHidden()
                    .environment(\.locale, Locale(identifier: "pt_BR"))
                
                Spacer()
            }
        }
    }
}

func formatarData(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd/MM"
    return formatter.string(from: date)
}

#Preview {
    AddNewGastoSheetView(dias: DiaSoftex.examples)
}
