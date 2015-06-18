//
//  main.m
//  BmobFastStart
//
//  Created by Bmob on 14-5-20.
//  Copyright (c) 2014年 bmob. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

#import <BmobSDK/Bmob.h>

int main(int argc, char * argv[])
{
    //此处填入应用key
    [Bmob registerWithAppKey:@"xxxxxxxxxxxxx"];
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
