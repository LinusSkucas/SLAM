//
//  Song+CoreDataProperties.swift
//  SLAM
//
//  Created by Linus Skucas on 11/24/21.
//
//

import Foundation
import CoreData


extension Song {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Song> {
        return NSFetchRequest<Song>(entityName: "Song")
    }

    @NSManaged public var title: String?
    @NSManaged public var artist: String?
    @NSManaged public var artworkURL: URL?
    @NSManaged public var appleMusicID: String?

}

extension Song : Identifiable {

}
