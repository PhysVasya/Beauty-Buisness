//
//  FinalStep.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 08.04.2022.
//

import SwiftUI

struct MainScreenRabBarControllerRepresented: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> MainScreenTabBarController {
        return MainScreenTabBarController()
    }
    
    func updateUIViewController(_ uiViewController: MainScreenTabBarController, context: Context) {
        
    }
    
    typealias UIViewControllerType = MainScreenTabBarController
    
    
}

struct FinalStep: View {
    
    public var salonType: SalonType
    @ObservedObject private(set) var salonTypesDB: SalonTypesDB
    @State private(set) var showMainTabBarController: Bool = false
    
    var body: some View {
       
            List(salonTypesDB.procedures) { procedure in
                Text(procedure.name!)
                
            }
            .onAppear {
                SalonTypesDB.shared.fetchProceduresForSalonType(salonType)
            }
            .fullScreenCover(isPresented: $showMainTabBarController) {
                MainScreenRabBarControllerRepresented()

            }
            .toolbar {
                Button("Готово") {
                    showMainTabBarController = true
                }
                .font(.system(size: 14, weight: .bold, design: .default))
            
            }
            .navigationTitle("Перечень услуг")
        
        
      
    }
}

struct FinalStep_Previews: PreviewProvider {
    static var previews: some View {
        FinalStep(salonType: SalonType(), salonTypesDB: SalonTypesDB.shared)
    }
}
