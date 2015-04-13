//
//  ViewController.swift
//  0407Demo
//
//  Created by Bmob on 15-4-7.
//  Copyright (c) 2015年 bmob. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let button:UIButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //创建
    @IBAction func create(sender: AnyObject) {
        let gameScore : BmobObject = BmobObject(className: "GameScore")
        gameScore.setObject(NSNumber(int: 1200), forKey: "score")
        gameScore.setObject("小明", forKey: "playerName");
        gameScore.setObject(NSNumber(bool: false ), forKey: "cheatMode")
        gameScore.setObject(NSNumber(int: 18), forKey: "age");
        gameScore.setObject(BmobUser(withoutDatatWithClassName: nil, objectId: "25fb9b4a61"), forKey: "friend")
        gameScore.saveInBackgroundWithResultBlock { (isSuccessful, error) -> Void in
            if(error != nil){
                println("save failed \(error.description)")
            }else{
                println("save successfully")
            }
        }
        
        //        var dic :NSMutableDictionary = NSMutableDictionary();
        //        gameScore.saveAllWithDictionary(dic )
        
       
    }
    
    //查询
    @IBAction func query(sender: AnyObject) {
//        let bquery : BmobQuery = BmobQuery(className: "GameScore");
        //条件约束
//        bquery.whereKey("playerName", notEqualTo: "小明")
//        bquery.whereKey("age", lessThan: NSNumber(int: 18))
//        bquery.whereKey("age", lessThanOrEqualTo: NSNumber(int: 18))
//        bquery.whereKey("age", greaterThan: NSNumber(int: 18))
//        bquery.whereKey("age", greaterThanOrEqualTo: NSNumber(int: 18))
        
//        bquery.whereKey("playerName", containedIn: ["小明","小红","小白"])
//        bquery.whereKey("playerName", notContainedIn: ["小明","小红","小白"])
        
//        bquery.selectKeys(["score","playerName"]);
//        bquery.whereKeyExists("score");
//        bquery.whereKeyDoesNotExist("score");
        
//        bquery.limit = 3;
//        bquery.skip = 3;
        
//        bquery.orderByDescending("score");
//        bquery.orderByAscending("score");
//        
//        bquery.findObjectsInBackgroundWithBlock { (objs, error) -> Void in
//            for obj in objs{
//                if obj is BmobObject{
//                    println("objectId  \(obj.objectId)")
//                    println("createdAt \(obj.createdAt)")
//                    println("updatedAt \(obj.updatedAt)")
//                }
//            }
        
        var query:BmobQuery = BmobQuery(className:"Post")
        query.includeKey("author")
        query.whereKeyExists("author")
        query.findObjectsInBackgroundWithBlock({array,error in
            for obj in array{
                if obj is BmobObject{
                    var obj2:BmobObject    = obj.objectForKey("author") as! BmobObject
                    if(obj2.objectForKey("username") != nil){
                        let name: String      = obj2.objectForKey("username") as! String
                        println("name is \(name)")
                    }
                    
                    let obj3               = obj as! BmobObject
                    var classNumber:NSInteger = obj3.objectForKey("class").integerValue
                    println("class is!   \(classNumber)")
                }
            }
            }
        )
        
        var string1:String = "2"
        var string2:String = "2"
        if string1 == string2{
            println("equal to")
        }
        
        
//        let query1:BmobQuery = BmobQuery(className: "GameScore");
//        query1.whereKey("playerName", equalTo: "Barbie")
//        query1.countObjectsInBackgroundWithBlock { (number, error) -> Void in
//            println("number \(number)")
//        }
        
//        var condiction1 = ["score":["$gt":150]]
//        var condiction2 = ["score":["$lt":5]]
//        bquery.addTheConstraintByOrOperationWithArray([condiction1,condiction2])
        
//        var condiction1 = ["score":["$gt":5]]
//        var condiction2 = ["score":["$lt":150]]
//        bquery.addTheConstraintByAndOperationWithArray([condiction1,condiction2])
        
//        bquery.cachePolicy = kBmobCachePolicyNetworkElseCache;
        
//        bquery.hasCachedResult();
//        bquery.clearCachedResult();
        
//        BmobQuery.clearAllCachedResults();
    }
    
    @IBAction func update(sender: AnyObject) {
        let obj : BmobObject = BmobObject(withoutDatatWithClassName: "GameScore", objectId: "5bf5219fc6")
        obj.setObject(NSNumber(int: 1), forKey: "class");
        obj.updateInBackgroundWithResultBlock { (isSuccessful, error) -> Void in
            if (error != nil){
                println("update failed \(error.description)")
            }else{
                println("update successfully")
            }
        }
    }
    
    func update()->Void{
        let query: BmobQuery = BmobQuery(className: "GameScore")
        query.getObjectInBackgroundWithId("5bf5219fc6", block: { (obj , error) -> Void in
            if(error == nil){
                if(obj != nil){
                    let obj1 : BmobObject = BmobObject(withoutDatatWithClassName: obj.className, objectId: obj.objectId);
                    obj1.setObject(NSNumber(bool: true), forKey: "cheatMode")
                    obj1.updateInBackground()
                }
            }
        })
        
        
        
    }
    
    func del()->Void{
        let query:BmobQuery = BmobQuery(className: "GameScore")
        query.getObjectInBackgroundWithId("5bf5219fc6", block: { (obj , error) -> Void in
            if(error != nil){
            
            }else{
                if(obj != nil){
                    obj.deleteInBackground();
                }
            }
        })
    }
    
    @IBAction func oneToOne(sender: AnyObject) {
        let gameScore : BmobObject = BmobObject(className: "GameScore")
        let user : BmobUser = BmobUser(withoutDatatWithClassName: nil, objectId: "25fb9b4a61")
        gameScore.setObject(user, forKey: "user")
        gameScore.saveInBackgroundWithResultBlock { (isSuccessful, error) -> Void in
            if (isSuccessful){
                println("objectId \(gameScore.objectId)")
            }
        }
    }
    
    
    @IBAction func oneToMuch(sender: AnyObject) {
        let obj: BmobObject = BmobObject(withoutDatatWithClassName: "Post", objectId: "a1419df47a")
        let relation: BmobRelation = BmobRelation();
        relation.addObject(BmobUser(withoutDatatWithClassName: nil, objectId: "27bb999834"))
        obj.addRelation(relation, forKey: "likes")
        obj.updateInBackgroundWithResultBlock { (isSuccessful, error) -> Void in
            if error != nil{
                println("error \(error.description)")
            }
        }
    }
    
    
    func queryRelation()->Void{
        let query = BmobQuery(className: "Comment")
        query.orderByDescending("updatedAt")
        query.whereObjectKey("author", relatedTo: BmobUser(withoutDatatWithClassName: nil, objectId: "27bb999834"))
        query.findObjectsInBackgroundWithBlock { (array , error) -> Void in
            for obj in array{
                println("objectId \(obj.objectId)")
            }
        }
    }
    
    func matchInQuery()->Void{
//        let 
        
        var firstForLoop = 0
        for i in 0..<4{
        
        }
    }
    
    
    @IBAction func login(sender: AnyObject) {
        BmobUser.loginWithUsernameInBackground("007", password: "123456") { (user, error) -> Void in
            if error != nil{
                println(error)
            }else{
                println("login sucessfully")
            }
        }
    }
    
    @IBAction func addRole(sender: AnyObject) {
        let normalUserRole = BmobRole(name: "normalUser")
//        normalUserRole.name = "normalUser"; //(name: "normalUser")
        
        let normalRelation = BmobRelation()
        
        let currentUser = BmobUser.getCurrentUser()
        
        normalRelation.addObject(currentUser)
        
        normalUserRole.addUsersRelation(normalRelation)
        
        normalUserRole.saveInBackgroundWithResultBlock { (isSuccessful, error) -> Void in
            if error != nil{
                println(error)
            }else{
                println("save sucessfully")
            }
        }
    }
}

