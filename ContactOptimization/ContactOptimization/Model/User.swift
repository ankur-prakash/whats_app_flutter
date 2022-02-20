//
//  User.swift
//  ContactOptimization
//
//  Created by Ankur Prakash on 12/02/22.
//

import Foundation

public struct User: Identifiable {
    
    public var id: String
    public var name: String
    public var age: Int
    
    public init(name: String, age: Int) {
        self.id = UUID().uuidString
        self.name = name
        self.age = age
    }
}
