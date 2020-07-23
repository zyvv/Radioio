//
//  ReachabilityStore.swift
//  Radioio
//
//  Created by 张洋威 on 2020/7/19.
//

import Foundation
import Combine
import Reachability

class ReachabilityStore: ObservableObject {
    private var reachability: Reachability

    @Published var reachable: Bool = true

    init() {
        reachability = try! Reachability()
        
        reachability.whenReachable = { [weak self] reachability in
            guard let self = self else { return }
            self.reachable = true
        }

        reachability.whenUnreachable = { [weak self] _ in
            guard let self = self else { return }
            self.reachable = false
        }

        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start reachability notifier.")
        }
    }
}
