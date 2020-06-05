// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/06/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import AppKit

class Model: ObservableObject {
    enum ModelError: Error {
        case noNameOrIdentifier
        case noErrorOrApplication
    }
    
    class Item: Codable, Identifiable {
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
        
        func open(completion: @escaping (Result<Bool, Error>) -> Void) {
            if let identifier = appID {
                open(using: identifier, completion: completion)
            } else if let url = self.url {
                open(using: url, completion: completion)
            } else {
                completion(.failure(ModelError.noNameOrIdentifier))
            }
        }
        
        func open(using url: URL, completion: @escaping (Result<Bool, Error>) -> Void) {
            NSWorkspace.shared.openApplication(at: url, configuration: NSWorkspace.OpenConfiguration()) { app, error in
                if let error = error {
                    completion(.failure(error))
                } else if let app = app {
                    print("Started \(self.label) using \(url).")
                    completion(.success(self.update(from: app)))
                } else {
                    completion(.failure(ModelError.noErrorOrApplication))
                }
            }
        }
        
        func open(using identifier: String, completion: @escaping (Result<Bool, Error>) -> Void) {
            NSWorkspace.shared.open([], withAppBundleIdentifier: identifier, options: [], additionalEventParamDescriptor: nil, launchIdentifiers: nil)
            print("Started \(label).")
            completion(.success(false))
        }
        
        func update(from app: NSRunningApplication) -> Bool {
            var updated = false
            if appID != app.bundleIdentifier {
                appID = app.bundleIdentifier
                updated = true
            }
            
            if let name = app.localizedName, name != self.name {
                self.name = name
                updated = true
            }
            
            return updated
        }
    }
    
    @Published internal var items: [Item] = []
    let queue = DispatchQueue.main
    
    func load() {
        queue.async {
            let decoder = JSONDecoder()
            if let json = UserDefaults.standard.string(forKey: "Items"), let data = json.data(using: .utf8) {
                if let items = try? decoder.decode([Item].self, from: data) {
                    self.items = items
                }
            }
        }
    }
    
    func save() {
        queue.async {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(self.items), let json = String(data: encoded, encoding: .utf8) {
                UserDefaults.standard.set(json, forKey: "Items")
            }
        }
    }
    
    func add(urls: [URL]) {
        queue.async {
            let items = urls.compactMap({ Model.Item(url: $0) })
            self.items.append(contentsOf: items)
            self.save()
        }
    }
    
    func delete(item: Item) {
        queue.async {
            self.items.removeAll(where: { $0.identifier == item.identifier })
            self.save()
        }
    }
    
    func performStartup() {
        let count = items.count
        var done = 0
        var updated = false
        for item in items {
            item.open() { result in
                done += 1
                switch result {
                    case .success(let didUpdate):
                        updated = updated || didUpdate
                    case .failure(let error):
                        print("Failed to open \(item.name): \(error).")
                }
                if done == count {
                    if updated {
                        print("Item(s) updated, so saving.")
                        self.save()
                    }
                }
            }
        }
    }
    
    
}
