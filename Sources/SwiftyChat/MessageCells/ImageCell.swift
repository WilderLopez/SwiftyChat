//
//  DefaultImageCell.swift
//  SwiftyChatbot
//
//  Created by Enes Karaosman on 23.05.2020.
//  Copyright © 2020 All rights reserved.
//

import SwiftUI
import KingfisherSwiftUI
import class Kingfisher.KingfisherManager

public struct ImageCell<Message: ChatMessage>: View {
    
    public let message: Message
    public let imageLoadingType: ImageLoadingKind
    public let size: CGSize
    @EnvironmentObject var style: ChatMessageCellStyle
    
    private var imageWidth: CGFloat {
        cellStyle.cellWidth(size)
    }
    
    private var cellStyle: ImageCellStyle {
        style.imageCellStyle
    }
    
    @ViewBuilder private var imageView: some View {
        switch imageLoadingType {
        case .local(let image): localImage(uiImage: image)
        case .remote(let remoteUrl): remoteImage(url: remoteUrl)
        case .remoteTodus(let remoteUrl, let imageSize): remoteImageFromTodus(url: remoteUrl, imageSize: imageSize)
        case .tnail(let imageTnail, _, _): localImageTnail(uiImage: imageTnail)
        }
    }
    
    public var body: some View {
        ZStack(alignment: .bottomTrailing){
            imageView
            
            DateCheckMarkView(isNotText: true, isCurrentUser: message.isSender, dateDescription: DateHelper.getDateWith(date: message.date), messageTag: message.isDisplayed ? .dd : message.isReceived ? .rd : .none)
//                .animation(.linear(duration: 0.2))
                .padding(3)
                .padding(.horizontal, 6)
                .background(Color.black.opacity(0.3))
                .cornerRadius(10)
                .padding(10)
                .foregroundColor(Color.white)
        }
        .background(message.isSender ? Color.primaryBubble : Color.secondaryBubble)
//        .clipped()
        .clipShape(CustomChatCorner(isCurrentUser: message.isSender))
        .contentShape(CustomChatCorner(isCurrentUser: message.isSender))
        .shadow(radius: 1)
        .foregroundColor(.white)
//        .frame(alignment: .center)
    }
    
    // MARK: - case Local Image
    @ViewBuilder private func localImage(uiImage: UIImage) -> some View {
        let width = uiImage.size.width
        let height = uiImage.size.height
        let isLandscape = width > height
        
        Image(uiImage: uiImage)
            .resizable()
            .aspectRatio(width / height, contentMode: isLandscape ? .fit : .fill)
            .frame(width: isLandscape ? 300 : 250, height: isLandscape ? nil : 350)
//            .frame(width: imageWidth, height: isLandscape ? nil : imageWidth)
//            .background(cellStyle.cellBackgroundColor)
//            .cornerRadius(cellStyle.cellCornerRadius)
//            .overlay(
//                RoundedRectangle(cornerRadius: cellStyle.cellCornerRadius)
//                    .stroke(
//                        cellStyle.cellBorderColor,
//                        lineWidth: cellStyle.cellBorderWidth
//                    )
//            )
//            .shadow(
//                color: cellStyle.cellShadowColor,
//                radius: cellStyle.cellShadowRadius
//            )
    }
//    @State var downloadIndicator = true
    @ViewBuilder private func localImageTnail(uiImage: UIImage) -> some View{
        let width = uiImage.size.width
        let height = uiImage.size.height
        let isLandscape = width > height
        
        ZStack{
        Image(uiImage: uiImage)
            .resizable()
            .aspectRatio(width / height, contentMode: isLandscape ? .fit : .fill)
            .frame(width: isLandscape ? 300 : 250, height: isLandscape ? nil : 350)
            
//            if downloadIndicator{
                Image(systemName: "arrow.down.circle")
                    .resizable()
                    .frame(width: 80, height: 80, alignment: .center)
                    .foregroundColor(.gray)
//            }
        }
    }
    
    @State var remoteIMGWidth: CGFloat = 1
    @State var remoteIMGHeight: CGFloat = 1
    @State var remoteIMG : UIImage? = nil
    var isLandscape : Bool {remoteIMGWidth > remoteIMGHeight}
    // MARK: - case Remote Image
    @ViewBuilder private func remoteImage(url: URL) -> some View {
        /**
         KFImage(url)
         .onSuccess(perform: { (result) in
             result.image.size
         })
         We can grab size & manage aspect ratio via a @State property
         but the list scroll behaviour becomes messy.
         
         So for now we use fixed width & scale height properly.
         */
        KFImage(url)
            .onSuccess(perform: { (result) in
                remoteIMGWidth = result.image.size.width
                remoteIMGHeight = result.image.size.height
            })
            .resizable()
            .aspectRatio(remoteIMGWidth / remoteIMGHeight, contentMode: isLandscape ? .fit : .fill)
            .frame(width: isLandscape ? 300 : 250, height: isLandscape ? nil : 350)
        
        
        
//            .background(cellStyle.cellBackgroundColor)
//            .cornerRadius(cellStyle.cellCornerRadius)
//            .overlay(
//                RoundedRectangle(cornerRadius: cellStyle.cellCornerRadius)
//                    .stroke(
//                        cellStyle.cellBorderColor,
//                        lineWidth: cellStyle.cellBorderWidth
//                    )
//            )
//            .shadow(
//                color: cellStyle.cellShadowColor,
//                radius: cellStyle.cellShadowRadius
//            )
        
    }
    
    
    //MARK: - case Remote Image from ToDus
    @ViewBuilder private func remoteImageFromTodus(url: URL, imageSize: CGSize) -> some View {
        let isLandScape = imageSize.width > imageSize.height
        KFImage(url)
            .resizable()
            .aspectRatio(imageSize.width / imageSize.height, contentMode: isLandScape ? .fit : .fill)
            .frame(width: isLandScape ? 300 : 250, height: isLandScape ? nil : 350)
    }
    
    
//    func fetch(url: URL){
//        KingfisherManager.shared.retrieveImage(with: url) { (resutl) in
//            switch resutl{
//            case .success(let task):
//                self.remoteIMG = task.image
//            case .failure(_):
//                print("error")
//            }
//        }
//    }
    

}

