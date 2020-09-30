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
    public var inputView: (_ proxy: GeometryProxy) -> AnyView
    
    @available(iOS 14.0, *)
    @Binding private var scrollToBottom: Bool
    
    @available(iOS 14.0, *)
    @State private var scrollProxy: ScrollViewProxy?

    private var onMessageCellTapped: (Message) -> Void = { msg in print(msg.messageKind) }
    private var messageCellContextMenu: (Message) -> AnyView = { _ in EmptyView().embedInAnyView() }
    private var onQuickReplyItemSelected: (QuickReplyItem) -> Void = { _ in }
    private var contactCellFooterSection: (ContactItem, Message) -> [ContactCellButton] = { _, _ in [] }
    private var onAttributedTextTappedCallback: () -> AttributedTextTappedCallback = { return AttributedTextTappedCallback() }
    private var onCarouselItemAction: (CarouselItemButton, Message) -> Void = { (_, _) in }
    
    /// Initialize
    /// - Parameters:
    ///   - messages: Messages to display
    ///   - inputView: inputView view to provide message
    public init(
        messages: Binding<[Message]>,
        inputView: @escaping (_ proxy: GeometryProxy) -> AnyView
    ) {
        self._messages = messages
        self.inputView = inputView
        self._scrollToBottom = .constant(false)
    }
    
    /// iOS 14 initializer, for supporting scrollToBottom
    /// - Parameters:
    ///   - messages: Messages to display
    ///   - scrollToBottom: set to `true` to scrollToBottom
    ///   - inputView: inputView view to provide message
    @available(iOS 14.0, *)
    public init(
        messages: Binding<[Message]>,
        scrollToBottom: Binding<Bool>,
        inputView: @escaping (_ proxy: GeometryProxy) -> AnyView
    ) {
        self._messages = messages
        self.inputView = inputView
        self._scrollToBottom = scrollToBottom
    }
    
    public var body: some View {
        DeviceOrientationBasedView(
            portrait: { GeometryReader { self.body(in: $0) } },
            landscape: { GeometryReader { self.body(in: $0) } }
        )
        .environmentObject(OrientationInfo())
        .edgesIgnoringSafeArea(.bottom)
    }
    
    // MARK: - Body in geometry
    @ViewBuilder private func body(in geometry: GeometryProxy) -> some View {
        if #available(iOS 14.0, *) {
            iOS14Body(in: geometry)
        } else {
            iOS14Fallback(in: geometry)
        }
    }
    
    // MARK: - List Item
    private func chatMessageCellContainer(in size: CGSize, with message: Message) -> some View {
        ChatMessageCellContainer(
            message: message,
            size: size,
            onQuickReplyItemSelected: self.onQuickReplyItemSelected,
            contactFooterSection: self.contactCellFooterSection,
            onTextTappedCallback: self.onAttributedTextTappedCallback,
            onCarouselItemAction: self.onCarouselItemAction
        )
        .onTapGesture { onMessageCellTapped(message) }
        .contextMenu(menuItems: { messageCellContextMenu(message) })
        .modifier(AvatarModifier<Message, User>(message: message))
        .modifier(MessageModifier(messageKind: message.messageKind, isSender: message.isSender))
        .modifier(CellEdgeInsetsModifier(isSender: message.isSender))
        .id(message.id)
    }
    
    // MARK: iOS14 Body
    @available(iOS 14.0, *)
    private func iOS14Body(in geometry: GeometryProxy) -> some View {
        
        ZStack(alignment: .bottom) {
            
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack {
                        ForEach(messages) { message in
                            chatMessageCellContainer(in: geometry.size, with: message)
                        }
                    }
                }
                .onAppear { scrollProxy = proxy }
            }
            .padding(.bottom, geometry.safeAreaInsets.bottom + 56)
//            .background(
//                LinearGradient(gradient: Gradient(colors: [Color.orange, .pink]), startPoint: .topLeading, endPoint: .bottomTrailing)
//            )

            inputView(geometry)

        }
        .keyboardAwarePadding()
        .dismissKeyboardOnTappingOutside()
        .onChange(of: scrollToBottom) { _ in
            if scrollToBottom {
                withAnimation {
                    scrollProxy?.scrollTo(messages.last?.id)
                }
                scrollToBottom = false
            }
        }
    }
    
    // MARK: iOS14 Fallback
    private func iOS14Fallback(in geometry: GeometryProxy) -> some View {
        ZStack(alignment: .bottom) {
            List {
                ForEach(messages) { message in
                    chatMessageCellContainer(in: geometry.size, with: message)
                }
            }
            .padding(.bottom, geometry.safeAreaInsets.bottom + 56)

            inputView(geometry)

        }
        .onAppear {
            // To remove only extra separators below the list:
            UITableView.appearance().tableFooterView = UIView()
            // To remove all separators including the actual ones:
            UITableView.appearance().separatorStyle = .none
        }
    }
    
}

extension ChatView {
    
    /// Triggered when a ChatMessage is tapped.
    public func onMessageCellTapped(_ action: @escaping (Message) -> Void) -> ChatView {
        var copy = self
        copy.onMessageCellTapped = action
        return copy
    }
    
    /// Present ContextMenu when a message cell is long pressed.
    public func messageCellContextMenu(_ action: @escaping (Message) -> AnyView) -> ChatView {
        var copy = self
        copy.messageCellContextMenu = action
        return copy
    }
    
    /// Triggered when a quickReplyItem is selected (ChatMessageKind.quickReply)
    public func onQuickReplyItemSelected(_ action: @escaping (QuickReplyItem) -> Void) -> ChatView {
        var copy = self
        copy.onQuickReplyItemSelected = action
        return copy
    }
    
    /// Present contactItem's footer buttons. (ChatMessageKind.contactItem)
    public func contactItemButtons(_ section: @escaping (ContactItem, Message) -> [ContactCellButton]) -> ChatView {
        var copy = self
        copy.contactCellFooterSection = section
        return copy
    }
    
    /// To listen text tapped events like phone, url, date, address
    public func onAttributedTextTappedCallback(action: @escaping () -> AttributedTextTappedCallback) -> ChatView {
        var copy = self
        copy.onAttributedTextTappedCallback = action
        return copy
    }
    
    /// Triggered when the carousel button tapped.
    public func onCarouselItemAction(action: @escaping (CarouselItemButton, Message) -> Void) -> ChatView {
        var copy = self
        copy.onCarouselItemAction = action
        return copy
    }
    
}
