//
//  ViewController.m
//  BmobPushDemoSend
//
//  Created by limao on 15/5/6.
//  Copyright (c) 2015年 Bmob. All rights reserved.
//

#import "ViewController.h"
#import <BmobSDK/Bmob.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendMsgUseBoardcastBtn:(UIButton *)sender {
    BmobPush *push = [BmobPush push];
    //设置推送消息
    [push setMessage:@"所有人的推送的消息"];
    //发送推送
    [push sendPushInBackgroundWithBlock:^(BOOL isSuccessful, NSError *error){
        if (isSuccessful) {
            NSLog(@"boardcast successful");
        } else if (error){
        NSLog(@"error %@",[error description]);
        }
    }];
}


@end
