//
//  Observable.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 1/19/26.
//

import Foundation

final class Observable<T> {
    private var listener: ((T) -> Void)?
    
    var value: T {
        didSet { listener?(value) }
    }
    
    init(_ value: T) {
        self.value = value
    }
    
    func bind(_ closure: @escaping (T) -> Void) {
        closure(value)
        self.listener = closure
    }
}
