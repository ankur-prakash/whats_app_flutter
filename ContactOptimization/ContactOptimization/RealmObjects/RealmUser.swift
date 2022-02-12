//
//  RealmUser.swift
//  ContactOptimization
//
//  Created by Ankur Prakash on 12/02/22.
//

import Foundation
import RealmSwift

/*
 
 Realm model properties need the dynamic var attribute in order for these properties to become accessors for the underlying database data.
 There are two exceptions to this: List and RealmOptional properties cannot be declared as dynamic because generic properties cannot be represented in the Objective-C runtime, which is used for dynamic dispatch of dynamic properties, and should always be declared with let.
 The dynamic keyword is what allows for Realm to be notified of changes to model variables, and consequently reflect them to the database.

 @objc dynamic is MUST **************************
 
 */

public class RealmUser: Object {
    
    @objc dynamic public var name: String = ""
    @objc dynamic public var age: Int = 0
    @objc dynamic public var id: String = UUID().uuidString
    
    public override class func primaryKey() -> String? {
        "id"
    }
}

public extension RealmUser {
    
    convenience init(user: User) {
        self.init()
        self.name = user.name
        print("user.name = \(user.name)")
        self.id = user.id
        self.age = user.age
    }
}

public extension User {
    
    init(realmUser: RealmUser) {
        self.id = realmUser.id
        self.name = realmUser.name
        print("realmUser.name = \(realmUser.name) \(realmUser.id) \(realmUser.age)")
        self.age = realmUser.age
    }
}
