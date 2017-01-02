//
//  GetIngredientsViewController.swift
//  AllergyScannerTabbed
//
//  Created by nikash khanna on 8/10/15.
//  Copyright (c) 2015 nikash khanna. All rights reserved.
//

import UIKit

class GetIngredientsViewController: UIViewController {
    var ingredientsArr = [String]()
    
    @IBOutlet weak var resultLabel: UILabel!
    
    @IBOutlet var infoTextView: UITextView!
    
    @IBOutlet var titleLabel: UILabel!
    
    var ingredient: String = ""
    
    func configureView () {
        
        _ = [String]()
        let ingredients: String = ingredient;
        ingredientsArr = ingredients.components(separatedBy: ", ")
        print(ingredientsArr)
        var match = false;
        var violations = [String]();
        _ = false
        _ = false
        
        var totalAllergens = [String]();
        
        _ = Bundle.main.path(forResource: "altAllergenNames", ofType: "txt")
  
        // total allergen list = user's list + alternate allergens
        totalAllergens += userAllergies
        
        // get list of alternate allergens based on user's list
        for a in userAllergies {
            for i in alternateAllergies.keys {
                if a.caseInsensitiveCompare(i) == ComparisonResult.orderedSame || a.lowercased().range(of: i.lowercased()) != nil || i.lowercased().range(of: a.lowercased()) != nil{
                    totalAllergens += alternateAllergies[i]!
                }
            }
        }
        
        //check to see if user enters an alternate allergen, add the key
        for i in userAllergies {
            for j in alternateAllergies.keys {
                for k in alternateAllergies[j]! {
                    if i.caseInsensitiveCompare(k) == ComparisonResult.orderedSame || i.lowercased().range(of: k.lowercased()) != nil || k.lowercased().range(of: i.lowercased()) != nil{
                        totalAllergens.append(j);
                    }
                }
            }
        }
        
        // match total allergies with ingredient list
        for i in  totalAllergens{
            for j in ingredientsArr {
                if j.lowercased().range(of: i.lowercased()) != nil || i.lowercased().range(of: j.lowercased()) != nil{
                    violations.append(j.lowercased());
                    match = true;
                }
            }
        }
        
        if match == false{
            //resultLabel.backgroundColor = UIColor.greenColor();
            resultLabel.text = "No Potential Allergen!"
        }
        else {
            resultLabel.backgroundColor = UIColor.red
            resultLabel.text = "ALERT!"
            _ = ""
            _ = 0;
            
            violations = uniq(violations);
            
            
            for x in 0 ..< violations.count {
                for y in x ..< violations.count {
                    if violations[x].lowercased() == violations[y].lowercased() + "s" ||  violations[y].lowercased() == violations[x].lowercased() + "s"{
                        violations.remove(at: y)
                    }
                }
            }
            
            let multiLineString = violations.joined(separator: "\n")
            
            let info = "\(multiLineString)"
            
            infoTextView!.layer.borderWidth = 3
            infoTextView!.layer.borderColor = UIColor.red.cgColor
            
            //infoTextView.font = UIFont(name: "Times New Roman", size: 21)
            
            infoTextView.text = info
            infoTextView.textColor = UIColor.init(red: 204, green: 0, blue: 0, alpha: 1)
            //titleLabel.textColor = UIColor.redColor()
            titleLabel.text = "This Food Contains:"
            
        }
    }
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        // Do any additional setup after loading the view.
        //self.tabBarController?.tabBar.barTintColor = UIColor.lightGrayColor()
        self.navigationController?.navigationBar.barTintColor = UIColor.groupTableViewBackground
        
        self.tabBarController?.tabBar.barTintColor = UIColor.groupTableViewBackground
    
        let path = Bundle.main.path(forResource: "altAllergenNames", ofType: "txt")
        var text = try! String(contentsOfFile: path!, encoding: String.Encoding.utf8)
        //println(text)
   
        resultLabel.layer.masksToBounds = true
        resultLabel.layer.cornerRadius = 8.0
        
        
        titleLabel.layer.masksToBounds = true
        titleLabel.layer.cornerRadius = 8.0
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func uniq<S : Sequence, T : Hashable>(_ source: S) -> [T] where S.Iterator.Element == T {
        var buffer = [T]()
        var added = Set<T>()
        for elem in source {
            if !added.contains(elem) {
                buffer.append(elem)
                added.insert(elem)
            }
        }
        return buffer
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) 
    
    }
    */

}
