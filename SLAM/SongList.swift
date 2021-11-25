//
//  SongList.swift
//  SLAM
//
//  Created by Linus Skucas on 11/24/21.
//

import SwiftUI

struct SongList: View {
    @Environment(\.managedObjectContext) var viewContext
    var window: NSWindow  // this should be in the environment
    @State var s = ["s", "v", "l"]
    
    var body: some View {
        ZStack {
            VisualEffectBackground()
            ScrollView {
                VStack(alignment: .leading) {
                    Button {
//                        NotificationCenter.default.post(name: .closeTheMainThing, object: nil)
                        window.close()
                    } label: {
                        Image(systemName: "xmark")
                            .symbolVariant(.fill.circle)
                    }
                    .buttonStyle(.borderless)
                    .keyboardShortcut("w", modifiers: .command)
                    .contextMenu {
                        Button {
                            NSApp.terminate(nil)
                        } label: {
                            Text("Quit SLAM")
                        }
                    }
                    .padding(3)

                    ForEach(s) { t in
                        VStack {
                            Text(t)
                            Divider()
                        }
                    }
                }
            }
        }
    }
}
