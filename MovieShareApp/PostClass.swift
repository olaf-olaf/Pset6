//
//  PostClass.swift
//  MovieShareApp
//
//  Created by Olaf Kroon on 07/12/16.
//  Copyright © 2016 Olaf Kroon. All rights reserved.
//

import Foundation

class Post {
    
    var email = String()
    var reserved = Bool()
    var title = String()
    var id = String()
    var parent = String()
    
    
    init(email: String, reserved: Bool, title: String) {
        
        self.email = email
        self.reserved = reserved
        self.title = title
        
    }
}