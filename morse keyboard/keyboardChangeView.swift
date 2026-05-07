//
//  keyboardChangeView.swift
//  morse keyboard
//
//  Created by 이종현 on 5/1/26.
//

import SwiftUI

struct keyboardChangeView: View {
    var onComplete: () -> Void

    @State private var text: String = ""
    @FocusState private var isTextFieldFocused: Bool
//    @AppStorage("initDone") private var initDone:Bool = false

    var body: some View {
        VStack(spacing: 20){
            Spacer().frame(height: 150)
            Text("모스 키보드로 전환").bold().font(.system(size: 25))
            HStack{
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("\(Text("지구").bold()) 아이콘을 길게 탭 하세요")
            }
            HStack{
                Image(systemName: "hand.tap")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("키보드를 전환하려면 \(Text("모스 키보드").bold())를 탭 하세요")
            }
            // 키보드를 나타나기 위해 만듦
            TextField("", text: $text)
                    .focused($isTextFieldFocused)
                    .opacity(0)
                    .frame(width: 0, height: 0)
            Spacer()
        }
        .onAppear{
            checkKeyboard()
            setupNotification()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                isTextFieldFocused = true
            }
        }
    }
    
    // 현재 키보드 종류를 검사하는 함수
    private func checkKeyboard(){
        if let mode = UIResponder.currentInputMode,
           let identifier = mode.value(forKey: "identifier") as? String {
//            print("현재 활성화된 키보드: \(identifier)")
            if identifier.contains("ijin-01.morse-keyboard.keyboard"){
//                initDone = true
                onComplete()
            }
//            else{
//                initDone = false
//            }
        }
    }
    
    // 시스템에서 키보드가 바뀔 때마다 실행
    private func setupNotification() {
        NotificationCenter.default.addObserver(forName: UITextInputMode.currentInputModeDidChangeNotification, object: nil, queue: .main) { _ in
            self.checkKeyboard()
        }
    }
}

// 현재 포커스된 입력창의 inputMode를 가져오는 확장 코드
extension UIResponder {
    static var currentInputMode: UITextInputMode? {
        // 현재 키보드 입력을 받고 있는 객체를 찾아 inputMode 반환
        return UIResponder.currentFirstResponder?.textInputMode
    }

    private static weak var _currentFirstResponder: UIResponder?
    static var currentFirstResponder: UIResponder? {
        _currentFirstResponder = nil
        UIApplication.shared.sendAction(#selector(findFirstResponder(_:)), to: nil, from: nil, for: nil)
        return _currentFirstResponder
    }

    @objc private func findFirstResponder(_ sender: Any) {
        UIResponder._currentFirstResponder = self
    }
}

#Preview {
    keyboardChangeView{}//.preferredColorScheme(.dark)
}
