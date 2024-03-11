//
//  ContentView.swift
//  PowerSyncExample
//
//  Created by Manrich Van Greunen on 2024/03/06.
//

import SwiftUI


struct ContentView: View {
    var ps = PowerSync()
    
    @State private var versionText = "Loading version..."
    @State private var userText = "Loading user"
    
    var body: some View {
        
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("User: " + userText)
            Text("Version: " + versionText)
        }
        .padding()
        .onAppear { 
              Task {
                await ps.connect()
                await ps.createUser()
                  
                self.versionText = await ps.version()
                self.userText = await ps.firstUser()
              }
            }
    }
}



