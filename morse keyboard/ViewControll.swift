//
//  ViewControll.swift
//  morse keyboard
//
//  Created by 이종현 on 4/29/26.
//

import SwiftUI

struct ViewControll: View {
    @AppStorage("isEnabled") private var isEnabled: Bool = false // 키보드 권한 설정 여부
    @AppStorage("isSetupCompleted") private var isSetupCompleted: Bool = false // 전체 설정 완료 여부
    @AppStorage("initDone") private var initDone: Bool = false
    
    
    var body: some View{
        Group{
            if isEnabled{
                if initDone{
                    if isSetupCompleted{
                        MainContentsView()
                            .transition(
                                .opacity
//                                    .combined(with: .scale)
                            )
                    }
                    else{
                        initDoneView{
                            withAnimation{
                                isSetupCompleted = true // 확인 버튼 클릭 시 메인으로 이동
                            }
                        }
                        .transition(.opacity)
                    }
                }else{
                    keyboardChangeView{
                        withAnimation{
                            initDone = true
                            isSetupCompleted = false
                        }
                    }
                    .transition(.opacity)
                }
            }else{
                RequestEnableView{
                    withAnimation{
                        initDone = false
                        isSetupCompleted = false
                    }
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: isEnabled)
        .animation(.easeInOut, value: initDone)
        .animation(.easeInOut, value: isSetupCompleted)
        .onAppear {
            updateKeyboardStatus()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                updateKeyboardStatus()
            }
        }
    }
    
    private func updateKeyboardStatus() {
        let sharedDefault = UserDefaults(suiteName: "group.com.rileytestut.AltStore.H4WKN2F")
        let hasBeenUsed = sharedDefault?.bool(forKey: "isKeyboardUsed") ?? false
        let systemEnabled = isKeyboardEnabled()
                
        withAnimation(.easeInOut) {
            self.isEnabled = systemEnabled || hasBeenUsed
        }
    }
    
    private func isKeyboardEnabled() -> Bool{
        let keyboardBundleID = "ijin-01.morse-keyboard.keyboard"
        // 현재 시스템에 등록된 모든 키보드 모드 확인
        let activeKeyboards = UITextInputMode.activeInputModes
            
        // 등록된 키보드들 중 본인의 Bundle ID를 포함하는 것이 있는지 검사
        return activeKeyboards.contains { mode in
            guard let identifier = mode.value(forKey: "identifier") as? String else { return false }
            return identifier.contains(keyboardBundleID)
        }
    }
}

#Preview {
    ViewControll()
}
