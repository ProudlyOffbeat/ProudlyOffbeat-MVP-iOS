//
//  UserDefaultsWrapper.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/22/26.
//

import Foundation

@propertyWrapper
struct UserDefault<T> {
    var key: String
    var defaultValue: T
    var userDefaults: UserDefaults

    init(key: String, defaultValue: T, userDefaults: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.userDefaults = userDefaults
    }

    var wrappedValue: T {
        get {
            return self.userDefaults.object(forKey: self.key) as? T ?? self.defaultValue
        } set {
            self.userDefaults.set(newValue, forKey: self.key)
        }
    }

    func remove() {
        self.userDefaults.removeObject(forKey: self.key)
    }
}
