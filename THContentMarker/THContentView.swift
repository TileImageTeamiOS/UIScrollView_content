//
//  THContentView.swift
//  THContentMarkerView
//
//  Created by Seong ho Hong on 2018. 2. 18..
//  Copyright © 2018년 Seong ho Hong. All rights reserved.
//

import UIKit

protocol THContentType {
    var contentInfo: [String: Any?] { get set }
}

public struct THContent: THContentType {
    var contentInfo: [String: Any?]
}

public class THContentView: UIView {
    weak var delegate: THContentViewDelegate!
}

public protocol THContentViewDelegate: class {
    func setContent(info: Any?)
    func dismiss()
}
