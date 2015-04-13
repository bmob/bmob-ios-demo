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
#import <BmobSDK/BmobGPSSwitch.h>

int main(int argc, char * argv[]) {
    @autoreleasepool {
         [BmobGPSSwitch gpsSwitch:NO];
        NSString *key = @"a83ae43acd08872e6da96a3d270808ff";
        [Bmob registerWithAppKey:key];
       
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
