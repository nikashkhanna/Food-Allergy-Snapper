//
//  TranslateQuery.swift
//  Allergy Snapper
//
//  Created by nikash khanna on 6/28/16.
//  Copyright © 2016 nikash khanna. All rights reserved.
//


import Foundation

extension String {
    public func urlEncode() -> String {
        let encodedURL = CFURLCreateStringByAddingPercentEscapes(
            nil,
            self as NSString,
            nil,
            "!@#$%&*'();:=+,/?[]" as CFString!,
            CFStringBuiltInEncodings.UTF8.rawValue)
        return encodedURL as! String
    }
}

open class TranslateQuery {
    
    fileprivate let translateQuery = "https://www.googleapis.com/language/translate/v2"
    fileprivate let getLanguagesQuery = "https://www.googleapis.com/language/translate/v2/languages"
    fileprivate let detectLanguageQuery = "https://www.googleapis.com/language/translate/v2/detect"
    
    fileprivate var sourceStr:String
    fileprivate var sourceLang:String
    fileprivate var targetLang:String="en"
    fileprivate var status="error"
    fileprivate var defaultQuery:String
    fileprivate var jsonName:String
    fileprivate var parameters:NSMutableDictionary = NSMutableDictionary()
    
    var languages:Array<Language>;
    
    var queryResult:String
    var queryResultMessage:String
    
    init(sourceString:String, optional sourceLanguage:String, optional targetLanguage:String, withKey apiKey:String) {
        sourceStr = sourceString
        
        sourceLang=sourceLanguage
        if (!targetLanguage.isEmpty) {
            targetLang=targetLanguage
        }
        if (!sourceLanguage.isEmpty) {
            sourceLang=sourceLanguage
        }
        status = ""
        queryResult = ""
        queryResultMessage = "Nothing done..."
        defaultQuery = detectLanguageQuery
        jsonName = "detections"
        languages=Array<Language>()
        addParameter(named: "key", value: apiKey)
    }
    
    func translate() -> Bool {
        addParameter(named: "target",value: targetLang)
        addParameter(named: "q",value: sourceStr.urlEncode())
        let availableLangs = languages.filter { $0.targetLanguage == targetLang }
        
        if (sourceLang.isEmpty) {
            setType(TranslateQueryType.detect)
            let arrResults=runQuery()
            if (arrResults.count>0)
            {
                if let result = (arrResults.lastObject! as AnyObject).lastObject as? NSDictionary {
                    sourceLang=result["language"] as! String
                    queryResultMessage="Detected"
                }
            }
            else
            {
                queryResultMessage="Сannot determine source language"
                return false
            }
        }
        
        addParameter(named: "source",value: sourceLang)
        
        //here we should have known source and target languages
        let thisLang = languages.filter { $0.targetLanguage == targetLang && $0.supportedLanguageCode == sourceLang}
        
        //report with friendlyname of detected language
        if (!thisLang.isEmpty) {
            queryResultMessage+=" " + thisLang[0].supportedLanguageName
            queryResultMessage=queryResultMessage.trimmingCharacters(
                in: CharacterSet.whitespacesAndNewlines)
        }
        
        //now let's translate stuff
        let array = sourceStr.components(separatedBy: "\n")
        
        for translateThis in array {
            setType(TranslateQueryType.translate)
            addParameter(named: "q",value: translateThis.urlEncode())
            
            let arrResults=runQuery()
            
            if (status == "error") {
                queryResultMessage = "There was an error in the process. Make sure you have secure internet connection and are taking a picture of ingredients."
                return false
            }
            else {
                for result in arrResults {
                    for (key,val) in (result as? NSDictionary)! {
                        if (key as! String == "translatedText") {
                            queryResult+=val as! String + "\n"
                        }
                    }
                }
                
            }
        }
        return true
    }
    
    fileprivate func setType(_ type:TranslateQueryType) {
        switch type{
        case TranslateQueryType.translate:
            defaultQuery = translateQuery
            status = ""
            jsonName = "translations"
        case TranslateQueryType.get_LANGUAGES:
            defaultQuery = getLanguagesQuery
            status = ""
            jsonName = "languages"
        case TranslateQueryType.detect:
            defaultQuery = detectLanguageQuery
            status = ""
            jsonName = "detections"
        }
    }
    
    fileprivate func addParameter(named name:String, value val:String) {
        parameters.setObject(val, forKey: name as NSCopying)
    }
    
    fileprivate func runQuery() -> NSArray {
        var query:String = "\(defaultQuery)?"
        
        for (parameter, value) in parameters {
            query += "&\(parameter)=\(value)"
        }
        
        
        let request = NSMutableURLRequest(url: URL(string: query)!)
        request.httpMethod = "GET"
        request.setValue("text/plain; charset=UTF-8", forHTTPHeaderField: "content-type")
        
        var response:URLResponse?
        
        do {
            let responseData:Data = try NSURLConnection.sendSynchronousRequest(request as URLRequest, returning: &response)
            let jsonResult:NSDictionary = try JSONSerialization.jsonObject(with: responseData, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
            if (jsonResult.object(forKey: "data") != nil){
                return (jsonResult.object(forKey: "data") as! NSDictionary).object(forKey: jsonName) as! NSArray
            }
            else if(jsonResult.object(forKey: "error") != nil)
            {
                status="error"
                return (jsonResult.object(forKey: "error")as! NSDictionary).allValues as NSArray
            }
            else
            {
                return NSArray()
            }
        }
        catch
        {
            return NSArray()
        }
        
    }
    
}

class Language {
    var targetLanguage: String = ""
    var supportedLanguageCode = ""
    var supportedLanguageName = ""
    
}

private enum TranslateQueryType:Int {
    case translate = 1
    case get_LANGUAGES = 2
    case detect = 3
}
