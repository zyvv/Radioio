//
//  RadioioApp.swift
//  Shared
//
//  Created by 张洋威 on 2020/7/14.
//

import SwiftUI

@main
struct RadioioApp: App {
    
    @Environment(\.scenePhase) private var scenePhase
    
    private var remoteRadioUpdater = RemoteRadioUpdater()
    
    @State var showMainView = false
    
    var body: some Scene {
        WindowGroup {
            if !showMainView {
                UpdatingRemoteRadioView(updater: remoteRadioUpdater)
                    .onReceive(remoteRadioUpdater.$needUpdate) { needUpdate in
                        showMainView = !needUpdate
                    }
            } else {
                PlayingView()
                    .edgesIgnoringSafeArea(.all)
                    .environmentObject(PlayerControl())
                    .environmentObject(RadioViewModel())
                    .environment(\.managedObjectContext, PersistentContainer.context)
            }
            
        }
//        .onChange(of: scenePhase) { newScenePhase in
//            if newScenePhase == .background {
//            }
//        }
    }
}
