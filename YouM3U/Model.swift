//
//  M3U.swift
//  YouM3U
//
//  Created by Don on 6/2/16.
//  Copyright © 2016 dongxing. All rights reserved.
//

import UIKit

func basicACL() -> AVACL! {
    let acl = AVACL()
    acl.setPublicReadAccess(true)
    acl.setPublicWriteAccess(false)
    acl.setWriteAccess(true, forUser: AVUser.currentUser())
    return acl
}

class M3U: AVObject, AVSubclassing {

    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    var url: String!
    var type: String?
    var group: String?
    var name : String?
    var cover : AVFile?
    
    var likes: Int = 0
    
}
