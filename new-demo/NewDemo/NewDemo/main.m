//
//  main.m
//  NewDemo
//
//  Created by Bmob on 15-1-8.
//  Copyright (c) 2015年 bmob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <BmobSDK/Bmob.h>

int main(int argc, char * argv[]) {
    @autoreleasepool {
        NSString *key = @"";
        [Bmob registerWithAppKey:key];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
