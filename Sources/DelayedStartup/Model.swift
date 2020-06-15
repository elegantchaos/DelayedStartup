// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/06/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Files

#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

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
            #if canImport(UIKit)
            UIApplication.shared.open(url)
            #else
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
            #endif
        }
        
        func open(using identifier: String, completion: @escaping (Result<Bool, Error>) -> Void) {
            #if canImport(UIKit)
            #else
            NSWorkspace.shared.open([], withAppBundleIdentifier: identifier, options: [], additionalEventParamDescriptor: nil, launchIdentifiers: nil)
            print("Started \(label).")
            completion(.success(false))
            #endif
        }
        
        #if canImport(UIKit)
        #else
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
        #endif
    }
    
    @Published internal var items: [Item] = []
    @Published internal var delayEnabled: Bool = true
    @Published internal var delay: String = "10"
    @Published internal var volumeEnabled: Bool = true
    @Published internal var volume: String = "caconym"
    @Published internal var quitWhenDone: Bool = true
    
    let queue = DispatchQueue(label: "com.elegantchaos.delayedstartup.model")
    
    typealias LoadCompletion = () -> Void
    func load(completion: LoadCompletion? = nil) {
        queue.async {
            let decoder = JSONDecoder()
            let defaults = UserDefaults.standard
            self.delayEnabled = defaults.bool(forKey: .delayKey)
            self.delay = defaults.string(forKey: .delayTimeKey) ?? ""
            self.volumeEnabled = defaults.bool(forKey: .checkKey)
            self.volume = defaults.string(forKey: .checkVolumeKey) ?? ""
            self.quitWhenDone = defaults.bool(forKey: .quitWhenDoneKey)
            if let json = UserDefaults.standard.string(forKey: .itemsKey), let data = json.data(using: .utf8) {
                if let items = try? decoder.decode([Item].self, from: data) {
                    self.items = items
                }
            }
            completion?()
        }
    }
    
    typealias SaveCompletion = () -> Void
    func save(completion: SaveCompletion? = nil) {
        queue.async {
            let encoder = JSONEncoder()
            let defaults = UserDefaults.standard
            if let encoded = try? encoder.encode(self.items), let json = String(data: encoded, encoding: .utf8) {
                defaults.set(json, forKey: .itemsKey)
            }
            defaults.set(self.delayEnabled, forKey: .delayKey)
            defaults.set(self.delay, forKey: .delayTimeKey)
            defaults.set(self.volumeEnabled, forKey: .checkKey)
            defaults.set(self.volume, forKey: .checkVolumeKey)
            defaults.set(self.quitWhenDone, forKey: .quitWhenDoneKey)
            completion?()
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
    
    func delete(at offsets: IndexSet) {
        queue.async {
            var identifiers: [UUID] = []
            for index in offsets {
                identifiers.append(self.items[index].identifier)
            }
            self.items.removeAll(where: { identifiers.contains($0.identifier) })
            self.save()
        }
    }
    
    func move(from: IndexSet, to: Int) {
        queue.async {
            self.items.move(fromOffsets: from, toOffset: to)
            self.save()
        }
    }
    
    func firstCheck() {
        checkingChannel.log("First check.")
        if delayEnabled {
            scheduleCheck()
        } else {
            performCheck()
        }
    }

    func scheduleCheck() {
        let seconds = (delayEnabled ? Int(delay) : nil) ?? 10
        checkingChannel.log("Delaying \(seconds) seconds.")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now().advanced(by: .seconds(seconds))) {
            self.performCheck()
        }
    }
    
    func performCheck() {
        if !volumeEnabled || FileManager.default.fileExists(atPath: "/Volumes/\(volume)") {
            checkingChannel.log("Starting applications.")
            performStartup()
        } else {
            checkingChannel.log("Volume \(volume) missing.")
            scheduleCheck()
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

extension String {
    static let delayKey = "Delay"
    static let delayTimeKey = "DelayTime"
    static let checkKey = "Check"
    static let checkVolumeKey = "CheckVolume"
    static let quitWhenDoneKey = "QuitWhenDone"
    static let itemsKey = "Items"

}
