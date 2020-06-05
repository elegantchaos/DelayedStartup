//
//  AppDelegate.swift
//  DelayedStartupCatalyst
//
//  Created by Sam Deane on 05/06/2020.
//  Copyright © 2020 Elegant Chaos. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    static var shared: AppDelegate { UIApplication.shared.delegate as! AppDelegate }

    let model = Model()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        model.load()
        
        if !UserDefaults.standard.bool(forKey: "DontCheckOnStartup") {
            scheduleCheck()
        }

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
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
        
}


class MobileFilePicker: UIDocumentPickerViewController {
    typealias Completion = ([URL]) -> Void
    
    let cleanupURLS: [URL]
    let completion: Completion?

    required init(forOpeningDocumentTypes types: [String], startingIn startURL: URL? = nil, completion: Completion? = nil) {
        self.cleanupURLS = []
        self.completion = completion
        super.init(documentTypes: types, in: .open)
        setup(startURL: startURL)
    }
    
    func setup(startURL: URL?) {
        if let url = startURL {
            directoryURL = url
        }
        delegate = self
        modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func cleanup() {
        for url in cleanupURLS {
            try? FileManager.default.removeItem(at: url)
        }
    }
}


extension MobileFilePicker: UIDocumentPickerDelegate {
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        completion?([])
        cleanup()
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        completion?(urls)
        cleanup()
    }
}
