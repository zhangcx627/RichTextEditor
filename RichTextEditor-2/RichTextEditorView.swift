//
//  RichTextEditorViewController.swift
//  RichTextEditor-2
//
//  Created by chenxu on 2019/8/14.
//  Copyright © 2019 chenxu. All rights reserved.
//

import UIKit
import WebKit
import Foundation


protocol RichTextEditorViewDelegate: NSObjectProtocol {

    func updateToolbar(_ name: String)

}
class RichTextEditorView: UIView, WKNavigationDelegate, WKUIDelegate, UINavigationControllerDelegate, RichTextToolBarDelegate {

    weak var delegate:RichTextEditorViewDelegate?

    var editorLoaded = false

    var shouldShowKeyBoard = true

    var alwaysShowToolbar = false

    var formatHTML = true

    var enabledToolbarItems:[String] = []

    var wkUScript = WKUserScript()

    var editorView = WKWebView()
    
    var resourcesLoaded = false

    var editorViewFrame: CGRect = .zero

    var internalHTML: String = ""

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.createEditorViewWithFrame(frame)

        if !resourcesLoaded {
            self.loadResources()
        }


//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowOrHide(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    func createEditorViewWithFrame(_ frame: CGRect) {
        //chenxu: for scalesPageFit
        let jScript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
        self.wkUScript = WKUserScript(source: jScript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)

        let wkUController = WKUserContentController()
        wkUController.addUserScript(self.wkUScript)

        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = true
        config.dataDetectorTypes = WKDataDetectorTypes.all
        config.userContentController = wkUController

        self.editorView = WKWebView(frame: frame, configuration: config)
        self.editorView.uiDelegate = self
        self.editorView.navigationDelegate = self

        //TODO: keyboardDisplayRequiresUserAction

        self.editorView.autoresizingMask = [.flexibleHeight, .flexibleWidth, .flexibleTopMargin, .flexibleBottomMargin]
        self.editorView.scrollView.bounces = false
        self.editorView.backgroundColor = .red
        self.addSubview(self.editorView)
    }


    func loadResources() {
        let bundle = Bundle(for: RichTextEditorView.classForCoder())
        var htmlString = ""
        if let filePath = bundle.path(forResource: "editor", ofType: "html") {
            do {
                htmlString = try String(contentsOfFile: filePath, encoding: .utf8)
            } catch {
            }
        }
        if let filePath = bundle.path(forResource: "jQuery", ofType: "js") {
            do {
                let jqueryString = try String(contentsOfFile: filePath, encoding: .utf8)
                htmlString = htmlString.replacingOccurrences(of: "<!-- jQuery -->", with: jqueryString)
            } catch {
            }
        }
        if let filePath = bundle.path(forResource: "JSBeautifier", ofType: "js") {
            do {
                let beautifierString = try String(contentsOfFile: filePath, encoding: .utf8)
                htmlString = htmlString.replacingOccurrences(of: "<!-- jsbeautifier -->", with: beautifierString)
            } catch {
            }
        }
        if let filePath = bundle.path(forResource: "EdoRichTextEditor", ofType: "js") {
            do {
                let jsString = try String(contentsOfFile: filePath, encoding: .utf8)
                htmlString = htmlString.replacingOccurrences(of: "<!--editor-->", with: jsString)
            } catch {
            }
        }

        self.editorView.loadHTMLString(htmlString, baseURL: nil)
        self.resourcesLoaded = true
    }


    /*@objc func keyboardWillShowOrHide(_ notif: Notification) {
        if let info = notif.userInfo {
            let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0
            let keyboardEnd = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? .zero

            let sizeOfToolBar = self.toolbarHolder.frame.size.height
            let keyboardHeight = keyboardEnd.size.height

            let extraHeight:CGFloat = 10.0
            if keyboardEnd.origin.y < UIScreen.main.bounds.size.height {
                UIView.animate(withDuration: duration) {
                    var toolbarFrame = self.toolbarHolder.frame
                    let kbRect = self.toolbarHolder.superview?.convert(keyboardEnd, from: nil)
                    toolbarFrame.origin.y = kbRect?.origin.y ?? 0 - sizeOfToolBar
                    self.toolbarHolder.frame = toolbarFrame

                    var editorFrame = self.editorView.frame
                    editorFrame.size.height = toolbarFrame.origin.y - extraHeight
                    self.editorView.frame = editorFrame
                    self.editorViewFrame = self.editorView.frame
                    self.editorView.scrollView.contentInset = .zero
                    self.editorView.scrollView.scrollIndicatorInsets = .zero

                    self.setFooterHeight(footerHeight: keyboardHeight - 8)
                    self.setContentHeight(contentHeight: self.editorViewFrame.size.height)
                }
            } else {
                UIView.animate(withDuration: duration) {
                    var frame = self.toolbarHolder.frame
                    frame.origin.y = self.frame.size.height + keyboardHeight
                    self.toolbarHolder.frame = frame

                    var editorFrame = self.editorView.frame
                    editorFrame.size.height = self.frame.size.height
                    self.editorView.frame = editorFrame
                    self.editorViewFrame = self.editorView.frame
                    self.editorView.scrollView.contentInset = .zero
                    self.editorView.scrollView.scrollIndicatorInsets = .zero
                    self.setFooterHeight(footerHeight: 0)
                    self.setContentHeight(contentHeight: self.editorViewFrame.size.height)
                }
            }
        }

    }*/

    func setFooterHeight(footerHeight: CGFloat) {
        let js = "edo_editor.setFooterHeight(\"\(footerHeight)\");"
        self.editorView.syncEvalJavascriptString(js)
    }

    func setContentHeight(contentHeight: CGFloat) {
        let js = "edo_editor.contentHeight = \"\(contentHeight)\";"
        self.editorView.syncEvalJavascriptString(js)
    }

    //MARK: WKWebView Delegate
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let urlString = navigationAction.request.url?.absoluteString.removingPercentEncoding {
            if urlString.range(of: "callback://0/") != nil {
                let name = urlString.replacingOccurrences(of: "callback://0/", with: "")
                self.updateToolBar(name: name)
                decisionHandler(.cancel)
            } else if urlString.range(of: "debug://") != nil {
                let debug = urlString.replacingOccurrences(of: "debug://", with: "").removingPercentEncoding
                print("debug:\(String(describing: debug))")
                decisionHandler(.cancel)
            } else if urlString.range(of: "scroll://") != nil {
                if let position = Int(urlString.replacingOccurrences(of: "scroll://", with: "")) {
                    self.editorDidScroll(position: position)
                }
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        } else {
            decisionHandler(.allow)
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.editorLoaded = true
        if self.internalHTML.count != 0 {
            self.internalHTML = ""
        }
        self.updateHTML()

    }

    func setHTML(html: String) {
        self.internalHTML = html
        if self.editorLoaded {
            self.updateHTML()
        }
    }

    func updateHTML() {
        let html = self.internalHTML
        let cleanedHTML = self.removeQuotesFromHTML(html: html)
        let tigger = "edo_editor.setHTML(\"\(cleanedHTML)\");"
        self.editorView.syncEvalJavascriptString(tigger)
    }

    func getHTML() -> String {
        var html = ""
        let js = "edo_editor.getHTML();"
        html = self.editorView.syncEvalJavascriptString(js) as? String ?? ""
        html = self.removeQuotesFromHTML(html: html)
        html = self.tidyHTML(html: html)
        return html
    }

    func removeQuotesFromHTML(html: String) -> String {
        var cleanHTML = html.replacingOccurrences(of: "\"", with: "\\\"")
        cleanHTML = cleanHTML.replacingOccurrences(of: "“", with: "&quot;")
        cleanHTML = cleanHTML.replacingOccurrences(of: "”", with: "&quot;")
        cleanHTML = cleanHTML.replacingOccurrences(of: "\r", with: "\\r")
        cleanHTML = cleanHTML.replacingOccurrences(of: "\n", with: "\\n")
        return cleanHTML
    }

    func tidyHTML(html: String) -> String {
        var html = html
        html = html.replacingOccurrences(of: "<br>", with: "<br />")
        html = html.replacingOccurrences(of: "<hr>", with: "<hr />")
        html = self.editorView.syncEvalJavascriptString("style_html(\"\(html)\");") as? String ?? ""
        return html
    }

    func focusTextEditor() {
        //TODO: keyboardRequiresUserInteraction
        let js = "edo_editor.focusEditor();"
        self.editorView.syncEvalJavascriptString(js)
    }

    func blurTextEditor() {
        let js = "edo_editor.blurEditor();"
        self.editorView.syncEvalJavascriptString(js)
    }


    //toolbar delegate
    func evalJavascriptString(_ js: String) {
        self.editorView.syncEvalJavascriptString(js)
    }

    func updateToolBar(name: String) {
        self.delegate?.updateToolbar(name)
    }

    func editorDidScroll(position: Int) {

    }

    func isIpad() -> Bool {
        return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad
    }
}

extension WKWebView {
    @discardableResult
    func syncEvalJavascriptString(_ jsString: String) -> Any? {
        var returnValue: Any? = nil
        var finished = false
        self.evaluateJavaScript(jsString) { (result, error) in
            returnValue = result
            finished = true
        }
        while !finished {
            RunLoop.current.run(mode: .default, before: Date.distantFuture)
        }
        return returnValue
    }
}


