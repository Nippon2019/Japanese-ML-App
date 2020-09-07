//
//  ViewController.swift
//  Handwritten Japanese Recognition App
//
//  Created by Aiyu Kamate on 2020/08/03.
//  Copyright © 2020 Aiyu Kamate. All rights reserved.
//
//  Icon from icons8.com

import UIKit
import Vision

class ViewController: UIViewController {

    @IBOutlet weak var handwrite: Handwrite!
    @IBOutlet weak var firstchoice: UILabel!
    @IBOutlet weak var secondchoice: UILabel!
    @IBOutlet weak var thirdchoice: UILabel!
    @IBOutlet weak var finallabel: UILabel!
    @IBOutlet weak var modelabel: UILabel!
    
    @IBOutlet weak var sbutton: UIButton!
    @IBOutlet weak var cbutton: UIButton!
    @IBOutlet weak var bbutton: UIButton!
    
    var model = try! VNCoreMLModel(for: hiragana().model)
    var modenum = 0  // number that represents the character mode
    var langnum = 0 //number that represents the language mode

    var x = 0  // changes to 1 while recognition is done
    var par1 = ""  // firstchoice parameter
    var par2 = ""  // secondchoice parameter
    var par3 = ""  // thirdchoice parameter
    var text1 = "Text Copied"
    var text2 = "OK"
    
    var color = UIColor(red: 230.00/255, green: 230.00/255, blue: 230.00/255, alpha: 1.00)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sbutton.decorate(colors: color)
        cbutton.decorate2(colorA: UIColor.white, colorB: UIColor.blue)
        bbutton.decorate(colors: color)
        
        handwrite.delegate = self
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
       get {
          return .portrait
       }
    }
    // disable landscape
    override open var shouldAutorotate: Bool {
        return false
    }
    
    func classification(request:VNRequest, error:Error?){
        guard let result = request.results as? [VNClassificationObservation] else {print("Error"); return}
        let results = result.filter({$0.confidence >= 0.005}).map({$0.identifier})
        
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

    func recognizeJapanese(){
        x = 1
        let request = [VNCoreMLRequest(model: model, completionHandler: classification)]
        let image = convertImage(image: UIImage(view: handwrite), size:CGSize(width:48,height:48))
        let handler = VNImageRequestHandler(cgImage: image.cgImage!)
        do {
            try handler.perform(request)
        }catch{
            fatalError("Error")
        }
        
    }
    
    @IBAction func clear(_ sender: AnyObject? = nil) {
        handwrite.clear()
        par1 = ""
        par2 = ""
        par3 = ""
        x = 0
        firstchoice.text = ""
        secondchoice.text = ""
        thirdchoice.text = ""
    }
    
    @IBAction func chooseA(_ sender: Any) {
        if (x == 1){
            finallabel.text = (finallabel.text ?? "") + par1
            par1 = ""
            par2 = ""
            par3 = ""
            x = 0
            clear()
        }
    }
    @IBAction func chooseB(_ sender: Any) {
        if (x == 1 && par2 != ""){
            finallabel.text = (finallabel.text ?? "") + par2
            par1 = ""
            par2 = ""
            par3 = ""
            x = 0
            clear()
        }
    }
    @IBAction func chooseC(_ sender: Any) {
        if (x == 1 && par3 != ""){
            finallabel.text = (finallabel.text ?? "") + par3
            par1 = ""
            par2 = ""
            par3 = ""
            x = 0
            clear()
        }
    }
    
    @IBAction func clearlabel(_ sender: Any) {
        if (finallabel.text != ""){
            if langnum == 0 && text1 != "Text Copied"{
                text1 = "Text Copied"
                text2 = "OK"
            }else if langnum == 1 && text1 == "Text Copied"{
                text1 = "テキストをコピー"
                text2 = "了解"
            }
            UIPasteboard.general.string = finallabel.text
            let alert = UIAlertController(title: text1, message: nil, preferredStyle: .alert)
            let button = UIAlertAction(title: text2, style: .default, handler: { (action) -> Void in})
            alert.addAction(button)
            self.present(alert, animated: true, completion: nil)
        }
        finallabel.text = ""
    }
    
    @IBAction func switchmode(_ sender: Any) {
        if (modenum == 0){
            modenum = 1
            if langnum == 0{modelabel.text = "mode: Katakana"}
            if langnum == 1{modelabel.text = "カタカナ"}
            model = try! VNCoreMLModel(for: katakana().model)
        }else if (modenum == 1){
            modenum = 2
            if langnum == 0{modelabel.text = "mode: Kanji"}
            if langnum == 1{modelabel.text = "漢字"}
            model = try! VNCoreMLModel(for: kanji().model)
        }else{
            modenum = 0
            if langnum == 0{modelabel.text = "mode: Hiragana"}
            if langnum == 1{modelabel.text = "ひらがな"}
            model = try! VNCoreMLModel(for: hiragana().model)
        }
        if (firstchoice.text != ""){
            recognizeJapanese()
        }
    }
    
    @IBAction func English(_ sender: Any) {
        if langnum != 0{
            sbutton.setTitle("switch mode", for: .normal)
            cbutton.setTitle("Clear", for: .normal)
            bbutton.setTitle("copy text & clear label", for: .normal)
            if modenum == 0{modelabel.text = "mode: Hiragana"}
            if modenum == 1{modelabel.text = "mode: Katakana"}
            if modenum == 2{modelabel.text = "mode: Kanji"}
            langnum = 0
        }
    }
    @IBAction func Japanese(_ sender: Any) {
        if langnum != 1{
            sbutton.setTitle("モード変更", for: .normal)
            cbutton.setTitle("クリア", for: .normal)
            bbutton.setTitle("テキストのコピーとクリア", for: .normal)
            if modenum == 0{modelabel.text = "ひらがな"}
            if modenum == 1{modelabel.text = "カタカナ"}
            if modenum == 2{modelabel.text = "漢字"}
            langnum = 1
        }
    }
    
    func convertImage(image:UIImage, size:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(size,false, 1.0 )
        image.draw(in: CGRect(x:0,y:0,width:size.width,height:size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
}

extension UIButton{
    func decorate(colors: UIColor){
        self.backgroundColor = colors
        self.layer.cornerRadius = 10
        self.setTitleColor(UIColor.black, for: .normal)
    }
    
    func decorate2(colorA: UIColor, colorB: UIColor){
        self.backgroundColor = colorA
        self.layer.borderWidth = 2.0
        self.layer.borderColor = UIColor.blue.cgColor
        self.setTitleColor(colorB, for: .normal)
        self.layer.cornerRadius = 10
    }
}
