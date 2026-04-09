//
//  CicloInfoView.swift
//  SoftexVamo
//
//  Created by Gabriel fontes on 26/03/26.
//

import SwiftUI
import Charts

struct CicloInfoView: View {
    @Binding var gastos: GastosDia
    @Binding var available: GastosDia
    
    var body: some View {
        HStack {
            Chart {
                SectorMark(
                    angle: .value(gastos.titulo, gastos.valor),
                    innerRadius: MarkDimension.ratio(0.6),
                    angularInset: 4
                )
                .foregroundStyle(.red)
                .cornerRadius(8)
                SectorMark(
                    angle: .value(available.titulo, available.valor),
                    innerRadius: MarkDimension.ratio(0.6),
                    angularInset: 4
                )
                .foregroundStyle(.blue)
                .cornerRadius(8)
            }
            VStack(alignment: .leading) {
                Text("\(gastos.titulo): R$\(gastos.valor, specifier: "%.2f")")
                    .foregroundStyle(.red)
                Text("\(available.titulo): R$\(available.valor, specifier: "%.2f")")
                    .foregroundStyle(.blue)
            }
            .padding(.leading)
        }
    }
}
