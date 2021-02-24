//
//  RadioTableView.swift
//  Radioio WatchKit Extension
//
//  Created by 张洋威 on 2021/2/22.
//

import SwiftUI

struct WatchMyRadioView: View {
    @EnvironmentObject var radioViewModel: RadioViewModel
    @EnvironmentObject var playerControl: PlayerControl
    
    @State var showPlaceholder: Bool = true
    
    var body: some View {
        Group {
            if radioViewModel.showMyRadiosPlacehodler {
                Text("No Record.")
                    .font(.body)
                    .foregroundColor(.white)
            } else {
                ScrollView(.vertical, showsIndicators: true) {
                    ForEach(radioViewModel.radioGroupNames(includeRegions: false), id: \.self) { region in
                        let columns = [GridItem()]
                        RadioGroupView(radioViewModel: radioViewModel, region: region, columns: columns)
                    }
                }
            }
        }
        .onReceive(radioViewModel.$showMyRadiosPlacehodler) {
            showPlaceholder = $0
        }
    }
}

struct WatchRadioLibraryView: View {
    @EnvironmentObject var radioViewModel: RadioViewModel
    @EnvironmentObject var playerControl: PlayerControl
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            ForEach(radioViewModel.radioGroupNames(includeFavouriteRadios: false, includeRecentPlayRadios: false), id: \.self) { region in
                let columns = [GridItem()]
                RadioGroupView(radioViewModel: radioViewModel, region: region, columns: columns)
            }
        }
        .onReceive(playerControl.$playerStatus) {
            if $0 == .playing {
                radioViewModel.shouldFetchRecentPlayRadio.send(true)
            }
        }
    }
}

private struct RadioGroupView: View {
    @ObservedObject var radioViewModel: RadioViewModel
    @EnvironmentObject var playerControl: PlayerControl
    var region: String
    var columns: [GridItem]
    
    var body: some View {
        if radioViewModel.haveRadio(inRegion: region) {
            LazyVGrid(columns: columns, spacing: 4) {
                Section(header:
                            Text(LocalizedStringKey(region))
                            .font(.system(.caption2))
                            .padding(.top, 6)
                ) {
                    ForEach(radioViewModel.radios(inRegion: region)!, id: \.id) { radio in
                        Button {
                            playerControl.play(radio: radio)
                        } label: {
                            Text(radio.name)
                                .font(.system(.callout))
                        }
                        .padding(.horizontal, 4)
                    }
                }
            }
            .padding(.vertical, 4)
            .foregroundColor(.white)
        }
    }
}


struct RadioTableView_Previews: PreviewProvider {
    static var previews: some View {
        WatchRadioLibraryView()
    }
}
