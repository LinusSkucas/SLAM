//
//  SLAMApp.swift
//  SLAM
//
//  Created by Linus Skucas on 11/19/21.
//

import SwiftUI
import SpriteKit

class AppDelegate: NSObject, NSApplicationDelegate {
    
    var statusBarItem: NSStatusItem!
    var introWindow: NSWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.squareLength))
        if let button = statusBarItem.button {
            button.title = "🍗"
            button.action = #selector(startSlamIt(_:))
        }
        
        guard !UserDefaults.standard.bool(forKey: "seenIntro") else { return }  // TODO: also check for mic permissions
        introWindow = SLAMWindow(contentRect: NSRect(x: 0, y: 0, width: 480, height: 200),
                                 styleMask: [],
                                 backing: .buffered, defer: false)
        guard let introWindow = introWindow else { return }
        
        introWindow.backgroundColor = .clear
        introWindow.isMovableByWindowBackground = true
        introWindow.animationBehavior = .alertPanel
        introWindow.setFrameAutosaveName("Introduction Window")
        introWindow.contentView = NSHostingView(rootView: IntroView())
        introWindow.level = .dock  // lol
        introWindow.center()
        introWindow.makeKeyAndOrderFront(nil)
        introWindow.makeFirstResponder(nil)
    }
    
    func applicationWillTerminate(_ notification: Notification) {
    }
    
    
    @objc func startSlamIt(_ sender: NSStatusBarButton) {
        
    }
}


@main
struct SLAMApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
