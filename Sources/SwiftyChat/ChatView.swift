//
//  ChatView.swift
//  SwiftyChatbot
//
//  Created by Enes Karaosman on 19.05.2020.
//  Copyright © 2020 All rights reserved.
//

import SwiftUI

public struct ChatView<Message: ChatMessage, User: ChatUser>: View {
    
    @Binding private var messages: [Message]
    @Binding private var onAppearMessage: Message
    private var inputView: () -> AnyView

    private var onMessageCellTapped: (Message) -> Void = { msg in print(msg.messageKind) }
    private var messageCellContextMenu: (Message) -> AnyView = { _ in EmptyView().embedInAnyView() }
    private var onQuickReplyItemSelected: (QuickReplyItem) -> Void = { _ in }
    private var contactCellFooterSection: (ContactItem, Message) -> [ContactCellButton] = { _, _ in [] }
    private var onAttributedTextTappedCallback: () -> AttributedTextTappedCallback = { return AttributedTextTappedCallback() }
    private var onCarouselItemAction: (CarouselItemButton, Message) -> Void = { (_, _) in }
    
    @available(iOS 14.0, *)
    @Binding private var scrollToBottom: Bool
    @Binding private var refreshOldMessages : Bool
//    @State private var scrollOffset: CGFloat = .zero
    @Binding var IDToScrollMove : UUID
    @State private var topOffset: CGFloat = .zero
    var scrollToid = 99
    @available(iOS 14.0, *)
    @Binding private var isBottom : Bool
    @State private var firstMove = false
//    private var bottomID = UUID().uuidString
    
    public var body: some View {
        DeviceOrientationBasedView(
            portrait: { GeometryReader { body(in: $0) } },
            landscape: { GeometryReader { body(in: $0) } }
        )
        .environmentObject(OrientationInfo())
        .edgesIgnoringSafeArea([.top, .horizontal])
    }
    
    // MARK: - Body in geometry
    private func body(in geometry: GeometryProxy) -> some View {
        ZStack(alignment: .bottom) {
                    
            if #available(iOS 14.0, *) {
                iOS14Body(in: geometry)
                    .padding(.bottom, geometry.safeAreaInsets.bottom + 40)
            } else {
                iOS14Fallback(in: geometry)
                    .padding(.bottom, geometry.safeAreaInsets.bottom + 56)
            }

            inputView()

        }
        .keyboardAwarePadding()
//        .dismissKeyboardOnTappingOutside()
    }
    
    @available(iOS 14.0, *)
    private func iOS14Body(in geometry: GeometryProxy) -> some View {
        ScrollView{
                ScrollViewReader { proxy in
                    LazyVStack {
                        ForEach(messages.sorted(by: { (m1, m2) -> Bool in
                            return m1.date.compare(m2.date) == .orderedAscending
                        })) { message in
                            chatMessageCellContainer(in: geometry.size, with: message)
                                .onAppear {
    //                                print("id: \(message.id) == last id: \(messages.last?.id)")
                                    
//                                    if message.id == messages.last?.id{
////                                        print("shold down ⬇️")
//                                        withAnimation {
//                                            self.isBottom = true
//                                            topOffset = scrollOffset
//                                        }
//                                    }else {
//                                            if scrollOffset > topOffset + geometry.size.height - 100{
//                                                withAnimation {
//                                                self.isBottom = false
//                                                }
////                                                print("⬆️")
//                                            }
//                                    }
                                    if !message.isSender{
                                        onAppearMessage = message
                                    }
                                    
                                    //catch first message on appear
                                    
//                                    if !firstMove{
//                                        DispatchQueue.main.async {
//                                            if let index = messages.firstIndex(where: { (mess) -> Bool in
//                                               print("Comparing : \(mess.securityID) == \(IDToScrollMove.uuidString)")
//                                                return mess.securityID.uppercased() == IDToScrollMove.uuidString.uppercased()
//                                            }){
//                                                print("move to item(\(index)) \(IDToScrollMove) 🥑🥮")
//
//                                                proxy.scrollTo(messages[index].id, anchor: .top)
//                                            }
//                                        }
//
//
//                                        firstMove = true
//                                    }else {
//
//                                        IDToScrollMove = UUID(uuidString: message.securityID)!
//
//                                    }
                                    
                                    //MARK: - Refresh Old Messages
//                                    if scrollOffset > -7 && !refreshOldMessages{
//                                        let firstMessage = messages.first
//                                        refreshOldMessages = true
//
//                                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(10), execute: {
//                                            withAnimation(Animation.linear(duration: 0)) {
//                                                proxy.scrollTo(firstMessage?.id, anchor: .top)
//                                            }
//                                        })
//                                    }
//                                    else if scrollOffset < -7 && refreshOldMessages{
//                                        refreshOldMessages = false
//                                    }

                                }
                        }
                        Rectangle()
                            .frame(height: 20, alignment: .center)
                            .foregroundColor(Color.clear)
                            .id(scrollToid)
                    }
                    .onChange(of: scrollToBottom) { value in
                        if value {
                            withAnimation(Animation.default) {
//                                proxy.scrollTo(messages.last?.id)
                                proxy.scrollTo(scrollToid)
//                                    topOffset = scrollOffset
                                self.isBottom = true
                            }
                            scrollToBottom = false
                        }
                    }
                    
                }
        }
        .background(Color.clear)
    }
    
//    private var bottomArea: some View{
//        Rectangle().frame(height: 10).foregroundColor(Color.clear)
//            .onAppear {
//            print("Bottom⬇️")
//            }
//            .onDisappear {
//                print("⬆️")
//            }
//    }
    
    private func iOS14Fallback(in geometry: GeometryProxy) -> some View {
        List(messages) { message in
            chatMessageCellContainer(in: geometry.size, with: message)
        }
        .onAppear {
            // To remove only extra separators below the list:
            UITableView.appearance().tableFooterView = UIView()
            // To remove all separators including the actual ones:
            UITableView.appearance().separatorStyle = .none
            
            // To clear background colors to allow library user set himself
            UITableView.appearance().backgroundColor = .clear
            UITableViewCell.appearance().backgroundColor = .clear
        }
    }
    
    // MARK: - List Item
    private func chatMessageCellContainer(in size: CGSize, with message: Message) -> some View {
        ChatMessageCellContainer(
            message: message,
            size: size,
            onQuickReplyItemSelected: onQuickReplyItemSelected,
            contactFooterSection: contactCellFooterSection,
            onTextTappedCallback: onAttributedTextTappedCallback,
            onCarouselItemAction: onCarouselItemAction
        )
        .onTapGesture { onMessageCellTapped(message) }
        .contextMenu(menuItems: { messageCellContextMenu(message) })
//        .modifier(AvatarModifier<Message, User>(message: message))
        .modifier(MessageHorizontalSpaceModifier(messageKind: message.messageKind, isSender: message.isSender))
        .modifier(CellEdgeInsetsModifier(isSender: message.isSender))
        .id(message.id)
    }
    
}

// MARK: - Initializers
public extension ChatView {
    
    /// Initialize
    /// - Parameters:
    ///   - messages: Messages to display
    ///   - onAppearMessage: Current message by the list
    ///   - scrollToSet: current scroll position
    ///   - inputView: inputView view to provide message
    init(
        messages: Binding<[Message]>,
        onAppearMessage: Binding<Message>,
        IDToScrollMove: Binding<UUID>,
        inputView: @escaping () -> AnyView
    ) {
        self._messages = messages
        self._onAppearMessage = onAppearMessage
        self._IDToScrollMove = IDToScrollMove
        self.inputView = inputView
        self._scrollToBottom = .constant(false)
        self._isBottom = .constant(false)
        self._refreshOldMessages = .constant(false)
    }
    
    /// iOS 14 initializer, for supporting scrollToBottom
    /// - Parameters:
    ///   - messages: Messages to display
    ///   - onAppearMessage: Current message by the list
    ///   - scrollToBottom: set to `true` to scrollToBottom
    ///   - isBottom: `true` when scroll is bottom
    ///   - refreshOldMessages: `true` when scroll is top
    ///   - scrollOffset: current scroll position
    ///   - inputView: inputView view to provide message
    @available(iOS 14.0, *)
    init(
        messages: Binding<[Message]>,
        onAppearMessage: Binding<Message>,
        scrollToBottom: Binding<Bool>,
        isBottom: Binding<Bool>,
        refreshOldMessages: Binding<Bool>,
        IDToScrollMove: Binding<UUID>,
        inputView: @escaping () -> AnyView
    ) {
        self._messages = messages
        self._onAppearMessage = onAppearMessage
        self.inputView = inputView
        self._scrollToBottom = scrollToBottom
        self._isBottom = isBottom
        self._refreshOldMessages = refreshOldMessages
        self._IDToScrollMove = IDToScrollMove
    }
    
}

public extension ChatView {
    
    /// Triggered when a ChatMessage is tapped.
    func onMessageCellTapped(_ action: @escaping (Message) -> Void) -> Self {
        then({ $0.onMessageCellTapped = action })
    }
    
    /// Present ContextMenu when a message cell is long pressed.
    func messageCellContextMenu(_ action: @escaping (Message) -> AnyView) -> Self {
        then({ $0.messageCellContextMenu = action })
    }
    
    /// Triggered when a quickReplyItem is selected (ChatMessageKind.quickReply)
    func onQuickReplyItemSelected(_ action: @escaping (QuickReplyItem) -> Void) -> Self {
        then({ $0.onQuickReplyItemSelected = action })
    }
    
    /// Present contactItem's footer buttons. (ChatMessageKind.contactItem)
    func contactItemButtons(_ section: @escaping (ContactItem, Message) -> [ContactCellButton]) -> Self {
        then({ $0.contactCellFooterSection = section })
    }
    
    /// To listen text tapped events like phone, url, date, address
    func onAttributedTextTappedCallback(action: @escaping () -> AttributedTextTappedCallback) -> Self {
        then({ $0.onAttributedTextTappedCallback = action })
    }
    
    /// Triggered when the carousel button tapped.
    func onCarouselItemAction(action: @escaping (CarouselItemButton, Message) -> Void) -> Self {
        then({ $0.onCarouselItemAction = action })
    }
    
}
