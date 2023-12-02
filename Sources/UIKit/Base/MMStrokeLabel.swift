//
//  MMStrokeLabel.swift
//  MMLibrary
//
//  Created by 曾亮敏 on 2023/12/2.
//

import UIKit

open class MMStrokeLabel: MMLabel {
    open var textBorderColor: UIColor = UIColor.black
    open var textBorderWidth: CGFloat = 0
    open var lineJoin: CGLineJoin = .round
    open var strokeDrawingMode: CGTextDrawingMode = .stroke
    open var textDrawingMode: CGTextDrawingMode = .fill
    
    open override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        let textColor = self.textColor
        context.setLineWidth(textBorderWidth)
        context.setLineJoin(lineJoin)
        context.setTextDrawingMode(strokeDrawingMode)
        // 描边颜色
        self.textColor = textBorderColor
        super.drawText(in: rect)
        
        context.setTextDrawingMode(textDrawingMode)
        self.textColor = textColor
        super.drawText(in: rect)
    }
}
