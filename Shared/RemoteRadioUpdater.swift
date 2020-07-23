//
//  RemoteRadioUpdater.swift
//  Radioio
//
//  Created by 张洋威 on 2020/7/20.
//

import Foundation
import Combine
import CoreData

class RemoteRadioUpdater: ObservableObject {
    
    private let moc = PersistentContainer.context
    private var dataTaskCancellable: AnyCancellable?
    @Published var needUpdate: Bool = false
    @Published var updateError: URLError?
    
    init() {
        let request = NSFetchRequest<Radio>(entityName: "Radio")
        let radios = (try? moc.fetch(request)) ?? []
        needUpdate = radios.count == 0
        update()
    }
    
    func update() {
        if needUpdate {
            requestRemoteRadioData()
        }
    }
    
    private func requestRemoteRadioData() {
        dataTaskCancellable = URLSession.shared
            .dataTaskPublisher(
                for: URL(string: "https://gitee.com/zyvv/Radioio/raw/master/radio_list.json")!
            )
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [unowned self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.updateError = error
                }
            },
            receiveValue: { [unowned self] (data, response) in
                self.decodeRemoteRadio(data: data)
            })
    }
    
    private func decodeRemoteRadio(data: Data) {
        guard let codingUserInfoKeyManagedObjectContext = CodingUserInfoKey.managedObjectContext else {
            fatalError("Failed to retrieve context")
        }
        let decoder = JSONDecoder()
        decoder.userInfo[codingUserInfoKeyManagedObjectContext] = moc
        do {
            _ = try decoder.decode([Radio].self, from: data)
            try moc.save()
            self.needUpdate = false
        } catch {
            self.updateError = URLError(URLError.Code(rawValue: 1000), userInfo: ["NSLocalizedDescriptionKey": error.localizedDescription])
        }       
    }
}


