//
//  NewInsightForm.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 28.09.20.
//

import SwiftUI

struct NewInsightForm: View {
    // Environment
    @EnvironmentObject var api: APIRepresentative
    
    // Initialization Constants
    let app: TelemetryApp
    let insightGroup: InsightGroup
    
    // Bindings
    @Binding var isPresented: Bool
    
    // State
    @State var insightCreateRequestBody: InsightCreateRequestBody = InsightCreateRequestBody(
        title: "New Insight",
        insightType: .breakdown,
        timeInterval: -3600*24,
        configuration: [:])
    
    let insightTypes: [InsightType] = [.breakdown, .count, .mean]
    @State private var selectedInsightTypeIndex = 0
    @State private var breakdownpayloadKey: String = "systemVersion"
    @State private var timeInterval: TimeInterval = 3600*24
    @State private var conditions: String = "unique-user; platform==iOS"
    
    
    // Formatters
    let dateComponentsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        return formatter
    }()
    
    var body: some View {
        
        let saveButton = Button("Save") {
            insightCreateRequestBody.configuration["breakdown.payloadKey"] = breakdownpayloadKey
            insightCreateRequestBody.configuration["conditions"] = conditions
            insightCreateRequestBody.insightType = insightTypes[selectedInsightTypeIndex]
            insightCreateRequestBody.timeInterval = -timeInterval
            
            api.create(insightWith: insightCreateRequestBody, in: insightGroup, for: app)
            isPresented = false
        }
        .keyboardShortcut(.defaultAction)
        
        let cancelButton = Button("Cancel") { isPresented = false }.keyboardShortcut(.cancelAction)
        let title = "System Version"
        
        let form = Form {
            #if os(macOS)
            Text(title)
                .font(.title2)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
            #endif
            
            Section(header: Text("Name"), footer: Text("Give your insight a human readable name, e.g. 'System Version'")) {
                TextField("Title", text: $insightCreateRequestBody.title)
            }
            
            Section(header: Text("Type"), footer: Text("What kind of insight is your insight?")) {
                Picker(selection: $selectedInsightTypeIndex, label: Text("Please choose a type")) {
                    ForEach(0 ..< insightTypes.count) {
                        Text(self.insightTypes[$0].humanReadableName)
                    }
                }
            }
            
            Section(header: Text("Time Frame"), footer: Text("How far should we go backwards in time to look for signals to include in this insight?")) {
                VStack {
                    Slider(value: $timeInterval, in: 3600...3600*24*30, step: 3600)
                    
                    let calculatedAt = Date()
                    let calculationBeginDate = Date(timeInterval: -timeInterval, since: calculatedAt)
                    let dateComponents = Calendar.autoupdatingCurrent.dateComponents([.day, .hour, .minute], from: calculationBeginDate, to: calculatedAt)
                 
                    HStack {
                        Text("\(dateComponentsFormatter.string(from: dateComponents) ?? "—")")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Section(header: Text("Conditions"), footer: Text("State Conditions that must apply for the signal to be counted")) {
                TextField("Conditions", text: $conditions)
            }
            
            if insightTypes[selectedInsightTypeIndex] == .breakdown {
                Section(header: Text("Payload Key"), footer: Text("What's the payload key you want a breakdown for? E.g. 'systemVersion' for a breakdown of system versions")) {
                    TextField("Payload Keyword", text: $breakdownpayloadKey)
                        
                }
            } else if insightTypes[selectedInsightTypeIndex] == .count {
                
            
            } else {
                Text("Sorry that Insight Type is not implemented yet :( ")
            }
            
            Section(header: Text("Debug"), footer: Text("Debug Info")) {
                Text("App: \(app.name)")
                Text("Insight Group: \(insightGroup.title)")
            }
            
            #if os(macOS)
            HStack {
                Spacer()
                cancelButton
                saveButton
            }
            #endif
            
        }
        
        #if os(macOS)
        form.padding()
        #else
        NavigationView {
            form
                .navigationTitle(title)
                .navigationBarItems(leading: cancelButton, trailing: saveButton)
        }
        #endif
    }
}

struct NewInsightForm_Previews: PreviewProvider {
    static var platform: PreviewPlatform? = nil
    
    static var previews: some View {
        NewInsightForm(app: MockData.app1, insightGroup: InsightGroup.init(id: UUID(), title: "Test Insight Group"), isPresented: .constant(true))
            .environmentObject(APIRepresentative())
            .previewLayout(.fixed(width: 600, height: 1000))
    }
}
