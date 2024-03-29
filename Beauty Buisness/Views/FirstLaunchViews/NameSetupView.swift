//
//  FirstStep.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 27.03.2022.
//

import SwiftUI


struct NameSetupView: View {
    
    @State private var isActive: Bool = false
    @State private var name: String = ""
    @State private var animate: Bool = false
    @State private var placeholder =  "Поле не может быть пустым"
    @State private var showSecondStep: Bool = false
    @State private var isFirstTimeLaunched: Bool = true
    
    var body: some View {
        NavigationView {
            
            VStack (alignment: .center) {
                NavigationLink(isActive: $showSecondStep) {
                    WorkingHoursSetupView ()
                } label: {
                    Text("")
                }
                
                Text("Введите название салона")
                    .font(.system(size: 26, weight: .semibold, design: .default))
                    .foregroundColor(.myAccentColor)
                    .multilineTextAlignment(.center)
                    .padding(.top, 30)
                
                Spacer()
                HStack {
                    Image(systemName: "pencil")
                        .foregroundColor(.myAccentColor)
                        .font(.title)
                    TextField("",
                              text: $name,
                              prompt: Text(placeholder).font(.system(size: 16))
                    )
                    .font(.system(size: 32, weight: .semibold, design: .rounded))
                    .textInputAutocapitalization(.words)
                    .disableAutocorrection(true)
                    .textFieldStyle(.plain)
                    .multilineTextAlignment(.center)
                    .overlay(Rectangle()
                        .foregroundColor(animate ? .myAccentColor : .gray)
                        .frame(height: animate ? 2 : 1)
                        .opacity(animate ? 1 : 0.1),
                             alignment: .bottom)
                    .animation(.easeIn, value: animate)
                    .onTapGesture {
                        animate = true
                    }
                }
                .padding()
                
                Spacer()
                CustomButton(isActive: $isActive,action: {
                    self.showSecondStep = true
                    UserDefaults.standard.set(name, forKey: "SALON-NAME")
                    
                }, labelText: "Продолжить")
                .onChange(of: name) { newValue in
                    if newValue != "" {
                        isActive = true
                    } else {
                        isActive = false
                    }
                }
            }
            .navigationTitle(Text("Название"))
            .sheet(isPresented: $isFirstTimeLaunched) {
                OnboardingView()
            }
            .padding() 
        }
        .background(Color.myBackgroundColor)
        
    }
}

struct FirstStep_Previews: PreviewProvider {
    static var previews: some View {
        NameSetupView() 
    }
}
