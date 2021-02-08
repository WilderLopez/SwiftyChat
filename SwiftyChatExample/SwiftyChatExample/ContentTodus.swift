//
//  ContentTodus.swift
//  SwiftyChatExample
//
//  Created by Wilder Lopez on 2/8/21.
//

import SwiftUI
import SwiftyChat

struct ContentTodus: View {
    //List of messages
    @State var messages: [MockMessages.ChatMessageItem]
    
    //don't use it for now
    @State var onAppearMessage = MockMessages.ChatMessageItem(securityID: "nil", user: MockMessages.ChatUserItem(userName: "nil"), messageKind: .text("nil"))
    
    //future features
    @State var scrollToBottom : Bool = false
    @State var isBottomArea = false
    @State var refreshOldMessages = false
    @Binding var lastMessageInScrollPosition : UUID
    @Binding var isBlocked : Bool
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
    
    private var chatview: some View {
        ChatView<MockMessages.ChatMessageItem, MockMessages.ChatUserItem>(messages: $messages, onAppearMessage: $onAppearMessage
//                .didSet(execute: { (currentMessage) in
////            print("🌸currentMessage: isSender(\(currentMessage.isSender)) > isReceived(\(currentMessage.isReceived)) > isDisplayed(\(currentMessage.isDisplayed))")
//
//                        SendDDProcedure(currentMessage: currentMessage)
//
//
//                    if currentMessage.isSender && (!currentMessage.isReceived || !currentMessage.isDisplayed){
//                        print("🍁currentMessage: isSender(\(currentMessage.isSender)) > isReceived(\(currentMessage.isReceived)) > isDisplayed(\(currentMessage.isDisplayed))")
//                    }
//                })
                , scrollToBottom: $scrollToBottom, isBottom: $isBottomArea, refreshOldMessages: $refreshOldMessages, IDToScrollMove: $lastMessageInScrollPosition){
            
            // InputView here, continue reading..
            VStack(spacing: 0){
                if !isBottomArea {
                    HStack{
                        Spacer()
                    Button(action: {
                        scrollToBottom = true
                    }){
                        Image(systemName: "chevron.down")
                            .font(.system(size: 20))
                            .padding(8)
                            .background(Color.primaryTodusColor)
                            .foregroundColor(.white)
                            .clipShape(Circle())

                    }
                    }.padding([.trailing, .bottom], 5)
                }
                
                if isBlocked{
                    blockedView
                    .frame(height: 40, alignment: .center)
                    .background(Color.white)
                }else {
                    
                //MARK: - Todus InputView
                TodusInputView(sendAction: { (messageKind) in
                let id = UUID().uuidString.lowercased()
                let date = Date()
                let time = Int64 (date.millisecondsSince1970)
                let newMessage = MockMessages.ChatMessageItem(
                    securityID: id, user: MockMessages.ChatUserItem(userName: TodusDefaults.getUserAlias()!),
                    messageKind: messageKind,
                    isSender: true,
                    date: date)
                    
                    
                    //add action to move scroll
                    DispatchQueue.main.async {
                        
                        messages.append(newMessage)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(10), execute: {
                        scrollToBottom = true
                        
                    })
//                        withAnimation(Animation.easeOut){
                        
//                    }
                
                switch messageKind{
                case .text(let text):
                    chatManager.sendMessage(tmessage: TMessage(name: TodusDefaults.getUserAlias()!, from: "\(TodusDefaults.getUsername()!)@im.todus.cu", to: self.chatManager.streamManager!.genericRoom!.getId(), id: id, type: self.chatManager.streamManager!.genericRoom!.getType(), body: text, createAt: time, isReceived: false, isDisplayed: false, roomId: self.chatManager.streamManager!.genericRoom!.getId(), sourceType: SourceType.text))
                    break;
                case .image(ImageLoadingKind.local(let img)):
                    self.selectedIMG = img
                    //MARK: sending IQ to reserve in S3
                    self.chatManager.justImg2Up = Just(img)
                    let size = img.jpegData(compressionQuality: 1)?.count ?? 0
                    
                    self.chatManager.streamManager?.xmppController.presigned(filetype: ToDusConstants.TYPE_PICTURE , isPersistent: false, size: size, id: id)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                        self.scrollToBottom = true
                    }

                    break;
                default:
                    print("tipo de mensaje no soportado")
                }

            }
                , scrollToBottom: $scrollToBottom, isRecording: $startRecording)
                }
                
//                Color.red.frame(height: isKeyboardActive ? 0 : proxy.safeAreaInsets.bottom).animation(.easeOut(duration: 0.1))
                
            }
            //MARK: - IQ QPURL Receiver
//            .onReceive(chatManager.$IQ_QPRUL) { iq_qprul in
//                if iq_qprul != nil {
//                        //casting to QPURL
//                        let qpurl = iq_qprul!.query as! QPURL
//                        //verify status code
//                        if qpurl.status == 200 && self.chatManager.justImg2Up != nil {
//                            // Subir la imagen
//                            DispatchQueue.main.async {
//                                _ = self.chatManager.justImg2Up!.sink(receiveCompletion: { _chat in
//                                    self.selectedIMG = nil
//                                    self.chatManager.IQ_QPRUL = nil
//                                }) { (image) in
//                                    self.chatManager.streamManager!.sendImageMessage(image: image, putUrl: qpurl.put_url, getUrl: qpurl.get_url, id: iq_qprul!.id)
//                                }
//                            }
//                        }
//
//
//                }
//            }
            //MARK: - IQ DelBlockIQ
//            .onReceive(chatManager.$IQ_DELBLOCK, perform: { (iq) in
//                if iq != nil && delBlockId == iq!.id{
//                    TodusDefaults.delBlockUser(blockedUser: GenericRoom(room: (chatManager.streamManager?.currentRoom)!).getPhonenumber())
//                        loading = false
//                        isBlocked = false
//                }else {
//                    loading = false
//                }
//            })
            //MARK: - Fetching Old Messages
//            .onChange(of: refreshOldMessages, perform: { (value) in
//                if value && canRefresh{
//                    canRefresh = false
//
//                    print("Fetching old messages...")
//                    currentPagination += 1
//                    RefreshOldMessages(currentPagination: currentPagination)
//
//                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
//                        canRefresh = true
//                    }
//                }
//            })
//
            
            .edgesIgnoringSafeArea(.all)
            .embedInAnyView()
        }
        .environmentObject(ChatMessageCellStyle())
        
    }
    
    
    @State var showAlert = false
    private var blockedView: some View{
        HStack{
            Spacer()
            Button {
                print("desbloquear")
                showAlert = true
            } label: {
                Text("Desbloquear").bold().foregroundColor(.primaryTodusColor)
            }.alert(isPresented: $showAlert) { () -> Alert in
                Alert(title: Text("Desbloquear contacto"), primaryButton: .default(Text("Desbloquear"), action: {
//                        TodusDefaults.delBlockUser(blockedUser: selectedContact.coredataInfo!.username)
                    delBlockId = UUID().uuidString.lowercased()
                    chatManager.streamManager?.xmppController.delBlock(id: delBlockId, to: GenericRoom(room: (chatManager.streamManager?.currentRoom)!).getJID())
                    
                }), secondaryButton: .cancel(Text("Cancelar")))
            }
            
            
//            if loading {
//                LoadingUIKit()
//            }
            Spacer()
        }
    }
}

struct ContentTodus_Previews: PreviewProvider {
    static var previews: some View {
        ContentTodus()
    }
}
