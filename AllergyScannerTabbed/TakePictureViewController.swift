
//
//  TakePictureViewController.swift
//  AllergyScannerTabbed
//
//  Created by nikash khanna on 8/10/15.
//  Copyright (c) 2015 nikash khanna. All rights reserved.
//

import UIKit
import SwiftyJSON
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class TakePictureViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate, UITabBarDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var API_KEY = "AIzaSyBCC0PK7bQv-oSCBQxwJ34SiA1JT-CEEtg"
    var TRANSLATE_KEY = "AIzaSyDoESTztYJH-Iw36MjWP-mS224pw4aJ9CU"
    
    @IBOutlet var myButton: UIButton!
    
    @IBOutlet var pickerTextField: UITextField!
    
    @IBOutlet var ingredientsPicture: UIImageView!
    @IBOutlet var textView: UITextView!
    
    @IBOutlet var infoLabel: UILabel!
    
    var activityIndicator:UIActivityIndicatorView!
    
    var pickOption: [String] = []
    var actual: [String] = []
    
    var language = "eng"
    
    @IBAction func takePic(_ sender: AnyObject) {
        // 1
        
        if (language.isEmpty) {
            displayAlert("No Language Selected!", message: "Please choose a language!", dismiss: false)
        }
        else{
        
            view.endEditing(true)
            
            // 2
            let imagePickerActionSheet = UIAlertController(title: "Snap/Upload Photo",
                message: nil, preferredStyle: .actionSheet)
            
            // 3
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let cameraButton = UIAlertAction(title: "Take Photo",
                    style: .default) { (alert) -> Void in
                        let imagePicker = UIImagePickerController()
                        imagePicker.delegate = self
                        imagePicker.sourceType = .camera
                        imagePicker.showsCameraControls = true
                        self.present(imagePicker,
                            animated: true,
                            completion: nil)
                }
                imagePickerActionSheet.addAction(cameraButton)
            }
            
            // 4
            let libraryButton = UIAlertAction(title: "Choose Existing",
                style: .default) { (alert) -> Void in
                    let imagePicker = UIImagePickerController()
                    imagePicker.delegate = self
                    imagePicker.sourceType = .photoLibrary
                    self.present(imagePicker,
                        animated: true,
                        completion: nil)
            }
            imagePickerActionSheet.addAction(libraryButton)
            
            // 5
            let cancelButton = UIAlertAction(title: "Cancel",
                style: .cancel) { (alert) -> Void in
            }
            imagePickerActionSheet.addAction(cancelButton)
            
            // 6
            present(imagePickerActionSheet, animated: true,
                completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let pickedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        ingredientsPicture.contentMode = .scaleAspectFit
        ingredientsPicture.image = pickedImage // You could optionally display the image here by setting imageView.image = pickedImage
        
        addActivityIndicator()
        
        let binaryImageData = self.base64EncodeImage(pickedImage)
        self.createRequest(binaryImageData)
        //translateText()
        
        dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func populatePicker () {
        let path = Bundle.main.path(forResource: "languages", ofType: "txt")
        
        if let aStreamReader = StreamReader(path: path!) {
            while let line = aStreamReader.nextLine() {
                let nsLine = NSString(string: line)
                let line = nsLine as String
                var arr = line.characters.split{$0 == "\t"}.map(String.init)
                pickOption.append(arr[0])
                actual.append(arr[1])
            }
            // You can close the underlying file explicitly. Otherwise it will be
            // closed when the reader is deallocated.
            
            aStreamReader.close()
        }
        //print(actual)
    }
    
    
    // Activity Indicator methods
    
    func displayAlert(_ title: String, message: String, dismiss: Bool) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        if dismiss == true {
            alert.addAction((UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                self.dismiss(animated: dismiss, completion:nil)
            })))
        }
        else {
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func addActivityIndicator() {
        infoLabel.isHidden = false;
        
        
        self.myButton.isHidden = false;
        self.myButton.isEnabled = true;
        
        
        self.textView.isHidden = false;
        self.textView.isEditable = true;
        activityIndicator = UIActivityIndicatorView(frame: view.bounds)
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.backgroundColor = UIColor(white: 0, alpha: 0.25)
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        view.isUserInteractionEnabled = false
    }
    
    func removeActivityIndicator() {
        activityIndicator.willRemoveSubview(activityIndicator)
        view.willRemoveSubview(activityIndicator)
        activityIndicator.removeFromSuperview()
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true;
        view.isUserInteractionEnabled = true
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickOption.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickOption[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerTextField.text = "Translate to: " + pickOption[row]
        language = actual[row]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        textView.delegate = self;
        self.navigationController?.navigationBar.barTintColor = UIColor.groupTableViewBackground
    
        self.tabBarController?.tabBar.barTintColor = UIColor.groupTableViewBackground
        
        infoLabel.isHidden = true;
        
        infoLabel.layer.masksToBounds = true
        infoLabel.layer.cornerRadius = 8.0
        
        textView!.layer.borderWidth = 3
        textView!.layer.borderColor = UIColor(red: 0/255, green: 0/255, blue:102/255, alpha: 0.75 ).cgColor
        
        let pickerView = UIPickerView()
        populatePicker()
        pickerView.delegate = self
        pickerTextField.inputView = pickerView
        pickerTextField.text = "Translate to: English"

        
        //[self.myButton.setEnabled:NO];
        self.myButton.isEnabled = false;
        self.myButton.isHidden = true;
        self.textView.isHidden = true;
        self.textView.isEditable = false;
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    func resizeImage(_ imageSize: CGSize, image: UIImage) -> Data {
        UIGraphicsBeginImageContext(imageSize)
        image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let resizedImage = UIImagePNGRepresentation(newImage!)
        UIGraphicsEndImageContext()
        return resizedImage!
    }
    
    func base64EncodeImage(_ image: UIImage) -> String {
        //addActivityIndicator()
        var imagedata = UIImagePNGRepresentation(image)
        
        // Resize the image if it exceeds the 2MB API limit
        if (imagedata?.count > 2097152) {
            let oldSize: CGSize = image.size
            let newSize: CGSize = CGSize(width: 800, height: oldSize.height / oldSize.width * 800)
            imagedata = resizeImage(newSize, image: image)
        }
        
        return imagedata!.base64EncodedString(options: .endLineWithCarriageReturn)
    }
    
    func createRequest(_ imageData: String) {
        // Create our request URL
        let request = NSMutableURLRequest( url: URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(API_KEY)")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue( Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        
        // Build our API request
        let jsonRequest: [String: Dictionary] = [
            "requests": [
                "image": [
                    "content": imageData
                ],
                "features": [
                    [
                        "type": "TEXT_DETECTION",
                        "maxResults": 10
                    ]
                ]
            ]
        ]
        
        // Serialize the JSON
        request.httpBody = try! JSONSerialization.data(withJSONObject: jsonRequest, options: [])
        
        // Run the request on a background thread
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            
            self.runRequestOnBackgroundThread(request)
        });
    }
    
    func runRequestOnBackgroundThread(_ request: NSMutableURLRequest) {
        
        let session = URLSession.shared
        
        // run the request
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            self.analyzeResults(data!)
            
            return()
        })
        
        task.resume()
        
    }
    
    func analyzeResults(_ dataToParse: Data) {
        
        // Update UI on the main thread
        DispatchQueue.main.async(execute: {
            
            
            // Use SwiftyJSON to parse results
            let json = JSON(data: dataToParse)
            let errorObj: JSON = json["error"]
            
            // Check for errors
            if (errorObj.dictionaryValue != [:]) {
                self.textView.text = "Error code \(errorObj["code"]): \(errorObj["message"])"
            } else {
                // Parse the response
                print(json)
                let responses: JSON = json["responses"][0]
                
                // Get label annotations
                let labelAnnotations: JSON = responses["textAnnotations"]
                let numLabels: Int = labelAnnotations.count
                var labels: Array<String> = []
                if numLabels > 0 {
                    var labelResultsText:String = ""
                    
                    let label = labelAnnotations[0]["description"].stringValue
                    labels.append(label)
                    for label in labels {
                        // if it's not the last item add a comma
                        if labels[labels.count - 1] != label {
                            labelResultsText += "\(label), "
                        } else {
                            labelResultsText += "\(label)"
                        }
                    }
                    
                    var x = labelResultsText;
                    
                    let q = TranslateQuery(sourceString: x, optional: "", optional: self.language, withKey: self.TRANSLATE_KEY)
                    let a = q.translate()
                    if (a == true) {
                        x = q.queryResult
                    }
                    else {
                        x = labelResultsText
                    }
                    self.textView.text = x
                } else {
                    self.textView.text = "No text found"
                }
            }
            self.removeActivityIndicator()
        })
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "checkIngredients" {
            
            //let object = ["nuts","my","name"] as NSArray!
            
            
            let object = textView.text;
            
            //print(textView.text);
            
            
            
            (segue.destination as! GetIngredientsViewController).ingredient = object!;
            }
        }
    }



extension TakePictureViewController {
    
}
