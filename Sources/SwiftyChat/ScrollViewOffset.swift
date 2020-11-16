//
//  ScrollViewOffset.swift
//  
//
//  Created by Wilder Lopez on 10/22/20.
//

import SwiftUI

struct ScrollViewOffset<Content: View>: View {
    @State var scrollStateY : CGFloat
    
    let onOffsetChange: (CGFloat) -> Void
    let content: () -> Content
    init(scrollStateY: CGFloat, onOffsetChange: @escaping (CGFloat) -> Void, @ViewBuilder content: @escaping () -> Content) {
        self.onOffsetChange = onOffsetChange
        self.content = content
        _scrollStateY = State(initialValue: scrollStateY)
    }
    var body: some View {
        ScrollView {
            offsetReader
            content()
                .padding(.top, -8)
                .offset(y: scrollStateY)
        }
        .coordinateSpace(name: "frameLayer")
        .onPreferenceChange(OffsetPreferenceKey.self, perform: onOffsetChange)
    }
    var offsetReader: some View {
        GeometryReader { proxy in
            Color.clear
                .preference(
                    key: OffsetPreferenceKey.self,
                    value: proxy.frame(in: .named("frameLayer")).minY
                )
        }
        .frame(height: 0)
    }
}

private struct OffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
}
