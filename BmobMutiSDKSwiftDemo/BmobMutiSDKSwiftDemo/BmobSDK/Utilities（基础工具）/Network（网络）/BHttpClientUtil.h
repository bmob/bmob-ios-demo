//
//  BHttpClientUtil.h
//  BmobSDK
//
//  Created by Bmob on 16/2/19.
//  Copyright © 2016年 bmob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "BRequestObject.h"
#import "BHttpClient.h"

typedef void(^HttpClientProgress)(CGFloat progress);

@interface BHttpClientUtil : NSObject

@property (copy, nonatomic) HttpClientProgress progressBlock;

/**
 *  初始化方法
 *
 *  @param url url地址
 *
 *  @return BHttpClientUtil实例
 */
-(instancetype)initWithUrl:(NSString *)url;

/**
 *  创建BHttpClientUtil实例
 *
 *  @param url url地址
 *
 *  @return BHttpClientUtil实例
 */
+(instancetype)requestUtilWithUrl:(NSString *)url;

/**
 *  添加参数 异步请求
 *
 *  @param dic     参数
 *  @param success 成功的回调
 *  @param fail    失败的回调
 */
-(void)addParameter:(NSDictionary *)dic successBlock:(BRequestSuccessBlock)success failBlock:(BRequestFailBlock)fail;


/**
 *  取消
 */
-(void)cancel;


-(void)setHttpMethod:(NSString *)method;


/**
 *  处理请求
 *
 *  @param request       请求的实例
 *
 */
-(void)requestWithPara:(BRequestObject *)request;
@end
