//
//  SoftexVamoApp.swift
//  SoftexVamo
//
//  Created by Gabriel fontes on 25/03/26.
//

import SwiftUI
import SwiftData

@main
struct SoftexVamoApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                CiclosListView()
                    .environmentObject(CiclosListViewModel())
                    .tabItem {
                        Label("Ciclos", systemImage: "airplane.up.right")
                    }
                NewCicloView()
                    .environmentObject(NewCicloViewModel())
                    .tabItem {
                        Label("Novo Ciclo", systemImage: "plus")
                    }
            }
        }
    }
}
