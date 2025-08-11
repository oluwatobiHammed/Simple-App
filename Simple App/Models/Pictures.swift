//
//  Pictures.swift
//  Simple App
//
//  Created by Oluwatobi Oladipupo on 2025-08-11.
//
import RealmSwift
import Realm

@objcMembers
class Pictures: Object, Decodable {
    private enum CodingKeys: String, CodingKey {
        case id,  author, width, height, url, downloadUrl = "download_url"
    }

    public required convenience init(from decoder: Decoder) throws {
        self.init()

        let container               = try decoder.container(keyedBy: CodingKeys.self)
        self.id                     = try container.decode(String.self, forKey: .id)
        self.author                 = try container.decodeIfPresent(String.self, forKey: .author)
        self.width                  = try container.decode(Int.self, forKey: .width)
        self.height                 = try container.decode(Int.self, forKey: .height)
        self.url                    = try container.decodeIfPresent(String.self, forKey: .url)
        self.downloadUrl                 = try container.decodeIfPresent(String.self, forKey: .downloadUrl)
    }

    override class func primaryKey() -> String? {
        return "id"
    }
    
    dynamic var id                    : String = ""
    dynamic var author                : String?
    dynamic var width                 : Int = 0
    dynamic var height                : Int = 0
    dynamic var url                   : String?
    dynamic var downloadUrl           : String?
}
