//
//  DismissKeyboardModifier.swift
//  
//
//  Created by Enes Karaosman on 28.08.2020.
//

import SwiftUI

extension View {
    dynamic func dismissKeyboardOnTappingOutside(force: Bool = true) -> some View {
        return ModifiedContent(content: self, modifier: DismissKeyboardOnTappingOutside(endEditing: force))
    }
}

public struct DismissKeyboardOnTappingOutside: ViewModifier {
    var endEditing : Bool
    public func body(content: Content) -> some View {
        content
            .onTapGesture {
                let keyWindow = UIApplication.shared.connectedScenes
                        .filter({$0.activationState == .foregroundActive})
                        .map({$0 as? UIWindowScene})
                        .compactMap({$0})
                        .first?.windows
                        .filter({$0.isKeyWindow}).first
                keyWindow?.endEditing(endEditing)
        }
    }
}
