//
//  HomeKitServiceProtocol.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 1/19/26.
//

import Foundation
import Homekit

protocol HomeKitServiceProtocol {
    var accessories: Observable<[HMAccessory]> { get }
    func requestPermission() async -> Bool
    func startDiscovery()
}
