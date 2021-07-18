//
//  DefaultImageCell.swift
//  SwiftyChatbot
//
//  Created by Enes Karaosman on 23.05.2020.
//  Copyright © 2020 All rights reserved.
//

import SwiftUI
import Kingfisher

public struct ImageCell<Message: ChatMessage>: View {

    public let message: Message
    public let imageLoadingType: ImageLoadingKind
    public let size: CGSize
    public var onRemoteResponse: (MockMessages.RemoteResponseRow) -> Void
    @State var isDownload = false
    @EnvironmentObject var style: ChatMessageCellStyle

    private var imageWidth: CGFloat {
        cellStyle.cellWidth(size)
    }

    private var cellStyle: ImageCellStyle {
        style.imageCellStyle
    }

    @ViewBuilder private var imageView: some View {
        if #available(iOS 14.0, *) {
            switch imageLoadingType {
            case .local(let image): localImage(uiImage: image)
            case .remote(let remoteUrl): remoteImageDefault(url: remoteUrl)
            case .remoteImage(let imageTnail, let remoteUrl, let imageSize, let tnailBytes, let isRemote): remoteImageFromTodus(uiImage: imageTnail, url: remoteUrl, imageSize: imageSize, tnailBytes: tnailBytes, isRemote: isRemote)
            }
        } else {
            // deprecate all of this
            switch imageLoadingType {
            case .local(let image): localImage(uiImage: image)
            case .remote(let remoteUrl): remoteImageDefault(url: remoteUrl)
            default:
                EmptyView()
            }
        }
    }

    public var body: some View {
        ZStack(alignment: .bottomTrailing){
            imageView

            DateCheckMarkView(isNotText: true, isCurrentUser: message.isSender, dateDescription: DateHelper.getDateWith(date: message.date), messageTag: message.isDisplayed ? .dd : message.isReceived ? .rd : message.isSent ? .r : .none)
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
    @ViewBuilder private func localImageTnail(uiImage: UIImage, bytes: Double) -> some View{
        let width = uiImage.size.width
        let height = uiImage.size.height
        let isLandscape = width > height

        ZStack{
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(width / height, contentMode: isLandscape ? .fit : .fill)
                .frame(width: isLandscape ? 300 : 250, height: isLandscape ? nil : 350)

            //            if downloadIndicator{
            Image(systemName: "arrow.down")
                .font(.system(size: 20))
                .foregroundColor(.white)
                .padding()
                .background(
                    Color.gray
                )
                .clipShape(Circle())


            //            }
        }.overlay(
            Text("\(bytes/1024/1024, specifier: "%.2f")MB")
                .font(.system(size: 13, weight: .bold, design: .default))
                .foregroundColor(.white)
                .padding(.horizontal, 5)
                .background(Color.black.opacity(0.6))
                .cornerRadius(10)
                .offset(y: 40)
        )
    }

    @State var remoteIMGWidth: CGFloat = 1
    @State var remoteIMGHeight: CGFloat = 1
    @State var remoteIMG : UIImage? = nil
    var isLandscape : Bool {remoteIMGWidth > remoteIMGHeight}
    // MARK: - case Remote Image
    @ViewBuilder private func remoteImageDefault(url: URL) -> some View {
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
            .onSuccess({ (result) in
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


    @State private var downloadAmount = 0.0
    @State private var startDownload = false
    @State private var isfinished = false
    @State private var finishFailure = false
    @State private var finishSuccess = false
    //MARK: - case Remote Image from ToDus
    @available(iOS 14.0, *)
    @ViewBuilder private func remoteImageFromTodus(uiImage: UIImage, url: URL, imageSize: CGSize, tnailBytes: Double, isRemote: Bool = false) -> some View {
        let isLandScape = imageSize.width > imageSize.height

        ZStack{

            if ( isRemote && !finishFailure ) && ( isRemote && !isfinished ){
            KFImage(url)
            //              .placeholder({
            //                                Image(uiImage: uiImage)
            //                                    .resizable()
            //                                    .aspectRatio(imageSize.width / imageSize.height, contentMode: isLandScape ? .fit : .fill)
            //                                    .frame(width: isLandScape ? 300 : 250, height: isLandScape ? nil : 350)
            //                            })
                    .onProgress({ v1, v2 in
                    let frac : Double = Double(v1) / Double(v2)
                    let amount = frac * 100
                    if downloadAmount <= amount {
                        if !startDownload {
                            startDownload = true
                        }
                        downloadAmount = amount
                        print("v1: \(v1)")
                        print("v2: \(v2)")
                        print("downloadAmount: \(downloadAmount)")
                    }
                })
                    .onSuccess({ imgResult in
                    if !isfinished{
                    print("Success ✅")
                    let remoteResponse : MockMessages.RemoteResponseRow =
                        .init(url: url, payload: imgResult.image.pngData(), tnailBytes: tnailBytes, isdownloaded: true, message: message as? MockMessages.RemoteResponseRow.Message)
                    startDownload = false
                    isfinished = true
                    onRemoteResponse(remoteResponse)
                    }
                })
                    .onFailure({ KError in
                    if !finishFailure{
                    print("failure Kingfisher: \(KError)")
                    let remoteResponse : MockMessages.RemoteResponseRow =
                        .init(url: url, payload: uiImage.pngData(), tnailBytes: tnailBytes, isdownloaded: false, message: message as? MockMessages.RemoteResponseRow.Message)

                    onRemoteResponse(remoteResponse)
                    startDownload = false
                    isfinished = false
                    finishFailure = true
                    }
                })
                .cancelOnDisappear(isfinished || finishFailure)
                .resizable()
                .aspectRatio(imageSize.width / imageSize.height, contentMode: isLandScape ? .fit : .fill)
                .frame(width: isLandScape ? 300 : 250, height: isLandScape ? nil : 350)
                .onAppear {
                    print("Image is Here 🔱")
                }
            }
            //hide when download is done
            if !isfinished {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(imageSize.width / imageSize.height, contentMode: isLandScape ? .fit : .fill)
                    .frame(width: isLandScape ? 300 : 250, height: isLandScape ? nil : 350)
            }

            if startDownload && downloadAmount < 100 {
                ProgressView("Descargando…", value: downloadAmount, total: 100)
                    .progressViewStyle(CirclerPercentageProgressViewStyle())
                    .frame(width: 120, height: 120, alignment: .center)
            }else {
                //only before start
                Button {
                    print("start presigned download")
                    let presignedRequest = MockMessages.RemoteResponseRow(triggerDownload: true, url: url, message: message as? MockMessages.RemoteResponseRow.Message)
                    onRemoteResponse(presignedRequest)
                } label: {
                    Image(systemName: "arrow.down")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            Color.gray
                        )
                        .clipShape(Circle())
                }

                Text("\(tnailBytes/1024/1024, specifier: "%.2f")MB")
                    .font(.system(size: 13, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .padding(.horizontal, 5)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(10)
                    .offset(y: 40)
            }
        }

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

@available(iOS 14.0, *)
public struct CirclerPercentageProgressViewStyle : ProgressViewStyle {
    public func makeBody(configuration: LinearProgressViewStyle.Configuration) -> some View {
        VStack(spacing: 10) {
            configuration.label
                .foregroundColor(Color.secondary)
            ZStack {
                Circle()
                    .stroke(lineWidth: 5.0)
                    .opacity(0.3)
                    .foregroundColor(Color.accentColor.opacity(0.8))
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(configuration.fractionCompleted ?? 0))
                    .stroke(style: StrokeStyle(lineWidth: 5.0, lineCap: .round, lineJoin: .round))
                    .foregroundColor(Color.accentColor)
                
                Text("\(Int((configuration.fractionCompleted ?? 0) * 100))%")
                    .font(.headline)
                    .foregroundColor(Color.secondary)
            }
        }
    }
}
