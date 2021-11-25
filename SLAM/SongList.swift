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
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Song.timestamp, ascending: false)], animation: .default) private var songs: FetchedResults<Song>
    
    var body: some View {
        ZStack {
            VisualEffectBackground()
            VStack(alignment: .leading) {
                HStack {
                    Button {
                        window.close()
                    } label: {
                        Image(systemName: "xmark")
                            .symbolVariant(.fill.circle)
                    }
                    .buttonStyle(.borderless)
                    .keyboardShortcut("w", modifiers: .command)
                    .contextMenu {
                        Button(role: .destructive) {
                            NSApp.terminate(nil)
                        } label: {
                            Text("Quit SLAM")
                        }
                    }
                    Spacer()
                }
                .padding(3)
                ScrollView {
                    ForEach(songs) { song in
                        VStack(alignment: .leading) {
                            HStack(alignment: .top) {
                                AsyncImage(url: song.artworkURL) { image in
                                    image
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .aspectRatio(contentMode: .fit)
                                        .cornerRadius(8)
                                } placeholder: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.gray.opacity(0.75))
                                            .frame(width: 50, height: 50)
                                            .redacted(reason: .placeholder)
                                        ProgressView()
                                            .progressViewStyle(.circular)
                                    }
                                }
                                
                                VStack(alignment: .leading) {
                                    Text(song.title ?? "")
                                        .font(.title2)
                                    Text(song.artist ?? "")
                                        .font(.caption)
                                        .textCase(.uppercase)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.horizontal)
                            Divider()
                        }.contextMenu {// TODO: Heard on timestamp, copy name, copy artist name, copy both, divider, then delete
                            Text("Heard on \(song.timestamp!, formatter: itemFormatter)")
                            Button("Copy Name") {
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString(song.title!, forType: .string)
                            }
                            .disabled((song.title == nil))
                            Button("Copy Artist Name") {
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString(song.artist!, forType: .string)
                            }
                            .disabled((song.artist == nil))
                            Button("Copy Artist Name and Song Name") {
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString("\(song.artist!) - \(song.title!)", forType: .string)
                            }
                            .disabled((song.artist == nil) || (song.title == nil))
                            Divider()
                            Button("Delete Song", role: .destructive) {
                                withAnimation {
                                    viewContext.delete(song)
                                    try! viewContext.save()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()
