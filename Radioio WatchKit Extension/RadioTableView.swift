//
//  RadioTableView.swift
//  Radioio WatchKit Extension
//
//  Created by 张洋威 on 2021/2/22.
//

import SwiftUI

struct RadioTableView: View {
    @EnvironmentObject var radioViewModel: RadioViewModel
    @EnvironmentObject var playerControl: PlayerControl
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            ForEach(radioViewModel.radioGroupNames(), id: \.self) { region in
                if radioViewModel.haveRadio(inRegion: region) {
                    Section(header:
                                Text(LocalizedStringKey(region))
                                .font(.system(.caption2))
                                .padding(.top, 6)
                    ) {
                        ForEach(radioViewModel.radios(inRegion: region)!) { radio in
                            Button {
                                playerControl.play(radio: radio)
                            } label: {
                                Text(radio.name)
                                    .font(.system(.callout))
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 2)
                        }
                    }
                }
            }
        }

    }
}

struct RadioTableView_Previews: PreviewProvider {
    static var previews: some View {
        RadioTableView()
    }
}
