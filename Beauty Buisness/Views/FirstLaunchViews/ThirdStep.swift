//
//  ThirdStep.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 08.04.2022.
//

import SwiftUI

struct ThirdStep: View {
    
    private let types = SalonTypesDB.shared.salonTypes

    var body: some View {
        
        List  {
            ForEach(types) { type in
                
                NavigationLink(type.type!) {
                    FinalStep(salonType: type, salonTypesDB: SalonTypesDB.shared)
                       
                }
                
               
            }
        }
        .navigationTitle("Выберите тип услуг")
        .navigationViewStyle(.automatic)
        .navigationBarTitleDisplayMode(.large)
        
        
    }
}

struct ThirdStep_Previews: PreviewProvider {
    static var previews: some View {
        ThirdStep()
    }
}
