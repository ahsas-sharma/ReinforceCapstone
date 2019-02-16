//
//  ViewController.swift
//  Reinforce
//
//  Created by Ahsas Sharma on 08/02/19.
//  Copyright © 2019 Ahsas Sharma. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CLImageEditorDelegate {
    var editor: CLImageEditor!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        setupCLImageEditorTools()
    }

    @IBAction func buttonTapped() {
       
    }


//    func showEditor() {
//        editor = CLImageEditor(image: UIImage(named:"wallpaper"), delegate: self)
//        self.present(editor, animated: true, completion: {
//
//            let textTool = self.editor.toolInfo.subToolInfo(withToolName: "CLTextTool", recursive: false)
//            print(textTool)
//
//        });
//    }
//
//    func setupCLImageEditorTools() {
//        let tool1 = editor.toolInfo.subToolInfo(withToolName: "CLFilterTool", recursive: false)
//        let tool2 = editor.toolInfo.subToolInfo(withToolName: "CLBlurTool", recursive: false)
//        tool1?.available = false
//        tool2?.available = false
//    }
}

