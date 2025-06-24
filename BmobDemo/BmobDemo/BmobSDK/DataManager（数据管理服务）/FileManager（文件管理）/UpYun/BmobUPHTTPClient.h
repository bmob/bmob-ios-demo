//
//  UPHTTPClient.h
//  UPYUNSDK
//
//  Created by DING FENG on 11/30/15.
//  Copyright © 2015 DING FENG. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BmobUPHTTPClient;

typedef void(^HttpSuccessBlock)(NSURLResponse *response, id responseData);
typedef void(^HttpFailBlock)(NSError *error);
typedef void(^HttpProgressBlock)(int64_t completedBytesCount, int64_t totalBytesCount);

@interface BmobUPHTTPClient : NSObject

- (void)uploadRequest:(NSMutableURLRequest *)request
              success:(HttpSuccessBlock)successBlock
              failure:(HttpFailBlock)failureBlock
             progress:(HttpProgressBlock)progressBlock;

- (void)cancel;

//默认链接超时 10s
- (void)timeoutIntervalForRequest:(NSTimeInterval)timeoutForRequest;
/// 默认不设置请求完成超时
//- (void)timeoutIntervalForResource:(NSTimeInterval)timeoutForResource;

@end
