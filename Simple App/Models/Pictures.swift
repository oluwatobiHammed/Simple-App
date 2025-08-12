//
//  Pictures.swift
//  Simple App
//
//  Created by Oluwatobi Oladipupo on 2025-08-11.
//

class Pictures: Codable {
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


    
    var id                    : String = ""
    var author                : String?
    var width                 : Int = 0
    var height                : Int = 0
    var url                   : String?
    var downloadUrl           : String?
}
