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
        ZStack {
            LinearGradient(
                gradient: .init(colors: [Color.lightBrown, Color.darkBrown, Color.background]),
                startPoint: .init(x: 0.382, y: 0),
                endPoint: .init(x: 0.5, y: 0.5))
                .edgesIgnoringSafeArea(.all)
                .disabled(true)
            VStack {
                Spacer()
                VStack(alignment: .leading, spacing: 2) {
                    Text(playerControl.playingRadio.name)
                        .font(.title3)
                        .bold()
                        .multilineTextAlignment(.center)
                    HStack {
                        if playerControl.playingRadio.desc != nil {
                            Text(playerControl.playingRadio.desc!)
                                .font(.caption)
                        }
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
        }
        .onReceive(playerControl.$playingRadio) {
            favourite = $0.favourite
        }
        .onDisappear {
            radioViewModel.shouldFetchRecentPlayRadio.send(true)
        }
    }
}

struct WatchMainView_Previews: PreviewProvider {
    static var previews: some View {
        WatchMainView()
    }
}
