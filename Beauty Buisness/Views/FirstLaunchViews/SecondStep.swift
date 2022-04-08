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
    
    @State private var presentThirdStep: Bool = false
    @State private var startingHour: Date = Date()
    @State private var endingHour: Date = Date()
    @State private var timeIsEqual: Bool = true
    @State private var isActive: Bool = false
        
    var body: some View {
        
            VStack (alignment: .center) {
                
                Text("Укажите часы работы")
                    .font(.system(size: 26, weight: .semibold, design: .default))
                    .foregroundColor(.myAccentColor)
                    .multilineTextAlignment(.center)
                    .padding(.top, 30)
                
                Spacer()
                HStack(spacing: 20) {
                    Image(systemName: "clock")
                        .foregroundColor(.myAccentColor)
                        .font(.title)
                    
                    VStack {
                        HStack {
                            Text("Начало работы")
                            DatePickerRepresentable(date: $startingHour)
                                .frame(height: 50, alignment: .center)
                        }
                        HStack {
                            Text("Конец работы")
                            DatePickerRepresentable(date: $endingHour)
                                .frame(height: 50, alignment: .center)
                        }
                    }
                }
                Spacer()
                ZStack {
                    
                    CustomButton(isActive: $isActive, action: {
                        self.presentThirdStep = true
                        saveWorkingHours()
                        
                    }, labelText: "Продолжить")
                    .onChange(of: startingHour) { newValue in
                        timeIsEqual = newValue >= endingHour
                        isActive = !timeIsEqual
                    }
                    NavigationLink(isActive: $presentThirdStep, destination: {
                        ThirdStep()
                    }) {
                        Text("")
                    }
                    
                }
                .navigationTitle(Text("Время работы"))
            }
            .padding()
        
    }
    
    
    func saveWorkingHours () {
        let startingDateComps = Calendar.current.dateComponents([.hour, .minute], from: startingHour)
        let endingDateComps = Calendar.current.dateComponents([.hour, .minute], from: endingHour)
        
        guard let startingHour = startingDateComps.hour,
              let startingMinute = startingDateComps.minute,
              let endingHour = endingDateComps.hour,
              let endingMinute = endingDateComps.minute else { return }
        
        //Saving working hours which later can be accessed and changed in the settings from right bar button item
        UserDefaults.standard.set(startingHour, forKey: "STARTING-HOUR")
        UserDefaults.standard.set(startingMinute, forKey: "STARTING-MINUTE")
        UserDefaults.standard.set(endingHour, forKey: "ENDING-HOUR")
        UserDefaults.standard.set(endingMinute, forKey: "ENDING-MINUTE")
    }
}


struct SecondStep_Previews: PreviewProvider {
    static var previews: some View {
        SecondStep()
    }
}
