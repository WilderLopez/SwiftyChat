//
//  File.swift
//  
//
//  Created by Wilder Lopez on 7/5/21.
//

import Foundation
import UIKit

public protocol RemoteResponseItem  {
    
    var tnail : UIImage { get set }
    
    associatedtype Message : ChatMessage
    var message : Message { get set }
    
    var isdownloaded : Bool { get set }
}
