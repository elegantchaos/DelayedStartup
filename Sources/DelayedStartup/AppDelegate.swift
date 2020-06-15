// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/06/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import ApplicationExtensions
import Cocoa
import Files
import SwiftUI


class ViewState: ObservableObject {
    func selectItemsToAdd() {
        AppDelegate.shared.selectItemsToAdd()
    }
}

@NSApplicationMain
class AppDelegate: BasicApplication {
    
    static var shared: AppDelegate { NSApp.delegate as! AppDelegate }
    
    var window: NSWindow!
    let model = Model()
    let viewState = ViewState()
    
    override func setUp(withOptions options: BasicApplication.LaunchOptions) {
        model.load() {
            DispatchQueue.main.async {
                self.setupWindow()
                if !UserDefaults.standard.bool(forKey: "DontCheckOnStartup") {
                    self.scheduleCheck()
                }
            }
        }
    }

    override func tearDown() {
        model.save()
    }
    
    func setupWindow() {
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView()
            .environmentObject(viewState)
            .environmentObject(model)
        
        // Create the window and set the content view.
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
    }
    
    func selectItemsToAdd() {
        let panel = NSOpenPanel()
        panel.title = "Add Startup Items"
        panel.prompt = "Add"
        panel.message = "Select one or more items to launch at startup time."
        
        panel.allowedFileTypes = ["app"]
        panel.directoryURL = URL(fileURLWithPath: "/Applications")
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
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now().advanced(by: .seconds(30))) {
            self.performCheck()
        }
    }
    
    func performCheck() {
        if FileManager.default.fileExists(atPath: "/Volumes/caconym/Users") {
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

