//
//  AppDelegate.swift
//  DelayedStartup
//
//  Created by Sam Deane on 05/06/2020.
//  Copyright © 2020 Elegant Chaos. All rights reserved.
//

import Cocoa
import Files
import SwiftUI

class Model: ObservableObject {
    struct Item {
        let url: URL
        let bookmark: Data
        
        init?(url: URL) {
            guard let data = url.secureBookmark(options: [.withSecurityScope, .securityScopeAllowOnlyReadAccess]) else { return nil }
            self.url = url
            self.bookmark = data
        }
        
        init?(data: Data) {
            guard let url = URL.resolveSecureBookmark(data) else { return nil }
            self.url = url
            self.bookmark = data
        }
    }
    
    @Published var startupItems: [Item] = []
    
    func load() {
        if let array = UserDefaults.standard.array(forKey: "Items"), let items = array as? [Data] {
            for data in items {
                if let item = Item(data: data) {
                    startupItems.append(item)
                }
            }
        }
    }
    
    func save() {
        var array: [Data] = []
        for item in startupItems {
            array.append(item.bookmark)
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
        let items = urls.compactMap({ Model.Item(url: $0) })
        model.startupItems.append(contentsOf: items)
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

