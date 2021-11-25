//
//  SongList.swift
//  SLAM
//
//  Created by Linus Skucas on 11/24/21.
//

import SwiftUI

struct SongList: View {
    @Environment(\.managedObjectContext) var viewContext
    @State var s = ["s", "v", "l"]
    
    var body: some View {
        ZStack {
            VisualEffectBackground()
            ScrollView {
                VStack(alignment: .leading) {
                    Button {
                        NotificationCenter.default.post(name: .closeTheMainThing, object: nil)
                    } label: {
                        Image(systemName: "xmark")
                            .symbolVariant(.fill.circle)
                    }
                    .buttonStyle(.borderless)
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

extension String: Identifiable {
    public var id: String {
        self
    }
}

struct SongList_Previews: PreviewProvider {
    static var previews: some View {
        SongList()
    }
}
