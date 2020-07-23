//
//  RadioCell.swift
//  Radioio
//
//  Created by 张洋威 on 2020/7/15.
//

import SwiftUI

struct RadioCell: View {
    
    @EnvironmentObject var playerControl: PlayerControl
//    @State var playingStatus: PlayerControl.PlayerStatus = PlayerControl.PlayerStatus.pause

    var radio: Radio
    
    var body: some View {
        ZStack {
            VStack(spacing: 6) {
                Text(radio.name)
                    .font(.body)
                    .bold()
                    .multilineTextAlignment(.center)
                if radio.desc?.count ?? 0 > 0 {
                    Text(radio.desc!)
                        .font(.footnote)
                }
            }
            .foregroundColor(.white)
//            PlayingStatusView(playingStatus: $playingStatus)
        }
        
        .padding(.vertical, 6)
        .padding(.horizontal, 15)
        .frame(height: 80)
        .frame(maxWidth: .infinity)
        .background(Color.darkBrown)
        .cornerRadius(6)
        .animation(.easeIn(duration: 0.1))
        .onTapGesture {
            playerControl.play(radio: radio)
        }
//        .onReceive(playerControl.$playerStatus) { _ in
//            playingStatus = playerControl.radioStatus(radio: radio)
//        }
    }
    
    
}

struct RadioCell_Previews: PreviewProvider {
    static var previews: some View {
        RadioCell(radio: Radio.sampleRadio())
    }
}
