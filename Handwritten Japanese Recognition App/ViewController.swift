//
//  ViewController.swift
//  Handwritten Japanese Recognition App
//
//  Created by Aiyu Kamate on 2020/08/03.
//  Copyright © 2020 Aiyu Kamate. All rights reserved.
//

import UIKit
import Vision

class ViewController: UIViewController {

    @IBOutlet weak var handwrite: Handwrite!
    @IBOutlet weak var firstchoice: UILabel!
    @IBOutlet weak var secondchoice: UILabel!
    @IBOutlet weak var thirdchoice: UILabel!
    @IBOutlet weak var finallabel: UILabel!
    @IBOutlet weak var modelabel: UILabel!
    
    var model = try! VNCoreMLModel(for: hiragana().model)
    var x = 0
    var modenum = 0
    var par = ""
    var par1 = ""
    var par2 = ""
    var par3 = ""
    
    @IBOutlet weak var sbutton: UIButton!
    @IBOutlet weak var cbutton: UIButton!
    @IBOutlet weak var rbutton: UIButton!
    @IBOutlet weak var button4: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sbutton.decorate(colors: UIColor.green)
        cbutton.decorate(colors: UIColor.systemTeal)
        rbutton.decorate(colors: UIColor.systemTeal)
        button4.decorate(colors: UIColor.systemPink)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
       get {
          return .portrait
       }
    }
    
    override open var shouldAutorotate: Bool {
        return false
    }
    
    func Classification(request:VNRequest, error:Error?){
        guard let result = request.results as? [VNClassificationObservation] else {print("no results"); return}
        
        let results = result
            .filter({$0.confidence >= 0.005})
            .map({$0.identifier})
        firstchoice.text = results[0]
        par1 = results[0]
        if (results.count > 1){
            secondchoice.text =  results[1]
            par2 = results[1]
        }else{
            secondchoice.text =  ""
        }
        if (results.count > 2){
            thirdchoice.text =  results[2]
            par3 = results[2]
        }else{
            thirdchoice.text =  ""
        }
    }

    @IBAction func recognizeJapanese(_ sender: Any) {
        x = 1
        let request = [VNCoreMLRequest(model: model, completionHandler: Classification)]
        let image = convertImage(image: UIImage(view: handwrite), toSize:CGSize(width:48,height:48))
        let handler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
        do {
            try handler.perform(request)
        }catch{
            fatalError("An error has occured.")
        }
        
    }
    
    @IBAction func clear(_ sender: Any) {
        handwrite.clear()
        par1 = ""
        par2 = ""
        par3 = ""
        x = 0
    }
    
    @IBAction func chooseA(_ sender: Any) {
        if (x == 1){
            finallabel.text = (finallabel.text ?? "") + par1
            par1 = ""
            par2 = ""
            par3 = ""
            x = 0
        }
    }
    @IBAction func chooseB(_ sender: Any) {
        if (x == 1 && par2 != ""){
            finallabel.text = (finallabel.text ?? "") + par2
            par1 = ""
            par2 = ""
            par3 = ""
            x = 0
        }
    }
    @IBAction func chooseC(_ sender: Any) {
        if (x == 1 && par3 != ""){
            finallabel.text = (finallabel.text ?? "") + par3
            par1 = ""
            par2 = ""
            par3 = ""
            x = 0
        }
    }
    
    @IBAction func clearlabel(_ sender: Any) {
        UIPasteboard.general.string = finallabel.text
        let alert = UIAlertController(title: "Text Copied", message: "Text Copied", preferredStyle: .alert)
        let button = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in})
        alert.addAction(button)
        self.present(alert, animated: true, completion: nil)
        finallabel.text = ""
        par1 = ""
        par2 = ""
        par3 = ""
        x = 0
    }
    
    @IBAction func switchmode(_ sender: Any) {
        if (modenum == 0){
            modenum = 1
            modelabel.text = "mode: Katakana"
        }else if (modenum == 1){
            modenum = 2
            modelabel.text = "mode: Kanji"
        }else{
            modenum = 0
            modelabel.text = "mode: Hiragana"
        }
        if (modenum == 0){
            model = try! VNCoreMLModel(for: hiragana().model)
        }else if (modenum == 1){
            model = try! VNCoreMLModel(for: katakana().model)
        }else{
            model = try! VNCoreMLModel(for: kanji().model)
        }
    }
}

extension UIButton{
    func decorate(colors: UIColor){
        self.backgroundColor = colors
        self.layer.cornerRadius = 10 //self.frame.height/2
        self.setTitleColor(UIColor.black, for: .normal)
    }
}

func convertImage(image:UIImage, toSize size:CGSize) -> UIImage{
    UIGraphicsBeginImageContextWithOptions(size,false, 1.0 )
    image.draw(in: CGRect(x:0,y:0,width:size.width,height:size.height))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage!
}
