//
//  CheckUtil.h
//  ThirdPartyLogin
//
//  Created by limao on 15/6/22.
//  Copyright (c) 2015年 limaofuyuanzhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CheckUtil : NSObject

+ (BOOL) isStrEmpty:(NSString*)string;

+ (void) showAlertWithMessage:(NSString*)message delegate:(id)delegate;

@end


