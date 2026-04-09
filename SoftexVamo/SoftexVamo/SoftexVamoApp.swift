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
    @StateObject var listViewModel = CiclosListViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(listViewModel)
        }
    }
}
