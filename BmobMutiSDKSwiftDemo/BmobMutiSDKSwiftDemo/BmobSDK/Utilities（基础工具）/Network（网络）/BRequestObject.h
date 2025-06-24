//
//  BRequestObject.h
//  BmobSDK
//
//  Created by Bmob on 15-2-3.
//  Copyright (c) 2015年 Bmob. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^BRequestSuccessBlock)(NSDictionary *dictionary,NSError *error);
typedef void(^BRequestFailBlock) (NSError *error);

typedef enum {
    BRequestObjectStateInit = 0,
    BRequestObjectStateDoing
}BRequestObjectState;

/**
 * 请求实体，用于存放请求参数
 */
@interface BRequestObject : NSObject

/**
 *  成功的回调
 */
@property (strong, nonatomic  ) BRequestSuccessBlock success;

/**
 *  网络失败的回调
 */
@property (strong, nonatomic  ) BRequestFailBlock    fail;

/**
 *  请求的url
 */
@property (copy, nonatomic  ) NSString             *url;

/**
 *  请求的参数
 */
@property (copy, nonatomic) NSDictionary         *para;

/**
 *  请求的状态
 */
@property (assign) BRequestObjectState  state;

/**
 *  请求的id
 */
@property (assign) int rid;

/**
 *  创建BRequestObject实例
 *
 *  @return BRequestObject实例
 */
+(instancetype)requestObject;
@end
