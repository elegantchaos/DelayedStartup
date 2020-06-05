// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/06/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import AppKit

class Model: ObservableObject {
    class Item: Codable {
        let identifier: UUID
        let bookmark: Data
        var appID: String?
        var name: String
        
        var url: URL? { URL.resolveSecureBookmark(bookmark) }
        var label: String { appID == nil ? name : "\(name) (\(appID!))" }
        
        init?(url: URL) {
            guard let data = url.secureBookmark(options: [.withSecurityScope, .securityScopeAllowOnlyReadAccess]) else { return nil }
            self.identifier = UUID()
            self.name = url.deletingPathExtension().lastPathComponent
            self.bookmark = data
        }
        
        func open() {
            if let identifier = appID {
                open(using: identifier)
            } else if let url = self.url {
                open(using: url)
            } else {
                print("Couldn't resolve \(label).")
            }
        }
        
        func open(using url: URL) {
            NSWorkspace.shared.openApplication(at: url, configuration: NSWorkspace.OpenConfiguration()) { app, error in
                if let error = error {
                    print("Problem starting \(self.name): \(error)")
                } else if let app = app {
                    print("Started \(self.label) using \(url).")
                    DispatchQueue.main.async {
                        self.update(from: app)
                    }
                }
            }
        }
        
        func open(using identifier: String) {
            NSWorkspace.shared.open([], withAppBundleIdentifier: identifier, options: [], additionalEventParamDescriptor: nil, launchIdentifiers: nil)
            print("Started \(label).")
        }
        
        func update(from app: NSRunningApplication) {
            var updated = false
            if appID != app.bundleIdentifier {
                appID = app.bundleIdentifier
                updated = true
            }
            
            if let name = app.localizedName, name != self.name {
                self.name = name
                updated = true
            }
            
            if updated {
                AppDelegate.shared.model.save()
            }
        }
    }
    
    @Published var startupItems: [Item] = []
    
    func load() {
        let decoder = JSONDecoder()
        if let json = UserDefaults.standard.string(forKey: "Items"), let data = json.data(using: .utf8) {
            if let items = try? decoder.decode([Item].self, from: data) {
                startupItems = items
            }
        }
    }
    
    func save() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(startupItems), let json = String(data: encoded, encoding: .utf8) {
            UserDefaults.standard.set(json, forKey: "Items")
        }
    }
    
    func performStartup() {
        for item in startupItems {
            item.open()
        }
    }
    
    
}
