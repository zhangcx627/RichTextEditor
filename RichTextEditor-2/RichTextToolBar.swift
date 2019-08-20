//
//  RichTextToolBar.swift
//  RichTextEditor-2
//
//  Created by chenxu on 2019/8/16.
//  Copyright © 2019 chenxu. All rights reserved.
//

import UIKit

protocol RichTextToolBarDelegate: NSObjectProtocol {

    func evalJavascriptString(_ js:String)

}

//MARK: Color Constants
let COLOR_RED    = "#ff485f"
let COLOR_YELLOW = "#ffd41a"
let COLOR_GREEN  = "#31d76e"
let COLOR_ORANGE = "#ffd41a"
let COLOR_PURPLE = "#755cf2"
let COLOR_TEAL   = "#59dce4"
let COLOR_BLACK  = "#000000"

class RichTextToolBar: UIView, RichTextEditorViewDelegate {

    var toolbar = UIToolbar()

    var toolbarScrollView = UIScrollView()

    var colorToolbar = UIToolbar()

    var toolbarColorScrollView = UIScrollView()

    weak var delegate:RichTextToolBarDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.createScrollView()
        self.createColorScrollView()
        self.createToolBar()
        //Build the toolbar
        self.buildToolBar()
        self.buildColorToolBar()
    }

    func createScrollView() {
        self.toolbarScrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 44))
        self.toolbarScrollView.backgroundColor = .clear
        self.toolbarScrollView.showsHorizontalScrollIndicator = false
        self.addSubview(self.toolbarScrollView)
    }

    func createColorScrollView() {
        self.toolbarColorScrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 44))
        self.toolbarColorScrollView.backgroundColor = .clear
        self.toolbarColorScrollView.showsHorizontalScrollIndicator = false
        self.toolbarColorScrollView.isHidden = true
        self.addSubview(self.toolbarColorScrollView)
        self.bringSubviewToFront(self.toolbarColorScrollView)
    }

    func createToolBar() {
        self.toolbar = UIToolbar(frame: .zero)
        self.toolbar.autoresizingMask = .flexibleWidth
        self.toolbar.backgroundColor = .clear
        self.toolbarScrollView.addSubview(self.toolbar)
        self.toolbarScrollView.autoresizingMask = self.toolbar.autoresizingMask

        self.colorToolbar = UIToolbar(frame: .zero)
        self.colorToolbar.autoresizingMask = .flexibleWidth
        self.colorToolbar.backgroundColor = .clear
        self.toolbarColorScrollView.addSubview(self.colorToolbar)
        self.toolbarColorScrollView.autoresizingMask = self.colorToolbar.autoresizingMask

        self.autoresizingMask = self.toolbar.autoresizingMask
    }


    func buildToolBar() {
        let items = self.itemsForToolbar()

        let toolbarWidth = items.count * 44

        self.toolbar.items = items
        for item in items {
            item.tintColor = UIColor(red: 0, green: 122/255.0, blue: 1, alpha: 1)
        }
        self.toolbar.frame = CGRect(x: 0, y: 0, width: toolbarWidth, height: 44)
        self.toolbarScrollView.contentSize = CGSize(width: self.toolbar.frame.size.width, height: 44)
    }

    func buildColorToolBar() {
        let items = self.itemsForColorToolBar()

        let toolbarWidth = items.count * 44 + items.count * 5

        self.colorToolbar.items = items
        self.colorToolbar.frame = CGRect(x: 0, y: 0, width: toolbarWidth, height: 44)
        self.toolbarColorScrollView.contentSize = CGSize(width: self.colorToolbar.frame.size.width, height: 44)
        self.toolbarColorScrollView.isScrollEnabled = true
        print("colorToolbar:\(colorToolbar.frame)")
    }

    func itemsForColorToolBar() -> [EdoBarButtonItem] {
        var items:[EdoBarButtonItem] = []
        let red = EdoBarButtonItem(image: UIImage.image(colorHex: COLOR_RED)?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(redColorSelected))

        red.label = "red"
        items.append(red)
        let red1 = EdoBarButtonItem(image: UIImage.image(colorHex: COLOR_RED)?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(redColorSelected))
        red1.label = "red1"
        items.append(red1)
        let red2 = EdoBarButtonItem(image: UIImage.image(colorHex: COLOR_RED)?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(redColorSelected))
        red2.label = "red2"
        items.append(red2)
        let red3 = EdoBarButtonItem(image: UIImage.image(colorHex: COLOR_RED)?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(redColorSelected))
        red3.label = "red3"
        items.append(red3)
        let red4 = EdoBarButtonItem(image: UIImage.image(colorHex: COLOR_RED)?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(redColorSelected))
        red4.label = "red4"
        items.append(red4)

        let yellow = EdoBarButtonItem(image: UIImage.image(colorHex: COLOR_YELLOW)?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(yellowColorSelected))
        yellow.label = "yellow"
        items.append(yellow)
        let green = EdoBarButtonItem(image: UIImage.image(colorHex: COLOR_GREEN)?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(greenColorSelected))
        green.label = "green"
        items.append(green)
        let orange = EdoBarButtonItem(image: UIImage.image(colorHex: COLOR_ORANGE)?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(orangeColorSelected))
        orange.label = "orange"
        items.append(orange)
        let purple = EdoBarButtonItem(image: UIImage.image(colorHex: COLOR_PURPLE)?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(purpleColorSelected))
        purple.label = "purple"
        items.append(purple)
        let teal = EdoBarButtonItem(image: UIImage.image(colorHex: COLOR_TEAL)?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(tealColorSelected))
        teal.label = "teal"
        items.append(teal)
        let black = EdoBarButtonItem(image: UIImage.image(colorHex: COLOR_BLACK)?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(blackColorSelected))
        black.label = "black"
        items.append(black)
        return items
    }

    func itemsForToolbar() -> [EdoBarButtonItem] {
        var items:[EdoBarButtonItem] = []
        let bold = EdoBarButtonItem(image: UIImage(named: "ZSSbold.png"), style: .plain, target: self, action: #selector(setBold))
        bold.label = "bold"
        items.append(bold)
        let bold1 = EdoBarButtonItem(image: UIImage(named: "ZSSbold.png"), style: .plain, target: self, action: #selector(setBold))
        bold1.label = "bold1"
        items.append(bold1)
        let bold2 = EdoBarButtonItem(image: UIImage(named: "ZSSbold.png"), style: .plain, target: self, action: #selector(setBold))
        bold2.label = "bold2"
        items.append(bold2)
        let italic = EdoBarButtonItem(image: UIImage(named: "ZSSitalic.png"), style: .plain, target: self, action: #selector(setItalic))
        italic.label = "italic"
        items.append(italic)

        let subScript = EdoBarButtonItem(image: UIImage(named: "ZSSsubscript.png"), style: .plain, target: self, action: #selector(setSubscript))
        subScript.label = "subscript"
        items.append(subScript)

        let superscript = EdoBarButtonItem(image: UIImage(named: "ZSSsuperscript.png"), style: .plain, target: self, action: #selector(setSuperscript))
        superscript.label = "superscript"
        items.append(superscript)

        let strikethrough = EdoBarButtonItem(image: UIImage(named: "ZSSstrikethrough.png"), style: .plain, target: self, action: #selector(setStrikethrough))
        strikethrough.label = "strikeThrough"
        items.append(strikethrough)

        let undo = EdoBarButtonItem(image: UIImage(named: "ZSSundo.png"), style: .plain, target: self, action: #selector(setUndo))
        undo.label = "undo"
        items.append(undo)

        let redo = EdoBarButtonItem(image: UIImage(named: "ZSSredo.png"), style: .plain, target: self, action: #selector(setRedo))
        redo.label = "redo"
        items.append(redo)

        let textColor = EdoBarButtonItem(image: UIImage(named: "ZSStextcolor.png"), style: .plain, target: self, action: #selector(setTextColor))
        textColor.label = "textColor"
        items.append(textColor)


        return items
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //加粗
    @objc func setBold() {
        let trigger = "edo_editor.setBold();"
        self.delegate?.evalJavascriptString(trigger)
    }
    //斜体
    @objc func setItalic() {
        let trigger = "edo_editor.setItalic();";
        self.delegate?.evalJavascriptString(trigger)
    }
    //下角标
    @objc func setSubscript() {
        let trigger = "edo_editor.setSubscript();";
        self.delegate?.evalJavascriptString(trigger)
    }
    //上角标
    @objc func setSuperscript() {
        let trigger = "edo_editor.setSuperscript();";
        self.delegate?.evalJavascriptString(trigger)
    }
    //删除线
    @objc func setStrikethrough() {
        let trigger = "edo_editor.setStrikeThrough();";
        self.delegate?.evalJavascriptString(trigger)
    }

    @objc func setUndo() {
        let trigger = "edo_editor.undo();";
        self.delegate?.evalJavascriptString(trigger)
    }
    @objc func setRedo() {
        let trigger = "edo_editor.redo();";
        self.delegate?.evalJavascriptString(trigger)
    }

    @objc func setTextColor() {
        self.toolbarColorScrollView.isHidden = false
        self.toolbarScrollView.isHidden = true
        self.toolbarColorScrollView.contentOffset = CGPoint(x: 0, y: 0 )
    }

    @objc func redColorSelected() {
        let tigger = "edo_editor.setTextColor(\"\(COLOR_RED)\");"
        self.setColorSelected(tigger)
    }
    @objc func greenColorSelected() {
        let tigger = "edo_editor.setTextColor(\"\(COLOR_GREEN)\");"
        self.setColorSelected(tigger)
    }
    @objc func yellowColorSelected() {
        let tigger = "edo_editor.setTextColor(\"\(COLOR_YELLOW)\");"
        self.setColorSelected(tigger)
    }
    @objc func orangeColorSelected() {
        let tigger = "edo_editor.setTextColor(\"\(COLOR_ORANGE)\");"
        self.setColorSelected(tigger)
    }
    @objc func purpleColorSelected() {
        let tigger = "edo_editor.setTextColor(\"\(COLOR_PURPLE)\");"
        self.setColorSelected(tigger)
    }
    @objc func tealColorSelected() {
        let tigger = "edo_editor.setTextColor(\"\(COLOR_TEAL)\");"
        self.setColorSelected(tigger)
    }
    @objc func blackColorSelected() {
        let tigger = "edo_editor.setTextColor(\"\(COLOR_BLACK)\");"
        self.setColorSelected(tigger)
    }

    func setColorSelected(_ jsString: String) {
        self.toolbarColorScrollView.isHidden = true
        self.toolbarScrollView.isHidden = false
        self.delegate?.evalJavascriptString(jsString)
    }
}

extension RichTextToolBar {
    //delegate
    func updateToolbar(_ name: String) {
        let itemNames = name.components(separatedBy: ",")
        if let items:[EdoBarButtonItem] = self.toolbar.items as? [EdoBarButtonItem] {
            for item in items {
                if itemNames.contains(item.label) {
                    //means select this item
                    item.tintColor = .black
                } else {
                    item.tintColor = UIColor(red: 0, green: 122/255.0, blue: 1, alpha: 1)
                }
            }
        }
    }
}

import CoreGraphics
extension UIImage {

    public static func image(colorHex: String) -> UIImage? {
        let color = UIColor(hexString: colorHex)
        return UIImage(color: color)?.roundCornersToCircle()
    }
}

