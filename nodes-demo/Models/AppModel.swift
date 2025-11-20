//
//  AppModel.swift
//  nodes-demo
//
//  Created by Олег Комаристый on 18.11.2025.
//

import SwiftUI
import Observation
import RealityKit

@MainActor
@Observable
final class AppModel: Sendable {
    var nodes: [Node] = []
    var selectedNodeId: String?
    
    init() {
        self.nodes = MockData.nodes
    }
    
    func addNode(name: String, description: String, position: (x: Float, y: Float, z: Float)?) {
        let _position: (x: Float, y: Float, z: Float)
            
            if let providedPosition = position {
                _position = providedPosition
            } else if nodes.isEmpty {
                // If no nodes exist, place in the center
                _position = (0, 0, 0)
            } else {
                // Calculate center position of all existing nodes
                let totalX = nodes.reduce(0.0) { $0 + $1.x }
                let totalY = nodes.reduce(0.0) { $0 + $1.y }
                let totalZ = nodes.reduce(0.0) { $0 + $1.z }
                
                let centerX = totalX / Float(nodes.count)
                let centerY = totalY / Float(nodes.count)
                let centerZ = totalZ / Float(nodes.count)
                
                _position = (centerX, centerY, centerZ)
            }
        
        let node = Node(
            id: UUID().uuidString,
            name: name,
            description: description,
            x: _position.x,
            y: _position.y,
            z: _position.z
        )
        nodes.append(node)
    }
    
    func removeNode(_ node: Node) {
        nodes.removeAll { $0.id == node.id }
    }
}
