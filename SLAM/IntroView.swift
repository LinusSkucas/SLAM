//
//  IntroView.swift
//  SLAM
//
//  Created by Linus Skucas on 11/20/21.
//

import SwiftUI
import AVFoundation
import LaunchAtLogin

struct IntroView: View {
    @State private var step: IntroStep = .welcome
    @Namespace private var namespace
    
    var body: some View {
        ZStack {
            VisualEffectBackground()
            switch step {  // TODO: Nice animation things
            case .welcome:
                IntroViewInstruction(title: "SLAM", description: "Shazam, out of your way.", image: Image(nsImage: NSApplication.shared.applicationIconImage), nextButtonLabel: "Continue...") {
                    step = .mic
                }
            case .mic:
                IntroViewInstruction(title: "Mic Check", description: "Give SLAM mic permissions so we can listen in on your private conversations with Siri. Oh, and listen to music for you.\n(Don't think of think of this as signing your rights away; just think of it as an extension to the irreversable contracts you've already signed agreeing to the same thing)", image: Image(systemName: "music.mic"), nextButtonLabel: "Authorize...") {
                    print("authorize")
                    AVCaptureDevice.requestAccess(for: .audio) { granted in
                        guard granted else { fatalError("Did not agree") }
                        step = .instructions
                        LaunchAtLogin.isEnabled = true
                    }
                }
                .padding()
            case .instructions:
                IntroViewInstruction(title: "What?", description: "Use the menu bar icon.\nClick to shazam.\nRight click to see history and preferences.", image: Image(systemName: "music.note.list"), nextButtonLabel: "Done!") {
                    NotificationCenter.default.post(name: .closeTheThing, object: nil)
                    #if !DEBUG
                    UserDefaults.standard.set(true, forKey: "seenIntro")
                    #endif
                }
            }
        }
    }
}

extension Notification.Name {
    static let closeTheThing = Notification.Name("closeTheThing")
    static let closeTheMainThing = Notification.Name("closeTheMainThing")
}


struct IntroView_Previews: PreviewProvider {
    static var previews: some View {
        IntroView()
    }
}

struct VisualEffectBackground: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.material = .hudWindow
        visualEffectView.state = .active
        visualEffectView.wantsLayer = true
        visualEffectView.layer?.cornerRadius = 16.0
        return visualEffectView
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
    
    typealias NSViewType = NSVisualEffectView
}
