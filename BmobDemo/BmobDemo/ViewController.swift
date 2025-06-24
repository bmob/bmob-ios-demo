//
//  ViewController.swift
//  BmobDemo
//
//  Created by dev on 2025/6/24.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.query()
    }

    func query(){
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 2){
            
            let query = BmobQuery(className: "abc")
            query?.findObjectsInBackground { list, error in
                if error != nil{
                    print("\(error?.localizedDescription)")
                }else{
                    for item in list! {
                        let model:BmobObject = item as! BmobObject
                        print("test:\(model.object(forKey: "test") ?? "")")
                    }
                }
            }
        }
        
    }
}

