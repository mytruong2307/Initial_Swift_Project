//
//  PRV300dpiPrintRenderer.swift
//  VAC Agent
//
//  Created by Mytruong on 3/25/19.
//  Copyright © 2019 Mytruong. All rights reserved.
//

import WebKit
class PRV300dpiPrintRenderer : UIPrintPageRenderer {
    func pdfData() -> NSData {
        let data = NSMutableData()
        UIGraphicsBeginPDFContextToData(data, self.paperRect, nil)
        UIColor.white.set();
        let pdfContext = UIGraphicsGetCurrentContext()
        pdfContext!.saveGState()
        pdfContext!.concatenate(CGAffineTransform(scaleX: 72/300, y: 72/300)) // scale down to improve dpi from screen 72dpi to printable 300dpi
        self.prepare(forDrawingPages: NSRange.init(0...self.numberOfPages))
        let bounds = UIGraphicsGetPDFContextBounds()
        for i in 0..<self.numberOfPages {
            UIGraphicsBeginPDFPage();
            self.drawPage(at: i, in: bounds)
        }
        pdfContext!.restoreGState()
        UIGraphicsEndPDFContext();
        return data
    }
}
