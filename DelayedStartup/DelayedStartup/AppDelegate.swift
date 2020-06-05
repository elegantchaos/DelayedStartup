// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/06/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Cocoa
import Files
import SwiftUI


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
    
    func selectItemsToAdd() {
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
                    self.model.add(urls: panel.urls)
                default:
                    break
            }
        }
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

