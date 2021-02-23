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
                #if os(iOS)
                PlayingView()
                    .edgesIgnoringSafeArea(.all)
                    .environmentObject(PlayerControl.shared)
                    .environmentObject(RadioViewModel())
                    .environment(\.managedObjectContext, PersistentContainer.context)
                #elseif os(macOS)
                MainView()
                    .environmentObject(PlayerControl.shared)
                    .environmentObject(RadioViewModel())
                    .environment(\.managedObjectContext, PersistentContainer.context)
                    .frame(minWidth: 670, minHeight: 400)
                #elseif os(watchOS)
                TabView {
                    WatchMainView()
                        .environmentObject(PlayerControl.shared)
                        .environmentObject(RadioViewModel.shared)
                        .environment(\.managedObjectContext, PersistentContainer.context)
                    NavigationView {
                        RadioTableView()
                            .navigationTitle(Text("Library"))
                            .environmentObject(PlayerControl.shared)
                            .environmentObject(RadioViewModel.shared)
                            .environment(\.managedObjectContext, PersistentContainer.context)
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                #endif
                
            }
        }
        

//        .onChange(of: scenePhase) { newScenePhase in
//            if newScenePhase == .background {
//            }
//        }
    }
}
