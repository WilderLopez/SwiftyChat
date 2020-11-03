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
                HStack(alignment: .bottom, spacing: 0){
                    if messageTag != .none{
//                        Image(systemName: "checkmark")
                        checkR()
                            .padding(.trailing, 2)
                        
                        if messageTag != .r {
                            Rectangle()
                                .frame(width: 1.5, height: 11, alignment: .center)
                                .cornerRadius(10)
                                .rotationEffect(Angle(degrees: 38))
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

struct DateCheckMarkView_Previews: PreviewProvider {
    static var previews: some View {
        DateCheckMarkView(isCurrentUser: true, date: Date(), messageTag: .rd)
            .previewLayout(PreviewLayout.fixed(width: 150, height: 90))
    }
}

struct checkR : View {
    var body: some View{
        HStack(alignment: .bottom,spacing: 3.5){
        Rectangle()
            .frame(width: 1.5, height: 6, alignment: .center)
            .cornerRadius(10)
            .rotationEffect(Angle(degrees: -38))
            
        Rectangle()
            .frame(width: 1.5, height: 11, alignment: .center)
            .cornerRadius(10)
            .rotationEffect(Angle(degrees: 38))
        }
    }
}
