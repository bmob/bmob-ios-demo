//
//  AppDelegate.h
//  ThirdPartyLogin
//
//  Created by limao on 15/6/22.
//  Copyright (c) 2015年 limaofuyuanzhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeiboSDK.h"
#import "WXApi.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,WeiboSDKDelegate,WXApiDelegate>


@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navigationController;

@end

