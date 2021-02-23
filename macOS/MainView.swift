//
//  MainView.swift
//  macOS
//
//  Created by 张洋威 on 2021/2/21.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var playerControl: PlayerControl
    @EnvironmentObject var radioViewModel: RadioViewModel
    @State var isPlaying: Bool = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: .init(colors: [Color.lightBrown, Color.darkBrown, Color.background]),
                startPoint: .init(x: 0.382, y: 0),
                endPoint: .init(x: 0.5, y: 0.5))
                .disabled(true)
            VStack {
                PlayingPanel()
                    .background(Color.background)
                    .frame(height: 100)                        
                    RadioLibraryView(radioViewModel: radioViewModel)
                        .unreachable(Binding.constant(playerControl.unreachable))
                        .environmentObject(playerControl)
            }
        }
    }
}

private struct PlayingPanel: View {
    @EnvironmentObject var playerControl: PlayerControl
    @EnvironmentObject var radioViewModel: RadioViewModel
    @State var favourite = false
    @State var isPlaying: Bool = false
    
    var body: some View {
        HStack {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                PlayingStatusView(playingStatus: Binding.constant(playerControl.playerStatus))
                    .frame(width: 15, height: 15)
                VStack(alignment: .leading, spacing: 5) {
                    Text(playerControl.playingRadio.name)
                        .font(.system(size: 40))
                        .bold()
                        .multilineTextAlignment(.leading)
                    HStack {
                        if playerControl.playingRadio.desc != nil {
                            Text(playerControl.playingRadio.desc!)
                                .font(.headline)
                        }
//                        Spacer()
                        Button(action: {
                            favourite = playerControl.favouriteRadio(radio: playerControl.playingRadio)
                            radioViewModel.shouldFetchFavouriteRadio.send(true)
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
                    }
                }
            }
            .padding()
            .foregroundColor(.white)
            Spacer()
            Button(action: {
                playerControl.toggle()
            }) {
                Image(systemName: (isPlaying ? "pause.circle" : "play.circle"))
                    .font(.system(size: 60))
                    .foregroundColor(.white)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.trailing, 30)
        }
        .onReceive(playerControl.$playingRadio) {
            favourite = $0.favourite
        }
        .onReceive(playerControl.$playerStatus) {
            isPlaying = $0 != .pause
        }
    }
}

private struct RadioGroupView: View {
    @ObservedObject var radioViewModel: RadioViewModel
    var region: String
    var columns: [GridItem]
    
    var body: some View {
        if radioViewModel.haveRadio(inRegion: region) {
            LazyVGrid(columns: columns, spacing: 8) {
                Section(header:
                            ZStack {
                                Color.lightBrown
                                Text(LocalizedStringKey(region))
                                    .font(.system(.callout))
                                    .foregroundColor(.gray)
                            }
                            .frame(width: 610, height: 25, alignment: .center)
                            .cornerRadius(6)
                ) {
                    ForEach(radioViewModel.radios(inRegion: region)!, id: \.id) { radio in
                        RadioCell(radio: radio)
                    }
                }
            }
            .padding(.vertical, 8)
            .foregroundColor(.white)
            .accentColor(.white)
            .font(.body)
        }
    }
}

private struct RadioLibraryView: View {
    @ObservedObject var radioViewModel: RadioViewModel
    @EnvironmentObject var playerControl: PlayerControl

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: true) {
                Spacer(minLength: 8)
                ForEach(radioViewModel.radioGroupNames(), id: \.self) { region in
                    let columns = [GridItem(.flexible(minimum: 100, maximum: 200)),
                                   GridItem(.flexible(minimum: 100, maximum: 200)),
                                   GridItem(.flexible(minimum: 100, maximum: 200))]
                    RadioGroupView(radioViewModel: radioViewModel, region: region, columns: columns)
                }
                Spacer(minLength: 15)
            }
            .padding(.horizontal, 8)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(PlayerControl.shared)
            .environmentObject(RadioViewModel())
            .environment(\.managedObjectContext, PersistentContainer.context)
            .frame(minWidth: 600, minHeight: 400)
    }
}
