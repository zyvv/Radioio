//
//  OnoffButton.swift
//  Radioio
//
//  Created by 张洋威 on 2020/7/22.
//

import SwiftUI

// TODO: - 开关按钮
struct OnoffButton: View {
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                Text("ON")
                Text("OFF")
                    .rotationEffect(.degrees(-45), anchor: .center)
                Circle()
                    .fill(Color.yellow)
                    .overlay (
                        RoundedRectangle(cornerRadius: lineSize(geometry).width * 0.25)
                            .fill(Color.white)
                            .frame(width: lineSize(geometry).width, height: lineSize(geometry).height)
                            .position(x: geometry.size.width / 2.0, y: geometry.size.width / 2.0)
                            
                    )
            }

        }
        
    }
    
    private func circleRadius(_ geometry: GeometryProxy) -> CGFloat {
        min(geometry.size.width, geometry.size.height) * 0.5
    }
    
    private func lineSize(_ geometry: GeometryProxy) -> CGSize {
        CGSize(width: 0.08 * circleRadius(geometry), height: 0.25 * circleRadius(geometry))
    }
    
}

struct OnoffButton_Previews: PreviewProvider {
    static var previews: some View {
        OnoffButton()
    }
}
