//
//  SliceResult.h
//  BmobSDK
//
//  Created by Bmob on 15-1-29.
//  Copyright (c) 2015年 donson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BmobSliceResult : NSObject

/**
 *  切片后的文件名
 */
@property (copy, nonatomic) NSString *filename;

/**
 *  是否成功
 */
@property (assign) BOOL isSuccessful;

/**
 *  如果失败了，失败的信息
 */
@property (copy, nonatomic) NSError  *error;


+(id)result;

@end
