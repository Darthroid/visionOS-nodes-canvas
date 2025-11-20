//
//  CreateNodeView.swift
//  nodes-demo
//
//  Created by Олег Комаристый on 20.11.2025.
//

import SwiftUI

struct CreateNodeView: View {
    @Environment(AppModel.self) var appModel
    @Environment(\.dismiss) var dismiss
    
    @State var name: String = ""
    @State var description: String = ""
    
    var body: some View {
        NavigationStack {
            VStack{
                Form {
                    TextField(text: $name) {
                        Text("Name")
                    }
                    
                    TextField(text: $description) {
                        Text("Description")
                    }
                }
                
                HStack {
                    Button("Create") {
                        appModel.addNode(name: name, description: description, position: nil)
                        dismiss()
                    }
                    .disabled(name.isEmpty && description.isEmpty)
                    
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .padding()
            .navigationTitle(Text("Create Node"))
        }
    }
}
