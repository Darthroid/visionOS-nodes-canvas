//
//  AppModel.swift
//  nodes-demo
//
//  Created by Олег Комаристый on 18.11.2025.
//

import SwiftUI
import Observation
import RealityKit
import SwiftData

@MainActor
@Observable
final class AppModel: Sendable {
    var container: ModelContainer?
    
    var context: ModelContext? {
        container?.mainContext
    }
    
    var nodes: [Node] = []
    var connections: [NodeConnection] = []
    var selectedNodeId: String?
    
    init() {
        self.nodes = MockData.nodes
        self.connections = MockData.connections
        
        let configuration = ModelConfiguration(isStoredInMemoryOnly: false, allowsSave: true)
        self.container = try? ModelContainer(
            for: NodeConnection.self, Node.self,
            configurations: configuration
        )
        
        fetchItems()
    }
    
    func node(forId id: String) -> Node? {
        return nodes.first(where: { $0.id == id })
    }
    
    func hasConnection(nodeId: String) -> Bool {
        return connections.contains(where: { $0.fromNodeId == nodeId || $0.toNodeId == nodeId })
    }
    
    func nodesConnectedWith(node: Node) -> [Node] {
        let connections = connections.filter { $0.fromNodeId == node.id || $0.toNodeId == node.id }
        var nodes: [Node] = []
        
        for c in connections {
            let otherNodeId = c.fromNodeId == node.id ? c.toNodeId : c.fromNodeId
            if let otherNode = self.node(forId: otherNodeId) {
                nodes.append(otherNode)
            }
        }
        
        return nodes
    }
    
    func addNode(name: String, detail: String, position: (x: Float, y: Float, z: Float)?) {
        let _position: (x: Float, y: Float, z: Float)
            
            if let providedPosition = position {
                _position = providedPosition
            } else if nodes.isEmpty {
                // If no nodes exist, place in the center
                _position = (0, 1.0, -1.5)
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
            detail: detail,
            x: _position.x,
            y: _position.y,
            z: _position.z
        )
        
        context?.insert(node)
        save()
    }
    
    func updateNode(id: String, with node: Node) {
        if let objectToUpdate = try? context?.fetch(FetchDescriptor<Node>(predicate: #Predicate { $0.id == id })).first {
            objectToUpdate.x = node.x
            objectToUpdate.y = node.y
            objectToUpdate.z = node.z
            objectToUpdate.name = node.name
            objectToUpdate.detail = node.detail
        }
        save()
    }
    
    func updateNode(id: String, name: String, detail: String) {
        if let objectToUpdate = try? context?.fetch(FetchDescriptor<Node>(predicate: #Predicate { $0.id == id })).first {
            objectToUpdate.name = name
            objectToUpdate.detail = detail
        }
        save()
    }
    
    func removeNode(at indexSet: IndexSet) {
        let nodesToDelete = nodes.enumerated()
            .filter { indexSet.contains($0.offset) }
            .map { $0.element }
        
        nodesToDelete.forEach { removeNode($0) }
    }
    
    func removeNode(_ node: Node) {
        let nodeId = node.id
        context?.delete(node)
        try? context?.delete(model: NodeConnection.self, where: #Predicate<NodeConnection> { item in
            item.fromNodeId == nodeId || item.toNodeId == nodeId
        })
        save()
    }
    
    fileprivate func save() {
        guard let context, context.hasChanges else { return }
        try? context.save()
        fetchItems()
    }
    
    func updatePosition(for nodeId: String, newPosition: SIMD3<Float>) {
        if let objectToUpdate = try? context?.fetch(FetchDescriptor<Node>(predicate: #Predicate { $0.id == nodeId })).first {
            objectToUpdate.x = newPosition.x
            objectToUpdate.y = newPosition.y
            objectToUpdate.z = newPosition.z
        }
        save()
    }
    
    func addConnection(from fromNodeId: String, to toNodeId: String) {
        guard fromNodeId != toNodeId,
              nodes.contains(where: { $0.id == fromNodeId }),
              nodes.contains(where: { $0.id == toNodeId }) else { return }
        
        guard !connections.contains(where: {
            ($0.fromNodeId == fromNodeId && $0.toNodeId == toNodeId) ||
            ($0.fromNodeId == toNodeId && $0.toNodeId == fromNodeId)
        }) else { return }
        
        let connection = NodeConnection(
            id: UUID().uuidString,
            fromNodeId: fromNodeId,
            toNodeId: toNodeId
        )
        context?.insert(connection)
        save()
    }
    
    
    func removeConnectionsBetween(_ node1: Node, and node2: Node) {
        
        let connections = connections.filter({
            $0.fromNodeId == node1.id && $0.toNodeId == node2.id
            || $0.fromNodeId == node2.id && $0.toNodeId == node1.id
        })
        
        connections.forEach {
            removeConnection($0)
        }
    }
    
    
    func removeConnection(_ connection: NodeConnection) {
        context?.delete(connection)
        save()
    }
    
    func removeConnection(nodeId: String) {
        if let connection = connections.first(where: { $0.fromNodeId == nodeId || $0.toNodeId == nodeId }) {
            removeConnection(connection)
        }
    }
    
    func fetchItems() {
        do {
            let nodeDescriptor = FetchDescriptor<Node>(sortBy: [SortDescriptor(\.name)])
            let connectionsDescriptor = FetchDescriptor<NodeConnection>(sortBy: [SortDescriptor(\.id)])
            nodes = try context?.fetch(nodeDescriptor) ?? []
            connections = try context?.fetch(connectionsDescriptor) ?? []
        } catch {
            print("Failed to fetch items: \(error)")
        }
    }
}
