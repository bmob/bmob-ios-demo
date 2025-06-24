//
//  UPYUNConfig.h
//  UpYunSDKDemo
//
//  Created by 林港 on 16/2/2.
//  Copyright © 2016年 upyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BmobUPYUNConfig : NSObject
+ (BmobUPYUNConfig *)sharedInstance;
/**
 *	@brief 默认空间名(必填项), 默认为 *****
 */
@property (nonatomic, copy) NSString *DEFAULT_BUCKET;
/**
 *	@brief	默认表单API密钥, 默认为 *******
 */
@property (nonatomic, copy) NSString *DEFAULT_PASSCODE;
/**
 *	@brief	默认当前上传授权的过期时间，单位为“秒” （必填项，较大文件需要较长时间)，默认1800秒
 */
@property (nonatomic, assign) NSInteger DEFAULT_EXPIRES_IN;
/**
 *	@brief	默认用户服务端生成的过期时间,防止用户手机时间不正确出现的上传错误,一般用不上
 */
@property (nonatomic, copy) NSString *DEFAULT_EXPIRES_STRING;
/**
 *	@brief 默认超过大小后走分块上传，可在init之后修改mutUploadSize的值来更改
 */
@property (nonatomic, assign) NSInteger DEFAULT_MUTUPLOAD_SIZE;
/**
 *	@brief 失败重传次数, 默认重试两次
 */
@property (nonatomic, assign) NSInteger DEFAULT_RETRY_TIMES;
/**
 *  @brief 单个分块尺寸100kb(不可小于100kb, 不超过5M)
 */
@property (nonatomic, assign) NSInteger SingleBlockSize;
/**
 *  @brief 表单Domain http://v0.api.upyun.com/
 */
@property (nonatomic, copy) NSString *FormAPIDomain;
/**
 *  @brief 分块Domain http://m0.api.upyun.com/
 */
@property (nonatomic, copy) NSString *MutAPIDomain;

@end