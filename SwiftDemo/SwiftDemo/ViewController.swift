//
//  ViewController.swift
//  SwiftDemo
//
//  Created by Bmob on 16/5/3.
//  Copyright © 2016年 bmob. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

//        queryUsers()

//        save()

//        update()

        deleteGameScore()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func queryUsers()  {
        let query:BmobQuery = BmobUser.query()
        query.order(byDescending: "createdAt")
        query.findObjectsInBackground { (array, error) in
            for i in 0..<array?.count{
                let obj :BmobUser = (array[i] as? BmobUser)!
                print("object id \(obj.objectId),username \(obj.username)")

            }
        }
    }

    func save(){
        let gamescore:BmobObject = BmobObject(className: "GameScore")
        gamescore.setObject("Jhon Smith", forKey: "playerName")
        gamescore.setObject(90, forKey: "score")
        gamescore.saveInBackground { (isSuccessful, error) in
            if error != nil{
                print("error is \(error?.localizedDescription)")
            }else{
                print("success")
            }
        }
    }

    func update() {
        let  gamescore:BmobObject = BmobObject(outDatatWithClassName: "GameScore", objectId: "f3a82207ed")
        gamescore.setObject(91, forKey: "score")
        gamescore.updateInBackground { (isSuccessful, error) in
            if error != nil{
                print("error is \(error?.localizedDescription)")
            }else{
                print("success")
            }
        }
    }

    func deleteGameScore()  {
        let  gamescore:BmobObject = BmobObject(outDatatWithClassName: "GameScore", objectId: "4faf28f4dd")
        gamescore.deleteInBackground { (isSuccessful, error) in
            if error != nil{
                print("error is \(error?.localizedDescription)")
            }else{
                print("success")
            }
        }
    }
}

