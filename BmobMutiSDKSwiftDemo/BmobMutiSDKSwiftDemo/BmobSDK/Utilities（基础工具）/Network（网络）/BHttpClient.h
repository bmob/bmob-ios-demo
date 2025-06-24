//
//  BmobHttpClient.h
//  BmobSDK
//
//  Created by Bmob on 16/2/18.
//  Copyright © 2016年 bmob. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^HttpSuccessBlock)(NSURLResponse *response, id responseData);
typedef void(^HttpFailBlock)(NSError *error);
typedef void(^HttpProgressBlock)(int64_t completedBytesCount, int64_t totalBytesCount);

@interface BHttpClient : NSObject

@property (strong, nonatomic) NSHTTPURLResponse   *httpResponse;
@property (nonatomic, strong) NSMutableData *didReceiveData;



- (void)uploadRequest:(NSMutableURLRequest *)request
              success:(HttpSuccessBlock)successBlock
              failure:(HttpFailBlock)failureBlock
             progress:(HttpProgressBlock)progressBlock;

- (void)downloadRequest:(NSMutableURLRequest *)request
                success:(HttpSuccessBlock)successBlock
                failure:(HttpFailBlock)failureBlock
               progress:(HttpProgressBlock)progressBlock;


- (void)cancel;

- (void)timeoutIntervalForRequest:(NSTimeInterval)timeoutForRequest;
- (void)timeoutIntervalForResource:(NSTimeInterval)timeoutForResource;

@end
