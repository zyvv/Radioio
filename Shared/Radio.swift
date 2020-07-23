//
//  Radio.swift
//  Radioio
//
//  Created by 张洋威 on 2020/7/20.
//

import CoreData
import Foundation

@objc(Radio)
class Radio: NSManagedObject, Decodable, Identifiable {
    
    @NSManaged var id_: NSNumber?
    @NSManaged var region_: String?
    @NSManaged var regionId_: NSNumber?
    @NSManaged var name_: String?
    @NSManaged var url_: URL?
    @NSManaged var desc: String?
    @NSManaged var source: String?
    @NSManaged var favourite: Bool
    @NSManaged var lastPlayTime: Date?
    @NSManaged var favouriteTime: Date?
    
    enum CodingKeys: String, CodingKey {
        case id_ = "id"
        case region_ = "region"
        case regionId_ = "region_id"
        case name_ = "name"
        case url_ = "url"
        case desc = "desc"
    }

    required convenience init(from decoder: Decoder) throws {
        guard let codingUserInfoKeyManagedObjectContext = CodingUserInfoKey.managedObjectContext else {
            fatalError("Failed to decode Radio 1")
        }
        guard let managedObjectContext = decoder.userInfo[codingUserInfoKeyManagedObjectContext] as? NSManagedObjectContext else {
                fatalError("Failed to decode Radio 2")
            }
        guard  let entity = NSEntityDescription.entity(forEntityName: "Radio", in: managedObjectContext) else {
            fatalError("Failed to decode Radio 3")
        }
        
        self.init(entity: entity, insertInto: managedObjectContext)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id_ = try container.decodeIfPresent(Int.self, forKey: .id_) as NSNumber?
        region_ = try container.decodeIfPresent(String.self, forKey: .region_)
        regionId_ = try container.decodeIfPresent(Int.self, forKey: .regionId_)  as NSNumber?
        name_ = try container.decodeIfPresent(String.self, forKey: .name_)
        url_ = try container.decodeIfPresent(URL.self, forKey: .url_)
        desc = try container.decodeIfPresent(String.self, forKey: .desc)
    }
    
    static func sampleRadio() -> Radio {
        let sampleRadioData =
            """
            {"id":0,
            "region":"测试：国家级",
            "region_id":0,
            "name":"测试数据：CNR中国之声",
            "url":"http://lhttp.qingting.fm/live/386/64k.mp3",
            "desc":"FM106.1"}
            """
            .data(using: .utf8)
        let codingUserInfoKeyManagedObjectContext = CodingUserInfoKey.managedObjectContext!
        let decoder = JSONDecoder()
        decoder.userInfo[codingUserInfoKeyManagedObjectContext] = PersistentContainer.context
        return try! decoder.decode(Radio.self, from: sampleRadioData!)
    }
    
    
}

public extension CodingUserInfoKey {
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")
}

extension Radio {
    var id: Int {
        get { Int(truncating: id_!) }
        set { id_ = NSNumber(value: newValue) }
    }

    var region: String {
        get { region_! }
        set { region_ = newValue }
    }
    
    var regionId: Int {
        get { Int(truncating: regionId_!) }
        set { regionId_ = NSNumber(value: newValue) }
    }

    var name: String {
        get { name_! }
        set { name_ = newValue }
    }

    var url: URL {
        get { url_! }
        set { url_ = newValue }
    }
}
