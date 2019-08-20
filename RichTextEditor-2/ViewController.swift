//
//  ViewController.swift
//  RichTextEditor-2
//
//  Created by chenxu on 2019/8/14.
//  Copyright © 2019 chenxu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let editorView = RichTextEditorView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 400))

        let toolbar = RichTextToolBar(frame: CGRect(x: 0, y: 410, width: self.view.frame.width, height: 50))

        toolbar.delegate = editorView
        editorView.delegate = toolbar
        
        self.view.addSubview(editorView)
        self.view.addSubview(toolbar)

    }


}

