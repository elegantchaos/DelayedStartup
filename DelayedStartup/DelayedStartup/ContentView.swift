//
//  ContentView.swift
//  DelayedStartup
//
//  Created by Sam Deane on 05/06/2020.
//  Copyright © 2020 Elegant Chaos. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var model: Model
    
    var body: some View {
        VStack {
            ForEach(model.startupItems, id: \.self) { item in
                Text(item.lastPathComponent)
            }

            HStack {
                Button(action: add) {
                    Text("Add")
                }
                
                Button(action: test) {
                    Text("Test")
                }
            }

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    func add() {
        AppDelegate.shared.selectFoldersToAdd() { folders in
            print(folders)
        }
    }
    
    func test() {
        AppDelegate.shared.model.performStartup()
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
