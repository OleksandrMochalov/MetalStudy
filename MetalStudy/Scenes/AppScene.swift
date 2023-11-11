//
//  AppScene.swift
//  MetalStudy
//
//  Created by Oleksandr on 10.11.2023.
//

import MetalKit

class AppScene: Node {
    var device: MTLDevice
    var size: CGSize
    var node: Node?
    
    init(device: MTLDevice, size: CGSize) {
        self.device = device
        self.size = size
    }
    
    override func add(child: Node) {
            self.node = child
        }
}
