//
//  ThirdStep.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 08.04.2022.
//

import SwiftUI

struct SalonTypesChooseView: View {
    
    @ObservedObject private(set) var types: SalonTypesDB = SalonTypesDB.shared
    @State private(set) var addSalonTypePressed: Bool = false
    @State private(set) var newSalonTypeName: String = ""
    
    var body: some View {
        
        List  {
            ForEach(types.salonTypes) { type in
                
                NavigationLink(type.type!) {
                    ProcedureTypesChooseView(salonType: type, salonTypesDB: SalonTypesDB.shared)
                    
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button {
                        
                    } label: {
                        Label("Удалить", systemImage: "trash")
                    }
                    .tint(Color.myAccentColor)
                }
            }
            AddNewSalonTypeRow(addButtonPressed: addSalonTypePressed, newName: $newSalonTypeName)
        }
        .padding(.top, 30)
        .listStyle(.plain)
        .navigationTitle("Выберите тип услуг")
        .navigationViewStyle(.automatic)
        .navigationBarTitleDisplayMode(.large)
    }
}

struct ThirdStep_Previews: PreviewProvider {
    static var previews: some View {
        SalonTypesChooseView(types: SalonTypesDB.shared)
    }
}
