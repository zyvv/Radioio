//
//  PlayingView.swift
//  Radioio
//
//  Created by 张洋威 on 2020/7/14.
//

import SwiftUI

struct PlayingView: View {
    @EnvironmentObject var playerControl: PlayerControl
    @State var isPlaying: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(
                    gradient: .init(colors: [Color.lightBrown, Color.darkBrown, Color.background]),
                    startPoint: .init(x: 0.382, y: 0),
                    endPoint: .init(x: 0.5, y: 0.5))
                    .disabled(true)
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        PlayingPanel()
                            .frame(width: geometry.size.width, height: geometry.size.height * 0.382)
                        VStack(spacing: 0) {
                            RecentPlayView()
                                .unreachable(Binding.constant(playerControl.unreachable))
                            Spacer()
                            Button(action: {
                                playerControl.toggle()
                            }) {
                                Image(systemName: (isPlaying ? "pause.circle" : "play.circle"))
                                    .font(.system(size: 80))
                                    .foregroundColor(.white)
                            }
                            .buttonStyle(PlainButtonStyle())
                            Spacer()
                        }
                        .frame(minHeight: geometry.size.height * 0.618)
                    }
                }
            }
        }
//        .statusBar(hidden: true)
        .onReceive(playerControl.$playerStatus) {
            isPlaying = $0 != .pause
        }
    }
}

private struct PlayingPanel: View {
    @EnvironmentObject var playerControl: PlayerControl
    @State var favourite = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 15) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    PlayingStatusView(playingStatus: Binding.constant(playerControl.playerStatus))
                        .frame(width: 15, height: 15)
                    Text(playerControl.playingRadio.name)
                        .font(.title)
                        .bold()
                        .multilineTextAlignment(.center)
                }                    
                if playerControl.playingRadio.desc != nil {
                    Text(playerControl.playingRadio.desc!)
                        .font(.headline)
                }
                
            }
            .padding()
            .foregroundColor(.white)
            
            HStack {
                Spacer()
                VStack {
                    Spacer()
                    Button(action: {
                       favourite = playerControl.favouriteRadio(radio: playerControl.playingRadio)
                    }) {
                        Text((favourite ? "Added": "Add"))
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 6)
                            .overlay(
                                Group {
                                    if favourite {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: .infinity)
                                                .fill(Color.white)
                                            Text("Added")
                                                .font(.subheadline)
                                                .foregroundColor(.darkBrown)
                                        }
                                    } else {
                                        RoundedRectangle(cornerRadius: .infinity)
                                            .strokeBorder(Color.white, lineWidth: 1.0)
                                    }
                                }
                            )
                            
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding()
                }
                
            }
        }.onReceive(playerControl.$playingRadio) { playingRadio in
            favourite = playingRadio.favourite
        }
    }
    
}

private struct RecentPlayView: View {
    @State var showRadioListView = false
    @State var recentPlayRadios = [Radio]()
    @EnvironmentObject var playerControl: PlayerControl
    @EnvironmentObject var radioViewModel: RadioViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Recently Played")
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(.leading, 8)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    allRadiosCell
                        .onTapGesture {
                            self.showRadioListView.toggle()
                        }
                        .sheet(isPresented: $showRadioListView) {
                            RadioListView(closeSelf: $showRadioListView, radioViewModel: radioViewModel)
                                .environmentObject(playerControl)
                        }
                    ForEach(recentPlayRadios, id: \.id) {
                        RadioCell(radio: $0)
                            .frame(width: 150)
                    }
                }
                .padding(.horizontal, 8)
            }
        }
        .padding(.vertical, 8)
        .onReceive(radioViewModel.$recentPlayRadios) {
            recentPlayRadios = $0
        }
    }
    
    var allRadiosCell: some View {
        VStack(spacing: 4) {
            Image(systemName: "radio")
                .font(.system(size: 35))
            Text("Library")
                .font(.subheadline)
        }
        .foregroundColor(.white)
        .frame(width: 100, height: 80)
        .background(Color.darkBrown)
        .cornerRadius(6)
    }
}

struct PlayingView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PlayingView()
        }
    }
}
