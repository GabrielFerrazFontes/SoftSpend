//
//  HistoricoView.swift
//  SoftexVamo
//
//  Created by Joao Victor on 06/04/26.
//

import SwiftUI

struct HistoricoView: View {
    
    @EnvironmentObject var viewModel: CiclosListViewModel
    
    var body: some View {
        NavigationStack{
            ScrollView{
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
                    }
                    
                }

            }
//
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
