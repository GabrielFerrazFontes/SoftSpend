//
//  PerfilView.swift
//  SoftSpend
//
//  Created by Gabriel fontes on 07/05/26.
//

import SwiftUI
import Combine

struct PerfilView: View {
    @StateObject var viewModel = PerfilViewModel()
    
    var body: some View {
        VStack(alignment: .leading){
            VStack(alignment: .leading){
                Text("Estatísticas")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Saber onde está gastando mais")
                    .foregroundStyle(Color("textSecondary"))
                    .padding(.bottom)
            }
            .padding()
            
            // colocar view para total gasto
            // colocar view para total economizado
            
            ScrollView{
                VStack(alignment: .leading){
                    
                    ForEach(viewModel.statistics, id: \.self){ stat in
                        CardCategoryView(
                            percent: stat.percent,
                            category: stat.categoria.localizedName,
                            systemImage: stat.categoria.systemImageName,
                            totalGasto: stat.totalGasto)
                    }
                }
            }
        }
    }
}

#Preview {
    PerfilView()
}

struct StatisticModel: Hashable {
    let categoria: Categoria
    let percent: Float
    let totalGasto: Float
}

final class PerfilViewModel: ObservableObject {
    @Published var statistics: [StatisticModel] = []
    @Published var totalGasto: Float = 0.0
    
    func fetchStatistics() {
        // chamar a rota com o valor total geral gasto
        
        // chamar a rota com as estatisticas de cada categoria
    }
}
