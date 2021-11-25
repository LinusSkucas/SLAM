//
//  IntroViewInstruction.swift
//  SLAM
//
//  Created by Linus Skucas on 11/24/21.
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
//            image
            
            VStack(alignment: .leading) {
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

struct IntroViewInstruction_Previews: PreviewProvider {
    static var previews: some View {
        IntroViewInstruction(title: "Mic Check", description: "Give SLAM mic permissions so we can listen in on your private conversations with Siri. Oh, and listen to music for you.", image: Image(systemName: "music.mic"), nextButtonLabel: "Auth") {
            print("authorize")
        }
    }
}
