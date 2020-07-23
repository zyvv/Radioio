//
//  PlayingView.swift
//  Shared
//
//  Created by 张洋威 on 2020/7/14.
//

import SwiftUI

struct PlayingView: View {
    var body: some View {

        VStack {
            PlayingPanel()
            RecentPlayView()
            MenuView()
        }
        
    }
}

struct PlayingPanel: View {
    var body: some View {
        GeometryReader(content: { geometry in
            ZStack {
                VStack(spacing: 15) {
                    Text("REO经济之声")
                        .font(Font.system(size: 50))
                    Text("FM25.0")
                        .font(Font.system(size: 25))
                }
                .foregroundColor(.white)
            }
            .frame(width: geometry.size.width, height: geometry.size.height * 0.382)
            .background(LinearGradient(
                gradient: .init(colors: [Self.gradientEnd, Self.gradientStart]),
                startPoint: .init(x: 0.5, y: 1),
                endPoint: .init(x: 0.5, y: 0.5)
            ))
            .edgesIgnoringSafeArea(.top)
        })
        
    }
    
    static let gradientStart = Color(red: 52.0 / 255, green: 43.0 / 255, blue: 46.0 / 255)
    static let gradientEnd = Color(red: 36.0 / 255, green: 30.0 / 255, blue: 32.0 / 255)
}

struct RecentPlayView: View {
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("最近播放")
            List(0..<10) { _ in
                RecentPlayCell()
            }
        }
        .frame(maxHeight: 300)
        .background(Color.yellow)
    }
}

struct RecentPlayCell: View {
    var body: some View {
        VStack(spacing: 6) {
            Text("中央人民广播电台马拉松分台")
                .multilineTextAlignment(.center)
                .font(.system(size: 20))
            Text("FM25.2")
                .font(.system(size: 15))
        }
        .padding(.all, 8)
        .frame(width: 170, height: 94)
        .background(Color.orange)
        .cornerRadius(6)
    }
}

struct MenuView: View {
    
    var body: some View {
        HStack {
            //favourite
            Button(action: {
                
            }) {
                Image(systemName: "heart")
                    .font(.system(size: 70, weight: .light))
                    .foregroundColor(.red)
            }
            Spacer()
            Button(action: {
                print("TAPED OFF")
            }) {
                Text("OFF")
                    .frame(width: 140, height: 70)
                    .font(.system(size: 30, weight: .medium))
                    .foregroundColor(.red)
                    .overlay(
                        RoundedRectangle(cornerRadius: 35)
                            .stroke(Color.red, lineWidth: 4)
                    )
            }
        }
        .frame(maxWidth: 300)
        .padding(.bottom, 50)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PlayingView()
        }
    }
}
