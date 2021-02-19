//
//  RadioListView.swift
//  Radioio
//
//  Created by 张洋威 on 2020/7/14.
//

import SwiftUI

struct RadioListView: View {
    @Binding var closeSelf: Bool
    @ObservedObject var radioViewModel: RadioViewModel
    @EnvironmentObject var playerControl: PlayerControl
        
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    PlayingMessageNavigationBar(closeSelf: $closeSelf)
                        .background(Color.darkBrown)
                        .frame(width: geometry.size.width, height: 64)
                    ZStack {
                        Color.background
                            .allowsHitTesting(false)
                            .edgesIgnoringSafeArea(.all)
                        ScrollView(.vertical, showsIndicators: false) {
                            Spacer(minLength: 8)
                            ForEach(radioViewModel.radioGroupNames(), id: \.self) { region in
                                RadioGroup(radioViewModel: radioViewModel, region: region)
                            }
                            Spacer(minLength: 15)
                        }
                        .padding(.horizontal, 8)
                    }
                    .unreachable(Binding.constant(playerControl.unreachable))
                    
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                radioViewModel.shouldFetchRecentPlayRadio.send(true)
            }
            .onDisappear {
                radioViewModel.shouldFetchRecentPlayRadio.send(true)
            }
        }
    }
}

struct PlayingMessageNavigationBar: View {
    @Binding var closeSelf: Bool
    @EnvironmentObject var playerControl: PlayerControl
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                titleView
                HStack {
                    Button(action: {
                        closeSelf.toggle()
                    }, label: {
                        Text("Close")
                            .foregroundColor(.white)
                            .font(.body)
                    })
                    Spacer()
                }
                .padding()
            }
        }
    }
    
    var titleView: some View {
        GeometryReader { geometry in
            VStack {
                Text("Library")
                    .foregroundColor(.white)
                    .bold()
                    .font(.title2)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                Spacer()
                playingMessageView
                Spacer()
            }
        }
    }
    
    var playingMessageView: some View {
        HStack(spacing: 2) {
            Spacer()
            PlayingStatusView(playingStatus: Binding.constant(playerControl.playerStatus))
                .frame(width: 10, height: 10)
            Text(playerControl.playingRadio.name)
                .font(.caption2)
                .foregroundColor(.white)
            Spacer()
        }
        .frame(maxHeight: 10)
    }
}

struct RadioGroup: View {
    @ObservedObject var radioViewModel: RadioViewModel
    let columns = [
            GridItem(.flexible(minimum: 100, maximum: 200)),
            GridItem(.flexible(minimum: 100, maximum: 200))
        ]
    var region: String
    
    var body: some View {
        DisclosureGroup(LocalizedStringKey(region)) {
            if radioViewModel.haveRadio(inRegion: region) {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(radioViewModel.radios(inRegion: region)!, id: \.id) { radio in
                        RadioCell(radio: radio)
                    }
                }.padding(.vertical, 8)
            }
        }
        .foregroundColor(.white)
        .accentColor(.white)
        .font(.body)
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

struct RadioListView_Previews: PreviewProvider {
    static var previews: some View {
        RadioListView(closeSelf: Binding.constant(false), radioViewModel: RadioViewModel())
    }
}
