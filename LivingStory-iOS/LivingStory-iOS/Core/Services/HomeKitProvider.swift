//
//  HomeKitProvider.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 1/19/26.
//

import HomeKit

final class HomeKitProvider: NSObject, HomeKitServiceProtocol {
    private let homeManager = HMHomeManager()
    let accessories = Observable<[HMAccessory]>([])
    
    func startDiscovery() {
        let allAccessories = homeManager.homes.flatMap($0.accessories)
        accessories.value = allAccessories
    }
}
