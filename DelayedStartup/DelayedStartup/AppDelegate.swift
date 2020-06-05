//
//  AppDelegate.swift
//  DelayedStartup
//
//  Created by Sam Deane on 05/06/2020.
//  Copyright © 2020 Elegant Chaos. All rights reserved.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    var startupItems: [URL] = []

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView()

        // Create the window and set the content view. 
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
        
        loadItems()
        scheduleCheck()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func loadItems() {
        if let array = UserDefaults.standard.array(forKey: "Items"), let items = array as? [Data] {
            for data in items {
                if let item = URL(dataRepresentation: data, relativeTo: nil) {
                    startupItems.append(item)
                }
            }
        }
    }
    
    func saveItems() {
        var array: [Data] = []
        for item in startupItems {
            do {
            let data = try item.bookmarkData()
            array.append(data)
            } catch {
                
            }
        }
        UserDefaults.standard.set(array, forKey: "Items")
    }
        
    func scheduleCheck() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now().advanced(by: .seconds(1))) {
            self.performCheck()
        }
    }
    
    func performCheck() {
        if FileManager.default.fileExists(atPath: "/Volumes/caconym") {
            performStartup()
        } else {
            scheduleCheck()
        }
    }
    
    func performStartup() {
        for item in startupItems {
            print("starting \(item)")
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now().advanced(by: .seconds(1))) {
            NSApp.terminate(self)
        }
    }
    
}

