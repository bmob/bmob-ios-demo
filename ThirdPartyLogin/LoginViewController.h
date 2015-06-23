//
//  LoginViewController.h
//  ThirdPartyLogin
//
//  Created by limao on 15/6/22.
//  Copyright (c) 2015年 limaofuyuanzhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TencentOpenAPI/TencentOAuth.h>

@interface LoginViewController : UIViewController<TencentSessionDelegate>
@property (nonatomic, retain)TencentOAuth *tencentOAuth;
@end
