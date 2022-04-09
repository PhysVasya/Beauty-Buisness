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

struct ProcedureTypesChooseView: View {
    
    public var salonType: SalonType
    @ObservedObject private(set) var salonTypesDB: SalonTypesDB
    @State private(set) var showMainTabBarController: Bool = false
    @State private(set) var addProcedurePressed: Bool = false
    @State private(set) var newProcedureName: String = ""
    
    var body: some View {
        ZStack {
            List {
                ForEach(salonTypesDB.procedures) { procedure in
                    Text(procedure.name!)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                withAnimation(.linear(duration: 0.2)) {
                                    salonTypesDB.deleteProcedure(procedure)
                                    if let index = salonTypesDB.procedures.firstIndex(of: procedure) {
                                        salonTypesDB.procedures.remove(at: index)
                                    }
                                }
                            } label: {
                                Label("Удалить", systemImage: "trash")
                            }
                            .tint(Color.myAccentColor)
                        }
                }
                
                withAnimation(.linear(duration: 0.4)) {
                    AddNewProcedureRow(salonType: salonType, addButtonPressed: addProcedurePressed, newName: $newProcedureName)
                }
                
            }
            .padding(.top, 30)
            .listStyle(.plain)
            .onAppear {
                SalonTypesDB.shared.fetchProceduresForSalonType(salonType)
            }
            .fullScreenCover(isPresented: $showMainTabBarController) {
                MainScreenRabBarControllerRepresented()
                    .ignoresSafeArea()
                
            }
            .toolbar {
                Button("Готово") {
                    showMainTabBarController = true
                }
                .font(.system(size: 16, weight: .bold, design: .default))
                
            }
            .navigationTitle("Перечень услуг")
            
            
            
        }
    }
}

struct FinalStep_Previews: PreviewProvider {
    static var previews: some View {
        ProcedureTypesChooseView(salonType: SalonType(), salonTypesDB: SalonTypesDB.shared)
    }
}
