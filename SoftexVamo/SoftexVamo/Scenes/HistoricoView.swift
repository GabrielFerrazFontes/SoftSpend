//
//  HistoricoView.swift
//  SoftexVamo
//
//  Created by Joao Victor on 06/04/26.
//

import SwiftUI

struct HistoricoView: View {
    
    @EnvironmentObject var viewModel: CiclosListViewModel
    @State var navegando = false
    @State private var showingModal = false
    
    let newCicloViewModel = NewCicloViewModel()
    
    var body: some View {
        NavigationStack{
            ScrollView{
                VStack{
                    VStack(alignment: .leading){
                        Text("Histórico")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        Text("Todos os seu ciclos registrados")
                            .foregroundStyle(Color.black.opacity(0.45))
                            .padding(.horizontal)
                            .padding(.bottom)
                        ForEach(viewModel.allCiclos){ ciclo in
                            CardCiclosView(ciclo: ciclo)
                                .environmentObject(viewModel)
                                .id("\(ciclo.id)-\(viewModel.actualCiclo.id)")
                        }
                    }
                    
                    Button{
                        showingModal.toggle()
                    }label: {
                        HStack(alignment: .center, spacing: 12) {
                            Image(systemName: "plus")
                                .font(.system(size: 18))
                                .foregroundStyle(Color.black.opacity(0.75))
                                .frame(width: 40, height: 40)
                                .background(Color.black.opacity(0.02))
                                .cornerRadius(16)
                            
                            Text("Criar Novo Ciclo")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(Color.black.opacity(0.35))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 100)
                        .background {
                            RoundedRectangle(cornerRadius: 18)
                                .strokeBorder(
                                    Color.gray.opacity(0.4),
                                    style: StrokeStyle(lineWidth: 2, dash: [3])
                                )
                                .background(Color.white)
                                .cornerRadius(18)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                    }
                    .fullScreenCover(isPresented: $showingModal) {
                        NewCicloView()
                            .environmentObject(newCicloViewModel)
                    }
                }
                
            }
        }
        .padding(.top, 20)
        .onAppear(){
            Task{
                await viewModel.fetchAllCiclos1()
            }
            
        }
        
    }
}

#Preview {
    HistoricoView()
        .environmentObject(CiclosListViewModel())
}
