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
        configuration: [:])
    
    @State private var selectedTypeIndex = 0

    @State private var breakdownPayloadKeyword: String = "systemVersion" {
        didSet {
            insightCreateRequestBody.configuration["breakdown.payloadKeyword"] = breakdownPayloadKeyword
        }
    }
    
    let insightTypes = ["Breakdown", "Mean"]
    let insightTypesValues: [InsightType] = [.breakdown, .mean]
    
    var body: some View {
        
        let saveButton = Button("Save") {
            api.create(insightWith: insightCreateRequestBody, in: insightGroup, for: app)
            //            api.create(derivedStatistic: derivedStatisticCreateRequestBody, for: derivedStatisticGroup, in: app)
            isPresented = false
        }
        .keyboardShortcut(.defaultAction)
        
        let cancelButton = Button("Cancel") { isPresented = false }.keyboardShortcut(.cancelAction)
        let title = "New Insight"
        
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
                Picker(selection: $selectedTypeIndex, label: Text("Please choose a type")) {
                    ForEach(0 ..< insightTypes.count) {
                        Text(self.insightTypes[$0])
                    }
                }
            }
            
            if insightTypesValues[selectedTypeIndex] == .breakdown {
                Section(header: Text("Payload Keyword"), footer: Text("What's the payload keyword you want a breakdown for? E.g. 'systemVersion' for a breakdown of system versions")) {
                    TextField("Payload Keyword", text: $breakdownPayloadKeyword)
                        
                }
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
            .previewLayout(.fixed(width: 600, height: 800))
    }
}
