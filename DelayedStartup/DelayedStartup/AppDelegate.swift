//
//  AppDelegate.swift
//  DelayedStartup
//
//  Created by Sam Deane on 05/06/2020.
//  Copyright © 2020 Elegant Chaos. All rights reserved.
//

import Cocoa
import SwiftUI

class Model: ObservableObject {
    @Published var startupItems: [URL] = []
    
    func load() {
        if let array = UserDefaults.standard.array(forKey: "Items"), let items = array as? [Data] {
            for data in items {
                do {
                    var wasStale = false
                    let item = try URL(resolvingBookmarkData: data, bookmarkDataIsStale: &wasStale)
                    startupItems.append(item)
                } catch {
                    
                }
            }
        }
    }
    
    func save() {
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
    
    func performStartup() {
        for item in startupItems {
            print("starting \(item)")
        }
    }
    
    
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    static var shared: AppDelegate { NSApp.delegate as! AppDelegate }
    
    var window: NSWindow!
    let model = Model()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView().environmentObject(model)
        
        // Create the window and set the content view.
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
        
        model.load()
        scheduleCheck()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func selectFoldersToAdd(completion: @escaping ([URL]) -> Void) {
        let panel = NSOpenPanel()
        panel.title = "Add Startup Items"
        panel.prompt = "Add"
        panel.message = "Select one or more items to launch at startup time."
        
        panel.allowedFileTypes = ["app"]
        
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowsMultipleSelection = true
        panel.beginSheetModal(for: window) { response in
            switch response {
                case .OK:
                    self.add(urls: panel.urls)
                default:
                    break
            }
        }
    }
    
    func add(urls: [URL]) {
        model.startupItems.append(contentsOf: urls)
        model.save()
    }
    
    func scheduleCheck() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now().advanced(by: .seconds(1))) {
            self.performCheck()
        }
    }
    
    func performCheck() {
        if FileManager.default.fileExists(atPath: "/Volumes/caconym") {
            model.performStartup()
        } else {
            scheduleCheck()
        }
    }
    
    func shutdown() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now().advanced(by: .seconds(1))) {
            NSApp.terminate(self)
        }
    }
}

