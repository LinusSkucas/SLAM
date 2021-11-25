//
//  IntroView.swift
//  SLAM
//
//  Created by Linus Skucas on 11/20/21.
//

import SwiftUI

enum IntroStep {
    case welcome
    case mic
    case instructions
}

struct IntroViewInstruction: View {
    var title: String
    var description: String
    var image: Image
    var nextButtonLabel: String
    var nextButtonAction: (() -> Void)
    
    var body: some View {
        HStack {
            image
            VStack {
                Text(title)
                    .font(.title)
                Text(description)
                    .font(.caption)
                Button(action: nextButtonAction) {
                    Text(nextButtonLabel)
                }
            }
        }
    }
}

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
                IntroViewInstruction(title: "Mic Check", description: "Give SLAM mic permissions so we can listen in on your private conversations with Siri. Oh, and listen to music for you.", image: Image(systemName: "music.mic"), nextButtonLabel: "Auth") {
                    print("authorize")
                    step = .instructions
                }
            case .instructions:
                IntroViewInstruction(title: "What?", description: "Use the menu bar icon.\n1 click to shazam.\n2 clicks to see history and preferences.", image: Image(systemName: "music.note.list"), nextButtonLabel: "Done!") {
//                    UserDefaults.standard.set(true, forKey: "seenIntro")
                }
            }
        }
    }
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
