//
//  PlayingStatusView.swift
//  Radioio
//
//  Created by 张洋威 on 2020/7/17.
//

import SwiftUI

fileprivate let viewOpacity: Double = 0.5

struct PlayingStatusView: View {
    @Binding var playingStatus: PlayerControl.PlayerStatus
    var body: some View {
        Group {
            switch playingStatus {
                case .loading:
                    LoadingView()
                case .pause:
                    GeometryReader { geometry in
                        Image(systemName: "pause.circle")
                            .foregroundColor(.white)
                            .font(.system(size: geometry.size.width))
                            .opacity(viewOpacity)
                    }
                    
                case .playing:
                    HistogramView()
            }
        }
    }
}

struct HistogramView: View {
    @State var heightRatios: (CGFloat, CGFloat, CGFloat) = (0.25, 0.5, 0.7)
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .bottom, spacing: 0) {
                Rectangle()
                    .fill(Color.white)
                    .frame(width: geometry.size.width * 0.25, height: geometry.size.height * heightRatios.0)
                Spacer(minLength: .leastNormalMagnitude)
                Rectangle()
                    .fill(Color.white)
                    .frame(width: geometry.size.width * 0.25, height: geometry.size.height * heightRatios.1)
                Spacer(minLength: .leastNormalMagnitude)
                Rectangle()
                    .fill(Color.white)
                    .frame(width: geometry.size.width * 0.25, height: geometry.size.height * heightRatios.2)
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: .leastNormalMagnitude, height: geometry.size.height)
            }
            .opacity(viewOpacity)
            .aspectRatio(1, contentMode: .fit)
            .animation(Animation.easeInOut(duration: 0.55).repeatForever(autoreverses: true))
            .onAppear {
                heightRatios = (0.65, 0.2, 0.35)
            }
        }
    }
}

struct LoadingView: View {
    @State var rotating = false
    
    var lineCount: Int = 6
    
    private func contentWidth(_ geometry: GeometryProxy) -> CGFloat {
        min(geometry.size.width, geometry.size.height)
    }
    
    private func lineWidth(_ geometry: GeometryProxy) -> CGFloat {
        contentWidth(geometry) * 0.2
    }
    
    private func lineHeight(_ geometry: GeometryProxy) -> CGFloat {
        contentWidth(geometry) * 0.333
    }
    
    private func lineOffsetY(_ geometry: GeometryProxy) -> CGFloat {
         0.5 * (lineHeight(geometry)-contentWidth(geometry))
    }
    
    var body: some View {
        GeometryReader { geometry in
            Group {
                ForEach(0..<lineCount) { i in
                    RoundedRectangle(cornerRadius: lineWidth(geometry))
                        .fill(Color.white)
                        .frame(width: lineWidth(geometry), height: lineHeight(geometry))
                        .position(CGPoint(x: contentWidth(geometry) * 0.5, y: contentWidth(geometry) * 0.5))
                        .offset(y: lineOffsetY(geometry))
                        .rotationEffect(.degrees(Double(i) / Double(lineCount)) * 360.0, anchor: .center)
                }
            }
            .opacity(viewOpacity)
            .aspectRatio(1, contentMode: .fit)
            .rotationEffect(.degrees(rotating ? 360 : 0), anchor: .center)
            .animation(Animation.linear(duration: 2.5).repeatForever(autoreverses: false))
            .onAppear {
                rotating = true
            }
            
        }
    }
}

struct PlayingStatusView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            HStack(spacing: 2) {
                PlayingStatusView(playingStatus: Binding.constant(PlayerControl.PlayerStatus.loading))
                    .frame(width: 30, height: 30)
                Text("缓冲中")
            }
            .frame(width: 200, height: 50)
            .background(Color.yellow)
            
            HStack(spacing: 2) {
                PlayingStatusView(playingStatus: Binding.constant(PlayerControl.PlayerStatus.playing))
                    .frame(width: 30, height: 30)
                Text("正在播放")
            }
            .frame(width: 200, height: 50)
            .background(Color.orange)
        }
        
    }
}
