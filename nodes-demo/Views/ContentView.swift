//
//  ContentView.swift
//  nodes-demo
//
//  Created by Oleg Komaristy on 17.11.2025.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    @Environment(AppModel.self) var appModel
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @State var selectedNodeId: String?
    @State var showNodeForm: Bool = false
    
    var body: some View {
        NavigationSplitView(sidebar: {
            List(appModel.nodes, selection: $selectedNodeId) { node in
                VStack(alignment: .leading) {
                    Text(node.name)
                        .font(.headline)
                    Text(node.positionDescription)
                        .font(.footnote)
                }
            }
            .toolbar(content: {
                Button {
                    showNodeForm = true
                } label: {
                    Image(systemName: "plus")
                }
            })
            .navigationTitle(Text("Nodes Demo"))
        }, detail: {
            Text("""
                Use gestures to move nodes
                Click on the node to show detail information
                """
            )
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
        })
        .sheet(isPresented: $showNodeForm) {
            CreateNodeView()
                .environment(appModel)
        }
        .onChange(of: selectedNodeId, { oldValue, newValue in
            appModel.selectedNodeId = newValue
        })
        .onAppear {
            Task {
                await openImmersiveSpace(id: "NodeMapView")
            }
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
