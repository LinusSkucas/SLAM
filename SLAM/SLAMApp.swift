//
//  SLAMApp.swift
//  SLAM
//
//  Created by Linus Skucas on 11/19/21.
//

import SwiftUI
import ShazamKit
import AVFoundation

enum MusicStatus: String {
    case ready = "music.note"
    case listening = "gearshape.2"
    case found = "ear"
    case error = "questionmark.square.dashed"
}

// Thanks: https://www.jessesquires.com/blog/2019/08/15/implementing-right-click-for-nsbutton/
extension NSEvent {
    var isRightClick: Bool {
        let rightClick = (self.type == .rightMouseDown)
        let controlClick = self.modifierFlags.contains(.control)
        return rightClick || controlClick
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, SHSessionDelegate {
    
    var statusBarItem: NSStatusItem!
    var introWindow: NSWindow?
    var mainWindow: NSWindow!
    var openedWindowCount = 0
    
    let session = SHSession()
    let audioEngine = AVAudioEngine()
    let signatureGenerator = SHSignatureGenerator()

    
    func applicationDidFinishLaunching(_ notification: Notification) {
        session.delegate = self
        
        statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.squareLength))
        if let button = statusBarItem.button {
            button.image = NSImage(systemSymbolName: MusicStatus.ready.rawValue, accessibilityDescription: "Music note")
            button.action = #selector(startSlamIt(_:))
            button.sendAction(on: [.leftMouseDown, .rightMouseDown])
        }
        
        guard !UserDefaults.standard.bool(forKey: "seenIntro") else { return }  // TODO: also check for mic permissions
        introWindow = SLAMWindow(contentRect: NSRect(x: 0, y: 0, width: 300, height: 200),
                                 styleMask: [],
                                 backing: .buffered, defer: false)
        guard let introWindow = introWindow else { return }
        
        introWindow.backgroundColor = .clear
        introWindow.isMovableByWindowBackground = true
        introWindow.animationBehavior = .alertPanel
        introWindow.setFrameAutosaveName("Introduction Window")
        introWindow.contentView = NSHostingView(rootView: IntroView())
        introWindow.level = .floating  // lol
        introWindow.center()
        introWindow.makeKeyAndOrderFront(nil)
        introWindow.makeFirstResponder(nil)
        NotificationCenter.default.addObserver(self, selector: #selector(closeIntroWindow(_:)), name: .closeTheThing, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(closeMainWindow(_:)), name: .closeTheMainThing, object: nil)
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        NotificationCenter.default.removeObserver(self, name: .closeTheThing, object: nil)
        NotificationCenter.default.removeObserver(self, name: .closeTheMainThing, object: nil)
    }
    
    
    @objc func startSlamIt(_ sender: NSStatusBarButton) {
        if let event = NSApp.currentEvent,
            event.isRightClick {
             createMainWindow()
         } else {
             DispatchQueue.main.async {
                 self.statusBarItem.button?.image = NSImage(systemSymbolName: MusicStatus.listening.rawValue, accessibilityDescription: "gears")
             }
             toggleMic()
         }
    }
    
    func createMainWindow() {
//        guard mainWindow == nil else {
//            return
//        }
        mainWindow = SLAMWindow(contentRect: NSRect(x: 0, y: 0, width: 300, height: 500),
                                styleMask: [.closable],
                                backing: .buffered, defer: false)
        guard let mainWindow = mainWindow else { return }
        mainWindow.isReleasedWhenClosed = false
        mainWindow.backgroundColor = .clear
        mainWindow.isMovableByWindowBackground = true
        mainWindow.animationBehavior = .documentWindow
        mainWindow.setFrameAutosaveName("Main Window")
        mainWindow.contentView = NSHostingView(rootView: SongList(window: mainWindow).environment(\.managedObjectContext, PersistenceController.shared.container.viewContext))
        mainWindow.level = .floating  // lol
        mainWindow.center()
        mainWindow.makeKeyAndOrderFront(nil)
        mainWindow.makeFirstResponder(nil)
    }
    
    func session(_ session: SHSession, didFind match: SHMatch) {
        print("match")
        guard let matchItem = match.mediaItems.first else {
            statusBarItem.button?.image = NSImage(systemSymbolName: MusicStatus.error.rawValue, accessibilityDescription: "Error")
            self.returnToNormalIcon()
            return
        }

        let newItem = Song(context: PersistenceController.shared.container.viewContext)
        newItem.title = matchItem.title ?? ""
        newItem.artist = matchItem.artist ?? ""
        newItem.artworkURL = matchItem.artworkURL
        newItem.appleMusicID = matchItem.appleMusicID ?? ""
        newItem.timestamp = Date()
        try! PersistenceController.shared.container.viewContext.save()
        toggleMic()
        DispatchQueue.main.async {
            self.statusBarItem.button?.image = NSImage(systemSymbolName: MusicStatus.found.rawValue, accessibilityDescription: "Ear")
            self.returnToNormalIcon()
        }
    }
    
    func toggleMic() {
        guard !audioEngine.isRunning else {
            audioEngine.stop()
            return
        }
        
        let input = audioEngine.inputNode
        let bus = 0
        input.removeTap(onBus: bus)

        let inputFormat = input.inputFormat(forBus: bus)
        
        input.installTap(onBus: bus, bufferSize: 1024, format: inputFormat) { buffer, time in
            self.session.matchStreamingBuffer(buffer, at: time)
        }
        
        audioEngine.prepare()
        try! audioEngine.start()
    }
    
    func returnToNormalIcon() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.statusBarItem.button?.image = NSImage(systemSymbolName: MusicStatus.ready.rawValue, accessibilityDescription: "Error")
        }
    }
    
    func session(_ session: SHSession, didNotFindMatchFor signature: SHSignature, error: Error?) {
        print("error")
        print(error?.localizedDescription)
        DispatchQueue.main.async {
            self.statusBarItem.button?.image = NSImage(systemSymbolName: MusicStatus.error.rawValue, accessibilityDescription: "Error")
            self.returnToNormalIcon()
        }

        toggleMic()
    }
    
    @objc func closeIntroWindow(_ notification: Notification) {
        introWindow?.close()
    }
    
    @objc func closeMainWindow(_ notification: Notification) {
        mainWindow?.close()
        openedWindowCount += 1
        
        if openedWindowCount >= 10 {  // lol
            let task = Process()
            var args = [String]()
            args.append("-c")
            let bundle = Bundle.main.bundlePath
            args.append("sleep 0.2; open \"\(bundle)\"")
            task.launchPath = "/bin/sh"
            task.arguments = args
            task.launch()
            NSApplication.shared.terminate(nil)
        }
    }
}

/// lol not sorry
class SLAMWindow: NSWindow {
    override var canBecomeKey: Bool {
        true
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
