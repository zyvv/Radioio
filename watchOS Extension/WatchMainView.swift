//
//  WatchMainView.swift
//  Radioio WatchKit Extension
//
//  Created by 张洋威 on 2021/2/22.
//

import SwiftUI

struct WatchMainView: View {
    @EnvironmentObject var playerControl: PlayerControl
    @EnvironmentObject var radioViewModel: RadioViewModel
    @State var isPlaying: Bool = false
    @State var favourite = false
    
    var body: some View {
        VStack {
            Spacer()
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline) {
                    PlayingStatusView(playingStatus: Binding.constant(playerControl.playerStatus))
                        .frame(width: 12, height: 12)
                    Text(playerControl.playingRadio.name)
                        .font(.title3)
                        .bold()
                        .multilineTextAlignment(.center)
                }
                if playerControl.playingRadio.desc != nil {
                    Text(playerControl.playingRadio.desc!)
                        .font(.caption)
                        .padding(.leading, 16)
                }
            }
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    playerControl.toggle()
                }) {
                    Image(systemName: (isPlaying ? "pause.circle" : "play.circle"))
                        .font(.system(size: 45))
                        .foregroundColor(.white)
                }
                .buttonStyle(PlainButtonStyle())
                Spacer()
                Button(action: {
                    favourite = playerControl.favouriteRadio(radio: playerControl.playingRadio)
                    radioViewModel.shouldFetchFavouriteRadio.send(true)
                }) {
                    Image(systemName: (favourite ? "heart.fill" : "heart"))
                        .font(.system(size: 25))
                        .foregroundColor(.white)
                }
                .buttonStyle(PlainButtonStyle())
                Spacer()
            }
            Spacer()
        }
        .onReceive(playerControl.$playingRadio) {
            favourite = $0.favourite
        }
        .onReceive(playerControl.$playerStatus) {
            isPlaying = $0 != .pause
            if $0 == .playing {
                radioViewModel.shouldFetchRecentPlayRadio.send(true)
            }
        }
    }
}

struct WatchMainView_Previews: PreviewProvider {
    static var previews: some View {
        WatchMainView()
    }
}
