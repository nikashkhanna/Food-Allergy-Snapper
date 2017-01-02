
//
//  AddAllergenViewController.swift
//  AllergyScanner
//
//  Created by nikash khanna on 8/9/15.
//  Copyright (c) 2015 nikash khanna. All rights reserved.
//

import UIKit

class AddAllergenViewController: UIViewController {
    
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

    @IBAction func goBack(_ sender: AnyObject) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var allergy: UITextField!
    
    @IBAction func addAllergen(_ sender: AnyObject) {
        if allergy.text != "" {
            userAllergies.append((allergy.text?.trimmingCharacters(in: CharacterSet.whitespaces))!);
            UserDefaults.standard.set(userAllergies, forKey: "allergies")
            displayAlert("Added Allergy!", message: "Successfully added allergen to your list of allergies!", dismiss: true);
        }
        else {
            displayAlert("No Allergens Found!", message: "Please Add an Allergen!", dismiss: false)
            allergy.text = "";
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        allergy.layer.cornerRadius = 8.0
        allergy.layer.masksToBounds = true
        allergy.layer.borderColor = UIColor( red: 0/255, green: 0/255, blue:102/255, alpha: 0.75 ).cgColor
        allergy.layer.borderWidth = 1.5
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "viewAllergies" {
            
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
