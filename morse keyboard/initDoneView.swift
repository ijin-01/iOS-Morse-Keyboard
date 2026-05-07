//
//  initDoneView.swift
//  morse keyboard
//
//  Created by 이종현 on 5/2/26.
//

import SwiftUI

struct initDoneView:View {
    var onComplete: () -> Void
    
    @State private var text: String = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 20){
            Spacer().frame(height: 150)
            Text("설정 완료").bold().font(.system(size: 25))
            Text("이제 모든 앱에서\n모스 키보드를 사용할 수 있습니다.")
                .multilineTextAlignment(.center)
            Spacer()
            
            Button("확인"){
                isTextFieldFocused = false
                onComplete()
            }
            .buttonStyle(.glassProminent)
            .controlSize(.large)
            .bold()
            
            // 키보드를 나타나기 위해 만듦
            TextField("", text: $text)
                .focused($isTextFieldFocused)
                .opacity(0)
                .frame(width: 0, height: 0)
            Spacer()
        }
        .onAppear{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                isTextFieldFocused = true
            }
        }
    }
}

#Preview {
    initDoneView{}//.preferredColorScheme(.dark)
}
