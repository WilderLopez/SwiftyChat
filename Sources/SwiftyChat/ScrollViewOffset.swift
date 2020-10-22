//
//  ScrollViewOffset.swift
//  
//
//  Created by Wilder Lopez on 10/22/20.
//

import SwiftUI

struct ScrollViewOffset<Content: View>: View {
    let onOffsetChange: (CGFloat) -> Void
    let content: () -> Content
    @Binding var isBottomChange: Bool
    
    init(
        onOffsetChange: @escaping (CGFloat) -> Void,
        @ViewBuilder content: @escaping () -> Content,
        isBottomChange: Binding<Bool>
    ) {
        self.onOffsetChange = onOffsetChange
        self.content = content
        self._isBottomChange = isBottomChange
    }
    
    var body: some View {
        ScrollView {
            offsetReader
            content()
                .padding(.top, -8)
            bottomReader
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
    var bottomReader: some View{
        Color.clear
            .onAppear{
                self.isBottomChange = true
            }
            .onDisappear {
                self.isBottomChange = false
            }
        
    }
    
}

private struct OffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
}

//private struct isBottomPreferenceKey: PreferenceKey{
//    static var defaultValue: Bool = false
//    static func reduce(value: inout Bool, nextValue: () -> Bool) {}
//}
