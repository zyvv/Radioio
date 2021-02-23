//
//  RadioViewModel.swift
//  Radioio
//
//  Created by 张洋威 on 2020/7/15.
//

import SwiftUI
import Combine
import CoreData

class RadioViewModel: ObservableObject {
    
    #if os(watchOS)
    static let `shared`: RadioViewModel = RadioViewModel()
    #endif
    
    private let context: NSManagedObjectContext = PersistentContainer.context
    private let favouritGroupName = "Recently Added"
    private let recentPlayGroupName = "Recently Played"
    
    private var radios: [Radio]
    private var regions: [String]
    private var regionRadios: [String: [Radio]]
    
    @Published var favouriteRadios: [Radio] = []
    
    @Published var recentPlayRadios: [Radio] = []
        
    let shouldFetchRecentPlayRadio = CurrentValueSubject<Bool, Never>(false)
    private var shouldFetchRecentPlayRadioCancellable: AnyCancellable?
    
    let shouldFetchFavouriteRadio = CurrentValueSubject<Bool, Never>(false)
    private var shouldFetchFavouriteRadioCancellable: AnyCancellable?
        
    init() {
        radios = RadioViewModel.getAllRaios()
        regions = radios
            .map { $0.region }
            .removingDuplicates()
        regionRadios = radios.reduce([String: [Radio]]()) {
            var radiosDict = $0
            var radiosArray = radiosDict.keys.contains($1.region) ? radiosDict[$1.region]! : []
            radiosArray.append($1)
            radiosDict.updateValue(radiosArray, forKey: $1.region)
            return radiosDict
        }
        shouldFetchRecentPlayRadio.send(true)
        shouldFetchRecentPlayRadioCancellable = shouldFetchRecentPlayRadio.sink { [unowned self] in
            if $0 == true {
                self.recentPlayRadios = self.getRecentPlayRadios()
            }
        }
        shouldFetchFavouriteRadio.send(true)
        shouldFetchFavouriteRadioCancellable = shouldFetchFavouriteRadio.sink { [unowned self] in
            if $0 == true {
                self.favouriteRadios = self.getFavouriteRadios()
            }
        }
    }
    
    func radios(inRegion region: String) -> [Radio]? {
        regionRadios[region]
    }
    
    func haveRadio(inRegion region: String) -> Bool {
        if regionRadios.keys.contains(region) {
            return regionRadios[region]!.count > 0
        }
        return false
    }
    
    func radioGroupNames(includeRecentPlayRadios: Bool = true) -> [String] {
        var groupNames = regions
        let favouriteRadios = getFavouriteRadios()
        if favouriteRadios.count > 0 {
            groupNames.insert(favouritGroupName, at: 0)
            regionRadios[favouritGroupName] = favouriteRadios
        }
        #if !os(macOS)
        if recentPlayRadios.count > 0 && includeRecentPlayRadios {
            groupNames.insert(recentPlayGroupName, at: 0)
            regionRadios[recentPlayGroupName] = recentPlayRadios
        }
        #endif
        return groupNames
    }
    
    static func getRecentPlayRadio() -> Radio {
        let request = NSFetchRequest<Radio>.init(entityName: "Radio")
        request.predicate = NSPredicate(format: "lastPlayTime < %@", Date() as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "lastPlayTime", ascending: false)]
        request.fetchLimit = 1
        if let radios = try? PersistentContainer.context.fetch(request),
           let radio = radios.first {
            return radio
        }
        return RadioViewModel.getFirstRadio()
    }
    
    static func getRadioOnDisk(radio: Radio) -> Radio {
        let request = NSFetchRequest<Radio>.init(entityName: "Radio")
        request.predicate = NSPredicate(format: "id_ = \(radio.id)")
        request.fetchLimit = 1
        if let radios = try? PersistentContainer.context.fetch(request),
           let r = radios.first {
            return r
        }
        return radio
    }
    
    // fetch recently play radios for widget
    static func getRecentlyPlayRadios() -> [Radio] {
        let request = NSFetchRequest<Radio>.init(entityName: "Radio")
        request.predicate = NSPredicate(format: "lastPlayTime < %@", Date() as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "lastPlayTime", ascending: false)]
        request.fetchLimit = 4
        return (try? PersistentContainer.context.fetch(request)) ?? []
    }
    
    private func getRecentPlayRadios() -> [Radio] {
        let request = NSFetchRequest<Radio>.init(entityName: "Radio")
        request.predicate = NSPredicate(format: "lastPlayTime < %@", Date() as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "lastPlayTime", ascending: false)]
        request.fetchLimit = 10
        return (try? context.fetch(request)) ?? []
    }
    
    private func getFavouriteRadios() -> [Radio] {
        let request = NSFetchRequest<Radio>.init(entityName: "Radio")
        request.predicate = NSPredicate(format: "favourite == %@", NSNumber(value: true))
        request.sortDescriptors = [NSSortDescriptor(key: "favouriteTime", ascending: false)]
        return (try? context.fetch(request)) ?? []
    }
    
    private static func getAllRaios() -> [Radio] {
        let request = NSFetchRequest<Radio>.init(entityName: "Radio")
        request.sortDescriptors = [NSSortDescriptor(key: "id_", ascending: true)]
        return (try? PersistentContainer.context.fetch(request)) ?? []
    }
    
    private static func getFirstRadio() -> Radio {
        let request = NSFetchRequest<Radio>.init(entityName: "Radio")
        request.sortDescriptors = [NSSortDescriptor(key: "id_", ascending: true)]
        request.fetchLimit = 1
        return (try! PersistentContainer.context.fetch(request)).first!
    }
    
}


