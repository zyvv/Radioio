//
//  UpdatingRemoteRadioView.swift
//  Radioio
//
//  Created by 张洋威 on 2020/7/20.
//

import SwiftUI

struct UpdatingRemoteRadioView: View {
    @State var retry = false
    @ObservedObject var updater: RemoteRadioUpdater
    
    #if os(watchOS)
    var vSpacing: CGFloat = 10
    #else
    var vSpacing: CGFloat = 30
    #endif
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: .init(colors: [Color.lightBrown, Color.darkBrown, Color.background]),
                startPoint: .init(x: 0.382, y: 0),
                endPoint: .init(x: 0.5, y: 0.5))
                .allowsHitTesting(false)
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: vSpacing) {
                if ((updater.updateError?.localizedDescription) != nil) {
                    Text(updater.updateError!.localizedDescription)
                } else {
                    updater.needUpdate ? Text("Downloading data...").multilineTextAlignment(.center) : Text("").multilineTextAlignment(.center)
                }
                Button(action: {
                    updater.update()
                }, label: {
                    #if os(tvOS)
                    Text("Retry")
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 6)
                    #else
                    Text("Retry")
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 6)
                        .overlay(
                            RoundedRectangle(cornerRadius: .infinity)
                                .strokeBorder(Color.white, lineWidth: 1.0)
                        )

                    #endif
                })
                .buttonStyle(PlainButtonStyle())
                .padding()
                .opacity(retry ? 1 : 0)
                .disabled(retry ? false : true)
                .animation(.easeOut)
            }
            .foregroundColor(Color.white)
            .onReceive(updater.$updateError) {
                if $0 != nil {
                    retry = true
                }
            }
        }
    }
}

struct UpdatingRemoteRadioView_Previews: PreviewProvider {
    static var previews: some View {
        UpdatingRemoteRadioView(updater: RemoteRadioUpdater())
    }
}
