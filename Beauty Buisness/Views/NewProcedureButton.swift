//
//  NewProcedureButton.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 30.03.2022.
//

import SwiftUI



struct NewProcedureButton: View {
    
    @State private var appeared = false
    @ObservedObject var elements: ObservableElementsForNewProcedureButton
    var previousContentOffset: CGFloat = CGFloat()
    
    var tap: (() -> Void)?
    
    var body: some View {
        Button {
            tap?()
                
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                Text("Новая запись")
                    .foregroundColor(Color.myBackgroundColor)
                    .font(.system(size: 14, weight: .semibold, design: .default))
            }
        }
        .frame(width: 150, height: 40, alignment: .center)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.easeIn(duration: 0.2), value: appeared)
        .onChange(of: elements.offset) { newValue in
            if newValue! > previousContentOffset || newValue! < previousContentOffset {
                appeared = true
                Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
                    appeared = false
                }
            }
          
            
        }
        .onAppear {
            if elements.events == 0 {
                appeared = true
            }
        }
       
             
    }
}

struct NewProcedureButton_Previews: PreviewProvider {
    static var previews: some View {
        NewProcedureButton(elements: ObservableElementsForNewProcedureButton(), tap: {})
    }
}


//Observing elements for correct visualisation of button.
//IF events == 0, it should be on the screen when the view loads up. THEN it should only listen to the offset.

class ObservableElementsForNewProcedureButton: ObservableObject {
    @Published var offset: CGFloat?
    @Published var events: Int?
}



