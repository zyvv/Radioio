//
//  TVMainView.swift
//  tvOS
//
//  Created by 张洋威 on 2021/2/23.
//

import SwiftUI

struct TVMainView: View {
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
                .edgesIgnoringSafeArea(.all)
            NavigationView {
                TabView {
                    PlayingView()
                        .tabItem {
                            Text("Playing")
                        }
                    MyRadioView()
                        .tabItem {
                            Text("Recently")
                        }
                    RadioLibraryView(radioGroups: radioViewModel.radioGroupNames(includeFavouriteRadios: false, includeRecentPlayRadios: false), radioViewModel: radioViewModel)
                        .environmentObject(playerControl)
                        .tabItem {
                            Text("Library")
                        }
                }
                .onPlayPauseCommand {
                    playerControl.toggle()
                }
        }
    }
    }
}

private struct PlayingView: View {
    var radio: Radio?
    @EnvironmentObject var playerControl: PlayerControl
    @EnvironmentObject var radioViewModel: RadioViewModel
    @State var favourite = false
    @State var isPlaying: Bool = false
    
    var body: some View {
        VStack {
            Spacer()
            VStack(alignment: .center, spacing: 20) {
                HStack(alignment: .center, spacing: 10) {
                    PlayingStatusView(playingStatus: Binding.constant(playerControl.playerStatus))
                        .frame(width: 50, height: 50)
                    Text(playerControl.playingRadio.name)
                        .font(.system(size: 120))
                        .bold()
                        .multilineTextAlignment(.center)
                }
                if playerControl.playingRadio.desc != nil {
                    Text(playerControl.playingRadio.desc!)
                        .font(.system(size: 50))
                }
            }
            Spacer()
            HStack {
                Button {
                    playerControl.toggle()
//                    radioViewModel.shouldFetchRecentPlayRadio.send(true)
                } label: {
                  Image(systemName: isPlaying ? "pause.circle" : "play.circle")
                    .font(.system(size: 60))
                    .frame(width: 200, height: 100)
                    .background(Color.lightBrown)
                    .cornerRadius(15)
                }
                .buttonStyle(RadioPlainStyle())
                Button {
                    favourite = playerControl.favouriteRadio(radio: playerControl.playingRadio)
                    radioViewModel.shouldFetchFavouriteRadio.send(true)
                } label: {
                  Image(systemName: favourite ? "heart.fill" : "heart")
                    .font(.system(size: 60))
                    .frame(width: 200, height: 100)
                    .background(Color.lightBrown)
                    .cornerRadius(15)
                }
                .buttonStyle(RadioPlainStyle())
            }
            .padding(50)
            Spacer()
        }
        .foregroundColor(.white)
        .onAppear {
            if radio != nil {
                playerControl.play(radio: radio!)
                radioViewModel.shouldFetchRecentPlayRadio.send(true)
            }
        }
        .onReceive(playerControl.$playingRadio) {
            favourite = $0.favourite
        }
        .onReceive(playerControl.$playerStatus) {
            isPlaying = $0 != .pause
            radioViewModel.shouldFetchRecentPlayRadio.send(true)
        }
    }
}

private struct MyRadioView: View {
    @EnvironmentObject var radioViewModel: RadioViewModel
    @EnvironmentObject var playerControl: PlayerControl
    
    @State var showPlaceholder: Bool = true
        
    var body: some View {
        Group {
            if radioViewModel.showMyRadiosPlacehodler {
                Text("No Record.")
                    .font(.title2)
                    .foregroundColor(.white)
            } else {
                RadioLibraryView(radioGroups: radioViewModel.radioGroupNames(includeRegions: false), radioViewModel: radioViewModel)
                        .environmentObject(playerControl)
            }
        }
        .onReceive(radioViewModel.$showMyRadiosPlacehodler) {
            showPlaceholder = $0
        }
    }
}

private struct RadioLibraryView: View {
    var radioGroups: [String]
    @ObservedObject var radioViewModel: RadioViewModel
    @EnvironmentObject var playerControl: PlayerControl

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: true) {
                Spacer(minLength: 8)
                ForEach(radioGroups, id: \.self) { region in
                    let columns = [GridItem(.flexible(minimum: 500, maximum: 600)),
                                   GridItem(.flexible(minimum: 500, maximum: 600)),
                                   GridItem(.flexible(minimum: 500, maximum: 600))]
                    RadioGroupView(radioViewModel: radioViewModel, region: region, columns: columns)
                }
                Spacer(minLength: 15)
            }
        }
    }
}

private struct RadioGroupView: View {
    @ObservedObject var radioViewModel: RadioViewModel
    var region: String
    var columns: [GridItem]
    
    var body: some View {
        if radioViewModel.haveRadio(inRegion: region) {
            LazyVGrid(columns: columns) {
                Section(header:
                            HStack {
                                Text(LocalizedStringKey(region))
                                    .font(.system(.headline))
                                    .bold()
                                    .foregroundColor(.gray)
                                    .padding(.leading)
                                Spacer()
                            }
                ) {
                    ForEach(radioViewModel.radios(inRegion: region)!, id: \.id) { radio in
                        NavigationLink(
                            destination: PlayingView(radio: radio)) {
                            ZStack {
                                Color.darkBrown
                                VStack(spacing: 6) {
                                    Text(radio.name)
                                        .font(.title3)
                                        .bold()
                                    if radio.desc?.count ?? 0 > 0 {
                                        Text(radio.desc!)
                                            .font(.callout)
                                    }
                                }
                                .foregroundColor(.white)
                                
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                            .cornerRadius(20)
                            .padding()
                        }
                        .buttonStyle(RadioPlainStyle())
                    }
                }
            }
            .padding()
        }
    }
}

struct RadioPlainStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        RadioPlainButton(configuration: configuration)
    }
}

struct RadioPlainButton: View {
    @Environment(\.isFocused) var focused: Bool
    let configuration: ButtonStyle.Configuration
  
    var body: some View {
        configuration.label
            .scaleEffect(focused ? 1.1 : 1)
            .brightness(focused ? 0.4 : 0)
            .focusable(true)
            .animation(.easeOut(duration: 0.15))
    }
}

struct TVMainView_Previews: PreviewProvider {
    static var previews: some View {
        TVMainView()
    }
}
