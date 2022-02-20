//
//  DBInteractor.swift
//  ContactOptimization
//
//  Created by Ankur Prakash on 12/02/22.
//

import Foundation

public class DBInteractor {
    
    static let shared = DBInteractor()
    lazy var globalRealmDB = GlobalRealmDB(name: "Admin.db")
    //lazy var realmDB = RealmDB(name: .just("User_1.db"))
    
    public lazy var testUsers = self.globalRealmDB.allUsers()
    
//    public init() {
//        for i in 0...99 {
//            globalRealmDB.addUser(User(name: "User \(i)", age: i))
//        }
//        print("COUNT = \(self.globalRealmDB.allUsers().count)")
//    }
}

public extension DBInteractor {
    
    func addUser(_ user: User) {
        self.globalRealmDB.addUser(user)
    }
}
