//
//  KeyboardViewController.swift
//  keyboard
//
//  Created by 이종현 on 4/29/26.
//

import UIKit
import SwiftUI

class KeyboardViewController: UIInputViewController {
    
    
    @IBOutlet var nextKeyboardButton: UIButton!
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Add custom view sizing constraints here
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Perform custom UI setup here
        self.nextKeyboardButton = UIButton(type: .system)
        
        self.nextKeyboardButton.setTitle(NSLocalizedString("Next Keyboard", comment: "Title for 'Next Keyboard' button"), for: [])
        self.nextKeyboardButton.sizeToFit()
        self.nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        
        self.view.addSubview(self.nextKeyboardButton)
        
        self.nextKeyboardButton.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.nextKeyboardButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        // 키보드 뷰 추가
        let hostingController = UIHostingController(rootView: KeyboardView())
        hostingController.view.backgroundColor = .clear
        view.addKeyboardSubview(hostingController.view)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "addKey"), object: nil, queue: nil){notification in
            if let text = notification.object as? String{
                self.textDocumentProxy.insertText(text)
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "spaceKey"), object: nil, queue: nil){notification in
            self.textDocumentProxy.insertText(" ")
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "deleteKey"), object: nil, queue: nil) { _ in
            // 현재 커서 앞의 글자 하나를 삭제
            self.textDocumentProxy.deleteBackward()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("deleteWordKey"), object: nil, queue: nil) { _ in
            guard let context = self.textDocumentProxy.documentContextBeforeInput, !context.isEmpty else {
                self.textDocumentProxy.deleteBackward()
                return
            }

            var totalDeleteCount = 0
            let characters = Array(context.reversed())
            var i = 0
            
            // 단계 1: 끝에 있는 연속된 공백 카운트
            while i < characters.count && characters[i] == " " {
                totalDeleteCount += 1
                i += 1
            }
            
            // 단계 2: 공백 이후 나오는 첫 번째 단어 카운트
            while i < characters.count && characters[i] != " " {
                totalDeleteCount += 1
                i += 1
            }

            // 3. 계산된 총 길이만큼 삭제 실행
            if totalDeleteCount > 0 {
                for _ in 0..<totalDeleteCount {
                    self.textDocumentProxy.deleteBackward()
                }
            } else {
                self.textDocumentProxy.deleteBackward()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let sharedDefault = UserDefaults(suiteName: "group.com.rileytestut.AltStore.H4WKN2F")
        sharedDefault?.set(true, forKey: "isKeyboardUsed")
    }
    
    override func viewWillLayoutSubviews() {
        self.nextKeyboardButton.isHidden = !self.needsInputModeSwitchKey
        super.viewWillLayoutSubviews()
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
        
        var textColor: UIColor
        let proxy = self.textDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.dark {
            textColor = UIColor.white
        } else {
            textColor = UIColor.black
        }
        self.nextKeyboardButton.setTitleColor(textColor, for: [])
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
}

extension UIView{
    func addKeyboardSubview(_ subview: UIView){
        subview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subview)
        NSLayoutConstraint.activate([
            subview.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            subview.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            subview.leftAnchor.constraint(equalTo: self.leftAnchor),
            subview.rightAnchor.constraint(equalTo: self.rightAnchor)
        ])
    }
}
