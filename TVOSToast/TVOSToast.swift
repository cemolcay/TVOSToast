//
//  TVOSToast.swift
//  TVOSToast
//
//  Created by Cem Olcay on 17/02/16.
//  Copyright © 2016 MovieLaLa. All rights reserved.
//

import UIKit
import ManualLayout

// MARK: - UIViewController Extension

public extension UIViewController {

    public func presentToast(toast: TVOSToast) {
        toast.presentOnView(self.view)
    }
}

// MARK: - NSAttributedString

public extension NSAttributedString {

    public convenience init(text: String, fontName: String, fontSize: CGFloat, color: UIColor) {
        let font = UIFont(name: fontName, size: fontSize) ?? UIFont.systemFontOfSize(fontSize)
        self.init(text: text, font: font, color: color)
    }

    public convenience init(text: String, font: UIFont, color: UIColor) {
        let attributes = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: color
        ]
        self.init(string: text, attributes: attributes)
    }

    public convenience init(imageName: String, bounds: CGRect?, bundle: NSBundle) {
        let textAttachment = NSTextAttachment()
        textAttachment.image = UIImage(named: imageName, inBundle: bundle, compatibleWithTraitCollection: nil)
        if let bounds = bounds {
            textAttachment.bounds = bounds
        }
        self.init(attachment: textAttachment)
    }

    public convenience init(attributedStrings: NSAttributedString...) {
        let mutableAttributedString = NSMutableAttributedString()
        for attributedString in attributedStrings {
            mutableAttributedString.appendAttributedString(attributedString)
        }
        self.init(attributedString: mutableAttributedString)
    }
}

// MARK: - TVOSToastButtonType

public enum TVOSToastRemoteButtonType: String {
    case MenuBlack
    case MenuWhite
    case ScreenBlack
    case ScreenWhite
    case PlayPauseBlack
    case PlayPauseWhite
    case SiriBlack
    case SiriWhite
    case VolumeWhite
    case VolumeBlack

    private func getImageName() -> String {
        return "tvosToast\(rawValue).png"
    }

    public func getAttributedString(bounds bounds: CGRect? = nil) -> NSAttributedString {
        if let bundlePath = NSBundle(forClass: TVOSToast.self).pathForResource("TVOSToastResourceBundle", ofType: "bundle"), bundle = NSBundle(path: bundlePath) {
            return  NSAttributedString(imageName: self.getImageName(), bounds: bounds, bundle: bundle)
        }

        fatalError("Can't load TVOSToastResourceBundle")
    }
}

public enum ToastElement {
    case StringType(String)
    case RemoteButtonType(TVOSToastRemoteButtonType)
}


public func +(lhs: String, rhs: TVOSToastRemoteButtonType) -> [ToastElement] {
    return [.StringType(lhs), .RemoteButtonType(rhs)]
}

public func +(lhs: TVOSToastRemoteButtonType, rhs: String) -> [ToastElement] {
    return [.RemoteButtonType(lhs), .StringType(rhs)]
}

public func +(lhs: [ToastElement], rhs: String) -> [ToastElement] {
    return lhs + [.StringType(rhs)]
}

public func +(lhs: String, rhs: [ToastElement]) -> [ToastElement] {
    return [.StringType(lhs)] + rhs
}


// MARK: - TVOSToastHintText

public class TVOSToastHintText {

    public var elements: [ToastElement]

    public init(element: [ToastElement]) {
        self.elements = element
    }

    public func buildAttributedString(font: UIFont, textColor: UIColor) -> NSAttributedString {
        let mutableAttributedString = NSMutableAttributedString()

        for element in elements {

            switch element {
            case .StringType(let asString):
                mutableAttributedString.appendAttributedString(NSAttributedString(text: asString, font: font, color: textColor))

            case .RemoteButtonType(let asRemoteButtonType):
                let size = font.pointSize + 30
                mutableAttributedString.appendAttributedString(asRemoteButtonType.getAttributedString(bounds: CGRect(x: 0, y: -size/4, width: size, height: size)))
            }
        }
        return mutableAttributedString.mutableCopy() as! NSAttributedString
    }
}

// MARK: - Position

public enum TVOSToastPosition {
    case Top(insets: CGFloat)
    case TopLeft(insets: CGFloat)
    case TopRight(insets: CGFloat)
    case Bottom(insets: CGFloat)
    case BottomLeft(insets: CGFloat)
    case BottomRight(insets: CGFloat)
}

// MARK: - Style

public struct TVOSToastStyle {
    // presentation
    public var position: TVOSToastPosition?
    public var duration: NSTimeInterval?
    // appearance
    public var backgroundColor: UIColor?
    public var cornerRadius: CGFloat?
    // text style
    public var font: UIFont?
    public var textColor: UIColor?

    public init() {
        position = nil
        duration = nil
        backgroundColor = nil
        cornerRadius = nil
        font = nil
        textColor = nil
    }
}

// MARK: - Toast

public class TVOSToast: UIView {

    // MARK: Properties

    public var style: TVOSToastStyle

    public var customContent: UIView?
    public var text: String?
    public var attributedText: NSAttributedString?
    public var hintText: TVOSToastHintText?

    private let customContentView = UIView()
    private let textLabel = UILabel()

    // MARK: Init



    public init(frame: CGRect, style: TVOSToastStyle? = nil) {
        self.style = style ?? TVOSToastStyle()
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        self.style = TVOSToastStyle()
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        customContentView.frame = bounds
        textLabel.frame = bounds
        addSubview(customContentView)
        // text
        textLabel.numberOfLines = 0
        textLabel.textAlignment = .Center
        addSubview(textLabel)
    }

    // MARK: Present

    public func presentOnView(view: UIView, callback: (() -> Void)? = nil) {

        // get style
        let position = style.position ?? .Bottom(insets: 20)
        let duration = style.duration ?? 3
        let backgroundColor = style.backgroundColor ?? UIColor.grayColor()
        let cornerRadius = style.cornerRadius ?? 10
        let font = style.font ?? UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        let textColor = style.textColor ?? UIColor.whiteColor()

        // setup style
        self.backgroundColor = backgroundColor
        self.layer.cornerRadius = cornerRadius
        self.alpha = 0
        view.addSubview(self)

        // setup text
        if let hintText = hintText {
            textLabel.attributedText = hintText.buildAttributedString(font, textColor: textColor)
        } else if let attributedText = attributedText {
            textLabel.attributedText = attributedText
        } else if let text = text {
            textLabel.text = text
            textLabel.textColor = textColor
            textLabel.font = font
        }

        // setup custom content
        if let customContent = customContent {
            customContentView.addSubview(customContent)
        }

        // setup position
        switch position {
        case .Top(let insets):
            top = insets
            centerX = view.width / 2
        case .TopLeft(let insets):
            top = insets
            left = insets
        case .TopRight(let insets):
            top = insets
            right = view.right - insets
        case .Bottom(let insets):
            bottom = view.bottom - insets
            centerX = view.width / 2
        case .BottomLeft(let insets):
            bottom = view.bottom - insets
            left = insets
        case .BottomRight(let insets):
            bottom = view.bottom - insets
            right = view.right - insets
        }

        // animate toast
        UIView.animateWithDuration(0.3,
                                   delay: 0,
                                   usingSpringWithDamping: 1,
                                   initialSpringVelocity: 0,
                                   options: .AllowAnimatedContent,
                                   animations: {
                                    self.alpha = 1
            },
                                   completion: { finished in
                                    UIView.animateWithDuration(0.3,
                                        delay: duration,
                                        usingSpringWithDamping: 1,
                                        initialSpringVelocity: 0,
                                        options: .AllowAnimatedContent,
                                        animations: {
                                            self.alpha = 0
                                        },
                                        completion: { finished in
                                            self.removeFromSuperview()
                                            callback?()
                                    })
        })
    }

    public func presentOnWindow(relatedToView view: UIView?, callback: (() -> Void)? = nil) {
        guard let _window = UIApplication.sharedApplication().delegate?.window, window = _window else {
            return
        }

        // get style
        let position = style.position ?? .Bottom(insets: 20)
        let duration = style.duration ?? 3
        let backgroundColor = style.backgroundColor ?? UIColor.grayColor()
        let cornerRadius = style.cornerRadius ?? 10
        let font = style.font ?? UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        let textColor = style.textColor ?? UIColor.whiteColor()

        // setup style
        self.backgroundColor = backgroundColor
        self.layer.cornerRadius = cornerRadius
        self.alpha = 0

        let superViewOriginToWindow: CGPoint
        let viewWidth: CGFloat
        let viewHeight: CGFloat

        if let view = view {
            superViewOriginToWindow = view.convertPoint(view.bounds.origin, toView: window)
            viewWidth = view.width
            viewHeight = view.height
        } else {
            superViewOriginToWindow = CGPoint(x: 0, y: 0)
            viewWidth = window.width
            viewHeight = window.height
        }

        window.addSubview(self)

        // setup text
        if let hintText = hintText {
            textLabel.attributedText = hintText.buildAttributedString(font, textColor: textColor)
        } else if let attributedText = attributedText {
            textLabel.attributedText = attributedText
        } else if let text = text {
            textLabel.text = text
            textLabel.textColor = textColor
            textLabel.font = font
        }

        // setup position
        switch position {
        case .Top(let insets):
            center = CGPoint(x: superViewOriginToWindow.x + viewWidth/2, y: superViewOriginToWindow.y + insets + height/2)
        case .TopLeft(let insets):
            center = CGPoint(x: superViewOriginToWindow.x + insets + width/2, y: superViewOriginToWindow.y + insets + height/2)
        case .TopRight(let insets):
            center = CGPoint(x: superViewOriginToWindow.x + viewWidth - insets - width/2, y: superViewOriginToWindow.y + insets + height/2)
        case .Bottom(let insets):
            center = CGPoint(x: superViewOriginToWindow.x + viewWidth/2, y: superViewOriginToWindow.y + viewHeight - insets - height/2)
        case .BottomLeft(let insets):
            center = CGPoint(x: superViewOriginToWindow.x + insets + width/2, y: superViewOriginToWindow.y + viewHeight - insets - height/2)
        case .BottomRight(let insets):
            center = CGPoint(x: superViewOriginToWindow.x + viewWidth - insets - width/2, y: superViewOriginToWindow.y + viewHeight - insets - height/2)
        }

        // animate toast
        UIView.animateWithDuration(
            0.3,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0,
            options: .AllowAnimatedContent,
            animations: {
                self.alpha = 1
            },
            completion: { finished in
                UIView.animateWithDuration(0.3,
                    delay: duration,
                    usingSpringWithDamping: 1,
                    initialSpringVelocity: 0,
                    options: .AllowAnimatedContent,
                    animations: {
                        self.alpha = 0
                    },
                    completion: { finished in
                        self.removeFromSuperview()
                        callback?()
                })
        })

    }

    public func hide(callback: (() -> Void)? = nil) {
        layer.removeAllAnimations()

        UIView.animateWithDuration(0.3,
                                   delay: 0,
                                   usingSpringWithDamping: 1,
                                   initialSpringVelocity: 0,
                                   options: .AllowAnimatedContent,
                                   animations: {
                                    self.alpha = 0
            },
                                   completion: { finished in
                                    self.removeFromSuperview()
                                    callback?()
        })
    }
}
