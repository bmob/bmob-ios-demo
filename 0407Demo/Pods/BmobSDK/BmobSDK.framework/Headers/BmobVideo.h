//
//  BmobStreamMedia.h
//  BmobSDK
//
//  Created by Bmob on 15-1-13.
//  Copyright (c) 2015年 donson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BmobConfig.h"
#import "BmobSliceTask.h"
#import "BmobSliceResult.h"



@interface BmobVideo : NSObject

/**
 *  提交切片请求
 *
 *  @param task     切片的请求数据
 *  @param block    切片的结果信息
 *  @param progress 切片的进度
 */
+(void)submitSliceTask:(BmobSliceTask *)task
                 block:(BmobSliceResultBlock)block
              progress:(BmobProgressBlock)progress;

/**
 *  获取m3u8的地址
 *
 *  @param filename m3u8的文件名
 *  @param block    结果信息
 */
+(void)requestVideoUrlWithM3u8Filename:(NSString *)filename
                                 block:(void(^)(NSString *address,NSError * error))block;
@end
