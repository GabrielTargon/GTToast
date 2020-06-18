//
//  GTToast.swift
//  GTToast
//
//  Created by Gabriel Targon on 05/09/19.
//  Copyright © 2019 Gabriel Targon. All rights reserved.
//

import UIKit
import ObjectiveC

class GTToast: UIView {
    
    enum Color: Int {
        case green = 0x739E41
        case yellow = 0xF2A51A
        case red = 0xF14C4C
    }
    
    @IBOutlet fileprivate var contentView: UIView!
    @IBOutlet fileprivate weak var messageLabel: UILabel!
    @IBOutlet fileprivate weak var closeImage: UIImageView!
    @IBOutlet fileprivate weak var backgroundView: UIView!
    @IBOutlet fileprivate weak var labelTrailingConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var buttonClose: UIButton!
    @IBOutlet fileprivate weak var messageLabelBottomConstraint: NSLayoutConstraint!
    
    private let toastHeight: CGFloat = 55
    private let toastHeightIphoneXAndLater: CGFloat = 89
    private let toastWidth: CGFloat = UIScreen.main.bounds.width
    private let toastViewAnimationSpeed: Double = 0.3
    
    private var messageText: NSAttributedString?
    private var shouldClose: Bool = false
    private var background: Color?
    private var isKeyboardVisible: Bool = false
    private var willDismissKeyboard: Bool = false
    private var keyboardSize: CGRect = CGRect.init(x: 0, y: 0, width: 0, height: 0)
    
    // MARK: - Lifecycle
    
    static func start() -> GTToast {
        return GTToast.init(frame: CGRect.init())
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    // MARK: Functions
    
    func show(withText text: String, withCloseButton close: Bool, andBackgroundColor color: Color) {
        let toastString = NSMutableAttributedString(string: text)
        toastString.addAttribute(NSAttributedString.Key.font,
                                 value: UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium),
                                 range: NSRange.init(location: 0, length: text.count))
        
        show(withAttributedText: toastString, withCloseButton: close, andBackgroundColor: color)
    }
    
    func show(withAttributedText text: NSAttributedString, withCloseButton close: Bool, andBackgroundColor color: Color) {
        guard self.contentView == nil else {
            return
        }
        
        commonInit()
        
        messageLabel.attributedText = text
        backgroundView.backgroundColor = UIColor.init(hex: color.rawValue)
        if !close {
            labelTrailingConstraint.constant = 8
            closeImage.isHidden = true
        }
    }
    
    func hideAfter(seconds: Double) {
        let deadlineTime = DispatchTime.now() + seconds
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            self.dismiss()
        }
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("GTToast", owner: self, options: nil)
        contentView.alpha = 1.0
        contentView.frame = CGRect.init(x: 0, y: UIScreen.main.bounds.height, width: 0, height: 0)
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        let window = UIApplication.shared.keyWindow
        window?.addSubview(contentView)
        
        showToast()
    }
    
    private func showToast() {
        UIView.animate(withDuration: toastViewAnimationSpeed, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            if self.isKeyboardVisible && !self.willDismissKeyboard {
                self.contentView.frame = CGRect.init(x: 0, y: (UIScreen.main.bounds.height - self.toastHeight - self.keyboardSize.height), width: self.toastWidth, height: self.toastHeight)
            } else {
                self.setContentViewFrame()
            }
        })
        
    }
    
    private func  dismiss() {
        guard let _ = self.contentView else {
            return
        }
        UIView.animate(withDuration: toastViewAnimationSpeed, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.contentView.frame.origin.y = UIScreen.main.bounds.height
        }) { (_) in
            self.contentView.removeFromSuperview()
            self.contentView = nil
        }
    }
    
    private func setContentViewFrame() {
        if let content = contentView {
            if UIDevice.current.screenType == .iPhonesX {
                content.frame = CGRect.init(x: 0, y: (UIScreen.main.bounds.height - toastHeightIphoneXAndLater), width: toastWidth, height: toastHeightIphoneXAndLater)
                messageLabelBottomConstraint.constant = 34
            } else {
                contentView.frame = CGRect.init(x: 0, y: (UIScreen.main.bounds.height - toastHeight), width: toastWidth, height: toastHeight)
                messageLabelBottomConstraint.constant = 0
            }
        }
    }
    
    //MARK: Keyboard behaviour

    @objc func keyboardDidShow(_ notification: NSNotification) {
        isKeyboardVisible = true
        guard let info = notification.userInfo else{
            return
        }
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardSize = keyboardFrame
    }

    @objc func keyboardWillShow(_ notification: NSNotification) {
        if let content = self.contentView {
            if let info = notification.userInfo {
                var keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
                keyboardFrame = self.convert(keyboardFrame, to: self)
                content.frame.origin.y = UIScreen.main.bounds.height - toastHeight - keyboardFrame.height
            }
        }
    }

    @objc func keyboardDidHide(_ notification: NSNotification) {
        isKeyboardVisible = false
        willDismissKeyboard = false
        keyboardSize = CGRect.init(x: 0, y: 0, width: 0, height: 0)
        setContentViewFrame()
    }

    @objc func keyboardWillHide(_ notification: NSNotification) {
        if let content = self.contentView {
            content.frame.origin.y += keyboardSize.height
        }
    }
    
    //MARK: Actions
    
    @IBAction func closeToastAction(_ sender: Any) {
        dismiss()
    }
    
}
