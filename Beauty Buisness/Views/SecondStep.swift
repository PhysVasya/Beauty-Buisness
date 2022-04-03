//
//  SecondStep.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 29.03.2022.
//

import SwiftUI

struct DatePickerRepresentable: UIViewRepresentable {
    
    @Binding var date: Date
    
    func makeCoordinator() -> Coordinator {
        Coordinator(date: $date)
    }
    
    
    
    func makeUIView(context: Context) -> UIDatePicker {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .time
        datePicker.minuteInterval = 15
        datePicker.addTarget(context.coordinator, action: #selector(Coordinator.changed(_:)), for: .valueChanged)
        return datePicker
    }
    
    func updateUIView(_ uiView: UIDatePicker, context: Context) {
        
    }
    
    typealias UIViewType = UIDatePicker
    
    class Coordinator: NSObject {
        private let date: Binding<Date>
        
        init(date: Binding<Date>) {
            self.date = date
        }
        
        @objc func changed(_ sender: UIDatePicker) {
            self.date.wrappedValue = sender.date
        }
    }
    
    
}

struct SecondStep: View {
    
    @Environment (\.dismiss) private var dismiss
    
    @FocusState private var animate: Bool
    @State private var placeholder =  "Поле не может быть пустым"
    @State private var placeholderNeeded: Bool = false
    @State private var startingHour: Date = Date()
    @State private var endingHour: Date = Date()
    @State private var timeIsEqual: Bool = true
    
    public let finalStep: ((_ startingHour: Date, _ endingHour: Date) -> Void)?
    
    var body: some View {
        ZStack {
            Color.myBackgroundColor
            VStack (alignment: .center) {
                
                Text("Укажите часы работы")
                    .font(.system(size: 26, weight: .semibold, design: .default))
                    .padding(.top, 200)
                    .padding(.bottom, 100)
                    .foregroundColor(.myAccentColor)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 20) {
                    Image(systemName: "clock")
                        .foregroundColor(.myAccentColor)
                        .font(.title)
                    
                    Text("С")
                    DatePickerRepresentable(date: $startingHour)
                    
                    Text("До")
                    DatePickerRepresentable(date: $endingHour)
                    
                    
                }
                
                ZStack {
                   
                    CustomButton(action: {

                        finalStep?(startingHour, endingHour)
                        dismiss()
                        
                    }, labelText: "Продолжить")
                    .padding(.vertical, 80)
                    
                    RoundedRectangle(cornerRadius: 20)
                        .frame(width: 350, height: 60, alignment: .center)
                        .foregroundColor(.myBackgroundColor)
                        .opacity(timeIsEqual ? 0.8 : 0)
                        .animation(.easeIn, value: timeIsEqual)
                        .onChange(of: startingHour) { newValue in
                            timeIsEqual = newValue >= endingHour
                        }
                        
                }
                
            
            }
            .padding(.horizontal, 40)
        }
        .ignoresSafeArea()
    }
}


struct SecondStep_Previews: PreviewProvider {
    static var previews: some View {
        SecondStep(finalStep: {_,_  in})
    }
}
