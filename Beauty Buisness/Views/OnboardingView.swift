//
//  GreetingsView.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 26.03.2022.
//

import SwiftUI

struct Comment: View {
    var imageName: String
    var text: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            Image(systemName: imageName)
                .imageScale(.medium)
                .font(.largeTitle)
                .foregroundColor(.myAccentColor)
                .frame(minWidth: 40)
            Text(text)
                .font(.subheadline.weight(.regular))
                .frame(minWidth: 250, minHeight: 40, alignment: .leading)
                .multilineTextAlignment(.leading)
        }
        .padding()
    }
}

struct CustomButton: View {
    
    var action: (() -> Void)?
    var labelText: String = ""
    
    var body: some View {
        Button {
            action?()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: 350, height: 60, alignment: .center)
                    .foregroundColor(.myAccentColor)
                Text(labelText)
                    .font(.body.weight(.semibold))
                    .foregroundColor(.myBackgroundColor)
                    .lineLimit(0)
            }
        }
    }
}


struct OnboardingView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.myBackgroundColor
            VStack(alignment: .center) {
                //TOP
                Text("Добро пожаловать в Beauty Buisness!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.vertical)
                    .multilineTextAlignment(.center)
                    .padding(.top, 80)
                    .frame(minHeight: 180)
                
                Spacer()
                //CENTER
                VStack (alignment: .leading) {
                    Comment(imageName: "person.fill", text: "Данное приложение позволяет удобно организовать отчет клиентуры")
                    Comment(imageName: "pencil.tip", text: "Позволяет вести удобную запись клиентов")
                    Comment(imageName: "note.text", text: "Позволяет вести заметки")
                }
                .padding()
                
                Spacer()
                
                CustomButton(action: {
                    dismiss()
                }, labelText: "Продолжить")
                .padding(.vertical, 80)
                //END OF BUTTON
            }
            .padding(.horizontal)
            //END OF VSTACK
        }
        .edgesIgnoringSafeArea(.all)
        
    }
    
}

struct GreetingsView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
            .previewDevice("iPhone 12")
    }
}
