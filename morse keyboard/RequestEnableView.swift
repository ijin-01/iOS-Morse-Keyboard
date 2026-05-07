//
//  RequestEnableView.swift
//  morse keyboard
//
//  Created by 이종현 on 5/1/26.
//

import SwiftUI

struct RequestEnableView: View{
    var onComplete: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer().frame(height: 150)
            
            Text("모스 키보드 설정").bold().font(.system(size: 25))
            HStack{
                Image(systemName: "hand.tap")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("\(Text("키보드").bold())를 탭합니다")
            }
            HStack{
                Image(systemName: "switch.2")
                    .imageScale(.large)
                    .offset(y:-6)
                    .frame(height: 12)
                    .clipped()
                    .foregroundStyle(.green)
                Text("\(Text("모스 키보드").bold()) 사용 설정")
            }
            HStack{
                Image(systemName: "switch.2")
                    .imageScale(.large)
                    .offset(y:-6)
                    .frame(height: 12)
                    .clipped()
                    .foregroundStyle(.green)
                Text("\(Text("전체 접근 허용").bold()) 사용 설정")
            }
            
            Spacer()
            
            Button("시작하기"){
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
                onComplete()
            }
            .buttonStyle(.glassProminent)
            .controlSize(.large)
            .bold()
            
            Spacer()
        }
    }
}

#Preview {
    RequestEnableView{}//.preferredColorScheme(.dark)
}
