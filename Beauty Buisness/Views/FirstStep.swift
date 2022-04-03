//
//  FirstStep.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 27.03.2022.
//

import SwiftUI

struct FirstStep: View {
    
    @State private var name: String = ""
    @FocusState private var animate: Bool
    @State private var placeholder =  "Поле не может быть пустым"
    @State private var placeholderNeeded: Bool = false
    
    public let nextStep: ((String) -> Void)?
    
    var body: some View {
        
        ZStack {
            Color.myBackgroundColor
            VStack (alignment: .center) {
                
                Text("Введите название салона")
                    .font(.system(size: 26, weight: .semibold, design: .default))
                    .padding(.top, 200)
                    .padding(.bottom, 100)
                    .foregroundColor(.myAccentColor)
                    .multilineTextAlignment(.center)
                
                Spacer()
                HStack {
                    Image(systemName: "pencil")
                        .foregroundColor(.myAccentColor)
                        .font(.title)
                    TextField("",
                              text: $name,
                              prompt: placeholderNeeded ? Text(placeholder).font(.system(size: 16)) : Text("")
                    )
                    .font(.system(size: 32, weight: .semibold, design: .rounded))
                    .keyboardType(.alphabet)
                    .textInputAutocapitalization(.characters)
                    .disableAutocorrection(true)
                    .textFieldStyle(.plain)
                    .multilineTextAlignment(.center)
                    .onSubmit {
                        if name == "" {
                            placeholderNeeded = true
                        } else {
                            placeholderNeeded = false
                        }
                    }
                    .focused($animate)
                    .overlay(Rectangle()
                        .foregroundColor(animate ? .myAccentColor : .gray)
                        .frame(height: animate ? 2 : 1)
                        .opacity(animate ? 1 : 0.1),
                             alignment: .bottom)
                    .animation(.easeIn, value: animate)
                }
                
                Spacer()
                CustomButton(action: {
                    if name != "" {
                        nextStep?(name)
                    }
                }, labelText: "Продолжить")
                .padding(.vertical, 80)
            }
            .padding(.horizontal, 40)
        }
        .ignoresSafeArea()
    }
}

struct FirstStep_Previews: PreviewProvider {
    static var previews: some View {
        FirstStep( nextStep: {_ in })
    }
}
