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
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(Color.white)
                .shadow(radius: 7, x: 0, y: 5)
            
            content
            .padding()
        }
        .padding()
    }
}
