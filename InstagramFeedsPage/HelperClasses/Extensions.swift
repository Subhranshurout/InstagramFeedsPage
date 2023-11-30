//
//  Extensions.swift
//  InstagramFeedsPage
//
//  Created by Yudiz-subhranshu on 28/09/23.
//

import Foundation
import UIKit

extension UILabel {
    var getLabelHeight: CGFloat {
        let labelWidth = self.frame.size.width
        let labelFont = self.font
        let labelContent = self.text
        let labelSize = NSString(string: labelContent!).boundingRect(
            with: CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: [NSAttributedString.Key.font: labelFont!],
            context: nil
        ).size
        return labelSize.height
    }
}
extension UIImage {
    var getWidth: CGFloat {
        get {
            let width = self.size.width
            return width
        }
    }

    var getHeight: CGFloat {
        get {
            let height = self.size.height
            return height
        }
    }
}
extension UIButton {
    func animateWith (namedImage : String,transFormScale : CGFloat = 1.5) {
        UIView.animate(withDuration: 0.3, animations: { [self] in
            self.transform = CGAffineTransform(scaleX: transFormScale, y: transFormScale)
            self.setImage(UIImage(named: namedImage), for: .normal)
        }, completion: { _ in
            UIView.animate(withDuration: 0.3, animations: { [self] in
                self.transform = .identity
            })
        })
    }
    func makeCircularViewBtn () {
        self.layoutIfNeeded()
        self.layer.cornerRadius = self.frame.size.width / 2
    }
    func makeCircularViewBtn (with color : UIColor,boarder width : CGFloat) {
        self.layoutIfNeeded()
        self.layer.cornerRadius = self.frame.size.width / 2
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
    }
}


extension UIImageView {
    func makeCircularImage () {
        self.layoutIfNeeded()
        self.layer.cornerRadius = self.frame.size.width / 2
    }
    func makeCircularImage(with color : UIColor,boarder width : CGFloat) {
        self.layoutIfNeeded()
        self.layer.cornerRadius = self.frame.size.width / 2
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
    }
}

extension UIView {
    func makeCircularView () {
        self.layoutIfNeeded()
        self.layer.cornerRadius = self.frame.size.width / 2
    }
    func makeCircularView(with color : UIColor,boarder width : CGFloat) {
        self.layoutIfNeeded()
        self.layer.cornerRadius = self.frame.size.width / 2
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
    }
}

extension IndexPath {
    var preViousindex : IndexPath  {
        let index = self.row - 1
        var path = self
        path.row = index
        return path
    }
    
    var nextIndex : IndexPath  {
        let index = self.row + 1
        var path = self
        path.row = index
        return path
    }
}
