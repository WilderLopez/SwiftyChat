//
//  ColorAppExtensions.swift
//  toDus-SwiftUI
//
//  Created by Wilder Lopez on 8/12/20.
//  Copyright © 2020 iGhost. All rights reserved.
//

import Foundation
import SwiftUI

extension Color {
    static var primaryTodusColor = Color("TodusColor")
    static var secondaryBubble = Color("SecondaryBubble")
    static var primaryBubble = Color("PrimaryBubble")
    static var textMessageColor = Color("TextMessage")
    static var chatBackgroundColor = Color("ChatBackground")
    static var ForengroundBackColor = Color("ForengroundBack")
    static var ddmarkColor = Color("ddmarkColor")
    static var rdmarkColor = Color("rdmarkColor")
    static var InputMessageBackgroundColor = Color("InputMessageBackground")
    static var InputMessageTinColor = Color("tinInputBarColor")
    #if os(macOS)
    static var fullTodusColor = Color("FullTodusColor")
    #endif
}

extension Color{
    public static func colorHash(name: String?) -> (color: Color,isDarK: Bool) {
        guard let name = name else {
            return (Color.red, false)
        }

        var nameValue = 0
        for character in name {
            let characterString = String(character)
            let scalars = characterString.unicodeScalars
            nameValue += Int(scalars[scalars.startIndex].value)
        }

        var r = Float((nameValue * 123) % 51) / 51
        var g = Float((nameValue * 321) % 73) / 73
        var b = Float((nameValue * 213) % 91) / 91
        
        let defaultValue: Float = 0.84
        r = min(max(r, 0.1), defaultValue)
        g = min(max(g, 0.1), defaultValue)
        b = min(max(b, 0.1), defaultValue)
        
        let lum = 0.2126 * r + 0.7152 * g + 0.0722 * b

        return (Color(red: Double(r), green: Double(g), blue: Double(b)), lum < 0.5)
    }
}
