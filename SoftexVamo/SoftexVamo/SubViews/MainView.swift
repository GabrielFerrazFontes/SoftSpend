//
//  TabView.swift
//  SoftexVamo
//
//  Created by Joao Victor on 06/04/26.
//

import SwiftUI

struct MainView: View {
    
    @EnvironmentObject var viewModel: CiclosListViewModel
    let newCicloViewModel = NewCicloViewModel()
    @State var sheetview = false

    let primaryPurple = Color(red: 0.54, green: 0.36, blue: 1.0)
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                if viewModel.selectedTab == 0 {
                    CiclosListView()
                } else {
                    HistoricoView()
                }
            }
            .environmentObject(viewModel)
            
            HStack {
                Button(action: {
                    viewModel.selectedTab = 0
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: viewModel.selectedTab == 0 ? "house.fill" : "house")
                            .font(.system(size: 22))
                        Text("Início")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(viewModel.selectedTab == 0 ? primaryPurple : .gray)
                }
                .frame(maxWidth: .infinity)
                
                Button(action: {
                    sheetview.toggle()
                }) {
                    ZStack {
                        Circle()
                            .fill(primaryPurple)
                            .frame(width: 64, height: 64)
                            .shadow(color: primaryPurple.opacity(0.4), radius: 10, x: 0, y: 5)
                        Image(systemName: "plus.circle")
                            .font(.system(size: 30, weight: .light))
                            .foregroundColor(.white)
                    }
                }.fullScreenCover(isPresented: $sheetview){
                    AddNewGastoSheetView(dias: viewModel.actualCiclo.dias)
                        .environmentObject(viewModel)
                }
                .offset(y: -24)

                
                
                Button(action: {
                    viewModel.selectedTab = 1
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 22))
                        Text("Histórico")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(viewModel.selectedTab == 1 ? primaryPurple : .gray)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.top, 12)
            .padding(.bottom, 24)
            .background(Color("surfaceBackground"))
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: -5)
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }
}

struct CustomTabBarView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(CiclosListViewModel())
    }
}
