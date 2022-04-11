//
//  AddNewProcedureRow.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 09.04.2022.
//

import SwiftUI

struct AddNewProcedureRow: View {
    
    
    public var salonType: SalonType
    @State private(set) var addButtonPressed: Bool = false
    @Binding private(set) var newName: String
    @FocusState private var isEditing: Bool
    
    var body: some View {
        ZStack {
            
            if addButtonPressed {
                TextField("", text: $newName, prompt: Text("Название"))
                    .textFieldStyle(.plain)
                    .focused($isEditing)
                    .onSubmit {
                        if newName != "" {
                            SalonTypesDB.shared.addProcedure(procedureName: newName, for: salonType)
                            addButtonPressed = false
                            newName = ""
                            isEditing = false
                        }
                        
                    }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            isEditing = true
                        }
                    }
                    .offset(x: addButtonPressed ? 0 : 50)
                
            } else {
                
                Button {
                    addButtonPressed = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Добавить...")
                    }
                    .foregroundColor(Color.myAccentColor)
                }
                .offset(x: addButtonPressed ? -50 : 0)
                
            }
        }
        .animation(.easeIn(duration: 0.2), value: addButtonPressed)
        
        
    }
    
}

//struct AddNewProcedureRow_Previews: PreviewProvider {
//    static var previews: some View {
//        AddNewProcedureRow(newName: <#T##Binding<String>#>)
//    }
//}
