//
//  DateCheckMarkView.swift
//  toDus-SwiftUI
//
//  Created by Wilder Lopez on 9/3/20.
//  Copyright © 2020 iGhost. All rights reserved.
//

import SwiftUI

enum MessageTag{
    case none, r, dd, rd
}

struct DateCheckMarkView: View {
    var isNotText = false
    @State var isCurrentUser : Bool
    @State var date : Date
    @State var messageTag : MessageTag
    var body: some View {
        HStack{
            Text(DateHelper.getDateWith(timeInterval: Int64(date.timeIntervalSince1970)))
                .italic()
            if isCurrentUser {
                HStack(spacing: 0){
                    if messageTag != .none{
                        Image(systemName: "checkmark")
                        
                        if messageTag != .r {
                            Rectangle()
                                .frame(width: 1.5, height: 11, alignment: .center)
                                .cornerRadius(10)
                                .rotationEffect(Angle(degrees: 32))
                        }
                    }else {
                        Image(systemName: "clock")
                    }
                }.foregroundColor(messageTag == .dd ? isNotText ? .white : .ddmarkColor : .rdmarkColor)
            }
        }.font(.system(size: 11))
        .frame(width: isCurrentUser ? 80 : 50, alignment: .bottomTrailing)
            .animation(.linear)
    }
}
