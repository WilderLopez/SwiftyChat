//
//  MockMessages.swift
//  SwiftyChatbot
//
//  Created by Enes Karaosman on 18.05.2020.
//  Copyright © 2020 All rights reserved.
//

import class UIKit.UIImage
import Foundation

public struct MockMessages {
    
    public enum Kind {
        case Text
        case Image
        case Location
        case Contact
        case QuickReply
        case Carousel
        
        private var messageKind: ChatMessageKind {
            switch self {
            case .Text: return .text("")
            case .Image: return .image(.remote(URL(string: "")!))
            case .Location: return .location(LocationRow(latitude: .nan, longitude: .nan))
            case .Contact: return .contact(ContactRow(displayName: ""))
            case .QuickReply: return .quickReply([])
            case .Carousel: return .carousel([CarouselRow(title: "", imageURL: nil, subtitle: "", buttons: [])])
            }
        }
    }
    
    // MARK: - Concrete model for Location
    private struct LocationRow: LocationItem {
        var latitude: Double
        var longitude: Double
    }
    
    // MARK: - Concrete model for Contact
    private struct ContactRow: ContactItem {
        var displayName: String
        var image: UIImage?
        var initials: String = ""
        var phoneNumbers: [String] = []
        var emails: [String] = []
    }
    
    // MARK: - Concrete model for QuickReply
    private struct QuickReplyRow: QuickReplyItem {
        var title: String
        var payload: String
    }
    
    // MARK: - Concrete model for Carousel
    private struct CarouselRow: CarouselItem {
        var title: String
        var imageURL: URL?
        var subtitle: String
        var buttons: [CarouselItemButton]
    }
    
    // MARK: - Concrete model for ChatMessage
    public struct ChatMessageItem: ChatMessage {
        
        public var id = UUID()
        public var securityID : String
        public var user: ChatUserItem
        public var messageKind: ChatMessageKind
        public var isSender: Bool
        public var date: Date
        public var isSent: Bool
        public var isReceived: Bool
        public var isDisplayed: Bool

        public init(
            securityID: String,
            user: ChatUserItem,
            messageKind: ChatMessageKind,
            isSender: Bool = false,
            date: Date = .init(),
            isSent: Bool = false,
            isDisplayed: Bool = false,
            isReceived: Bool = false
        ) {
            self.securityID = securityID
            self.user = user
            self.messageKind = messageKind
            self.isSender = isSender
            self.date = date
            self.isSent = isSent
            self.isReceived = isReceived
            self.isDisplayed = isDisplayed
        }
    }
    //MARK: - Model for Remote Response
    public struct RemoteResponseRow : RemoteResponseItem {
        public typealias Message = ChatMessageItem
        
        public var tnail: UIImage
        public var isdownloaded: Bool
        
        public var message: Message
        
        public init(
            tnail: UIImage,
            isdownloaded: Bool,
            message: Message
        ) {
            self.tnail = tnail
            self.isdownloaded = isdownloaded
            self.message = message
        }
        
    }
    
    // MARK: - Concrete model for ChatUser
    public struct ChatUserItem: ChatUser {

        public static func == (lhs: ChatUserItem, rhs: ChatUserItem) -> Bool {
            lhs.id == rhs.id
        }

        public let id = UUID().uuidString
        
        /// Username
        public var userName: String
        
        /// User's chat profile image, considered if `avatarURL` is nil
        public var avatar: UIImage?
        
        /// User's chat profile image URL
        public var avatarURL: URL?

        public init(userName: String, avatarURL: URL? = nil, avatar: UIImage? = nil) {
            self.userName = userName
            self.avatar = avatar
            self.avatarURL = avatarURL
        }
        
    }
    
    public static var sender: ChatUserItem = .init(
        userName: "Sender",
        avatarURL: URL(string: "https://ebbot.ai/wp-content/uploads/2020/04/Ebbot-Sa%CC%88ljsa%CC%88l.png")
    )
    
    public static var chatbot: ChatUserItem = .init(
        userName: "Chatbot",
        //        avatar: #imageLiteral(resourceName: "avatar")
        avatarURL: URL(string: "https://3.bp.blogspot.com/-vO7C5BPCaCQ/WigyjG6Q8lI/AAAAAAAAfyQ/1tobZMMwZ2YEI0zx5De7kD31znbUAth0gCLcBGAs/s200/TOMI_avatar_full.png")
    )
    
    private static var randomUser: ChatUserItem {
        [sender, chatbot].randomElement()!
    }
    
    public static var mockImages: [UIImage] = []
    
    public static func generateMessage(kind: MockMessages.Kind) -> ChatMessageItem {
        let randomUser = Self.randomUser
        switch kind {
        
        case .Image:
            guard let randomImage = mockImages.randomElement() else { fallthrough }
            return ChatMessageItem(
                securityID: UUID().uuidString,
                user: randomUser,
                messageKind: .image(.local(randomImage)),
                isSender: randomUser == Self.sender
            )
            
        case .Text:
            return ChatMessageItem(
                securityID: UUID().uuidString,
                user: randomUser,
                messageKind: .text(Lorem.sentence()),
                isSender: randomUser == Self.sender
            )
            
        case .Carousel:
            return ChatMessageItem(
                securityID: UUID().uuidString,
                user: Self.chatbot,
                messageKind: .carousel([
                    CarouselRow(
                        title: "Multiline Title",
//                        imageURL: URL(string:"https://picsum.photos/400/300"),
                        imageURL: URL(string: "https://picsum.photos/id/1/400/200"),
                        subtitle: "Multiline Subtitle, you do not believe me ?",
                        buttons: [
                            CarouselItemButton(title: "Action Button")
                        ]
                    ),
                    CarouselRow(
                        title: "This one is really multiline",
//                        imageURL: URL(string:"https://picsum.photos/400/300"),
                        imageURL: URL(string: "https://picsum.photos/id/2/400/200"),
                        subtitle: "Multilinable Subtitle",
                        buttons: [
                            CarouselItemButton(title: "Tap me!")
                        ]
                    )
                ]),
                isSender: false
            )
            
        case .QuickReply:
            let quickReplies: [QuickReplyRow] = (1...Int.random(in: 2...4)).map { idx in
                return QuickReplyRow(title: "Option.\(idx)", payload: "opt\(idx)")
            }
            return ChatMessageItem(
                securityID: UUID().uuidString,
                user: randomUser,
                messageKind: .quickReply(quickReplies),
                isSender: randomUser == Self.sender
            )
            
        case .Location:
            let location = LocationRow(
                latitude: Double.random(in: 36...42),
                longitude: Double.random(in: 26...45)
            )
            return ChatMessageItem(
                securityID: UUID().uuidString,
                user: randomUser,
                messageKind: .location(location),
                isSender: randomUser == Self.sender
            )
            
        case .Contact:
            let contacts = [
                ContactRow(displayName: "Enes Karaosman"),
                ContactRow(displayName: "Adam Surname"),
                ContactRow(displayName: "Wilder López")
            ]
            return ChatMessageItem(
                securityID: UUID().uuidString,
                user: randomUser,
                messageKind: .contact(contacts.randomElement()!),
                isSender: randomUser == Self.sender
            )
            
        default:
            return ChatMessageItem(
                securityID: UUID().uuidString,
                user: randomUser,
                messageKind: .text("Bom!"),
                isSender: randomUser == Self.sender
            )
        }
    }
    
    public static var randomMessageKind: MockMessages.Kind {
        let allCases: [MockMessages.Kind] = [
            .Image,
            .Text, .Text, .Text,
            .Contact,
            .Text, .Text, .Text,
            .Carousel,
            .Location,
            .Text, .Text, .Text,
            .QuickReply
        ]
        return allCases.randomElement()!
    }
    
    public static func generatedMessages(count: Int = 30) -> [ChatMessageItem] {
        return (1...count).map { _ in generateMessage(kind: randomMessageKind)}
    }
    
}
