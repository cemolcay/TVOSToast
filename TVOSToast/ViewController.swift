//
//  ViewController.swift
//  TVOSToast
//
//  Created by Cem Olcay on 17/02/16.
//  Copyright © 2016 MovieLaLa. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    let tap = UITapGestureRecognizer(target: self, action: #selector(showToast(tap:)))
    tap.allowedPressTypes = [NSNumber(value: UIPressType.select.rawValue)]
    view.addGestureRecognizer(tap)
  }

  @objc open func showToast(tap: UITapGestureRecognizer) {
    showToastWithAttributedString()
    showToastWithHintText()
    showToastWithText()
  }

  // Examples

  func showToastWithHintText() {
    let toast = TVOSToast(frame: CGRect(x: 0, y: 0, width: 800, height: 140))
    toast.style.position = TVOSToastPosition.bottom(insets: 20)
    toast.hintText = TVOSToastHintText(element: "Press the" + TVOSToastRemoteButtonType.MenuWhite + " button to exit app")
    presentToast(toast)
  }

  func showToastWithAttributedString() {
    let toast = TVOSToast(frame: CGRect(x: 0, y: 0, width: 800, height: 140))
    toast.style.position = TVOSToastPosition.topLeft(insets: 20)
    toast.attributedText = NSAttributedString(attributedStrings:
      NSAttributedString(
        text: "This is ",
        font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline),
        color: UIColor.white),
      NSAttributedString(
        text: "attributed string",
        font: UIFont.italicSystemFont(ofSize: 25),
        color: UIColor.white))
    presentToast(toast)
  }

  func showToastWithText() {
    let toast = TVOSToast(frame: CGRect(x: 0, y: 0, width: 800, height: 140))
    toast.style.position = TVOSToastPosition.topRight(insets: 20)
    toast.text = "This is regular text"
    presentToast(toast)
  }
}

