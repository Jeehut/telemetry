//
//  CardView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 02.09.20.
//

import SwiftUI

struct CardView<Content>: View where Content: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body : some View {
        ZStack {
            #if os(macOS)
            let fillColor: Color = Color.init(NSColor.systemGray)
            #else
            let fillColor: Color = Color.init(UIColor.systemGray6)
            #endif
            
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(fillColor)
                .shadow(color: Color(hue: 0, saturation: 0, brightness: 0, opacity: 0.2), radius: 7, x: 0, y: 6)
            
            content
            .padding()
        }
        .padding()
    }
}
