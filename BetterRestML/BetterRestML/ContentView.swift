//
//  ContentView.swift
//  BetterRestML
//
//  Created by Fábio Carlos de Souza on 09/01/23.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var sleepAmount = 8.0
    @State private var wakeUp = defaultWakeTime
    @State private var coffeeAmout = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    var body: some View {
        NavigationView {
            Form {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Que horas você acorda?")
                        .font(.headline)
                    
                    
                    DatePicker("Selecione uma data", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
            
                VStack(alignment: .leading, spacing: 0) {
                    Text("Quantas horas deseja dormir?")
                        .font(.headline)
                    
                    Stepper("\(sleepAmount.formatted()) horas", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                VStack(alignment: .leading, spacing: 0) {
                    Text("Quantas cafezinhos você bebe?")
                        .font(.headline)
                    
                    Stepper(coffeeAmout == 1 ? "1 cup" : "\(coffeeAmout) cups", value: $coffeeAmout, in: 1...20)
                }
            }
            .navigationTitle("BetterRest")
            .toolbar {
                Button("Calcular", action: calcularHorarioDeDormir)
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    func calcularHorarioDeDormir() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmout))
            
            let sleepTime = wakeUp - prediction.actualSleep
            alertTitle = "Seu horario de dormir é..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
            
            
        } catch {
            alertTitle = "Erro"
            alertMessage = "Desculpa, ocorreu um problema ao calcular"
        }
        showingAlert = true
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
