//
//  ChatMessage.swift
//  SwiftyChatbot
//
//  Created by Enes Karaosman on 19.05.2020.
//  Copyright © 2020 All rights reserved.
//

import Foundation

public protocol ChatMessage: Identifiable {
    
    associatedtype User: ChatUser
    /// The `User` who sent this message.
    var user: User { get }
    
    /// Security ID UUID string
    var securityID: String {get}
    
    /// Type of message
    var messageKind: ChatMessageKind { get }
    
    /// To determine if user is the current user to properly align UI.
    var isSender: Bool { get }
    
    /// The date message sent.
    var date: Date { get }
    
    ///Sent to Server
    var isSent: Bool {get set}
    
    /// Received Message
    var isReceived: Bool { get set }
    
    /// Displayed Message
    
    var isDisplayed: Bool { get set }
    
    var fileName: String? { get set }
    var messageDescription: String? { get set }
    
}
