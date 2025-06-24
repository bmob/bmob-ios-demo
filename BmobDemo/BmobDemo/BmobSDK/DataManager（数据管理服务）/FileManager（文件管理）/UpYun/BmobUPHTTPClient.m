//
//  UPHTTPClient.m
//  UPYUNSDK
//
//  Created by DING FENG on 11/30/15.
//  Copyright © 2015 DING FENG. All rights reserved.
//

#import "BmobUPHTTPClient.h"
#import "BmobUPMultipartBody.h"


@interface BmobUPHTTPClient() <NSURLSessionDelegate>

@property (copy) HttpProgressBlock progressBlock;
@property (copy) HttpSuccessBlock successBlock;
@property (copy) HttpFailBlock failureBlock;

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionTask *sessionTask;
@property (nonatomic, strong) NSMutableData *didReceiveData;
@property (nonatomic, strong) NSURLResponse *didReceiveResponse;
@property (nonatomic, assign) BOOL didCompleted;

@property (nonatomic, assign) NSTimeInterval timeoutForRequest;
@property (nonatomic, assign) NSTimeInterval timeoutForResource;

@end


@implementation BmobUPHTTPClient

- (id)init {
    self = [super init];
    if (self) {
        _didCompleted = NO;
    }
    return self;
}

- (void)cancel {
    [_sessionTask cancel];
}

- (void)timeoutIntervalForRequest:(NSTimeInterval)timeoutForRequest {
    self.timeoutForRequest = timeoutForRequest;
}
- (void)timeoutIntervalForResource:(NSTimeInterval)timeoutForResource {
    self.timeoutForResource = timeoutForResource;
}

- (NSMutableData *)didReceiveData {
    if (!_didReceiveData) {
        _didReceiveData = [[NSMutableData alloc]init];
    }
    return _didReceiveData;
}

- (NSURLSession *)session {
    if (!_session) {
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        sessionConfig.timeoutIntervalForRequest = self.timeoutForRequest;
        //sessionConfig.timeoutIntervalForResource = self.timeoutForResource;
        _session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}

- (void)uploadRequest:(NSMutableURLRequest *)request
              success:(HttpSuccessBlock)successBlock
              failure:(HttpFailBlock)failureBlock
             progress:(HttpProgressBlock)progressBlock {
    //发起请求
    [request setValue:@"2" forHTTPHeaderField:@"x-upyun-api-version"];
    _progressBlock = progressBlock;
    _successBlock = successBlock;
    _failureBlock = failureBlock;
    _sessionTask = [self.session dataTaskWithRequest:request];
    
    [_sessionTask resume];
}

#pragma mark NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    if (!_didCompleted) {
        if (_progressBlock) {
            _progressBlock(totalBytesSent, totalBytesExpectedToSend);
        }
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    _didCompleted = YES;
    if (error) {
        if (_failureBlock) {
            NSError *upError = error;
            if (upError.code < NSURLErrorTimedOut &&
                upError.code > NSURLErrorCannotLoadFromNetwork
                ) {
                upError = [[NSError alloc] initWithDomain:@"BmobUPHTTPClient" code:error.code
                                                 userInfo:@{@"message":error.localizedDescription}];
            }
            _failureBlock(upError);
            
        }
    } else {
        //判断返回状态码错误。
        NSInteger statusCode =((NSHTTPURLResponse *)_didReceiveResponse).statusCode;
        NSIndexSet *succesStatus = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 100)];
        if ([succesStatus containsIndex:statusCode]) {
            if (_successBlock) {
                _successBlock(_didReceiveResponse , _didReceiveData);
            }
        } else {
            NSString *errorString = [[NSString alloc] initWithData:_didReceiveData encoding:NSUTF8StringEncoding];
            NSError *upError = [[NSError alloc] initWithDomain:@"BmobUPHTTPClient"
                                                          code:statusCode
                                                      userInfo:@{@"message":errorString}];
            if (_failureBlock) {
                _failureBlock(upError);
            }
        }
    }
    
    [self cleanParam];
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    
    completionHandler(NSURLSessionResponseAllow);
    _didReceiveResponse = response;
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    [self.didReceiveData appendBytes:data.bytes length:data.length];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition,
                             NSURLCredential *credential))completionHandler {
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        
        completionHandler(NSURLSessionAuthChallengeUseCredential,
                          [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]);
    }
}

#pragma mark NSProgress KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"fractionCompleted"]) {
        NSProgress *progress = (NSProgress *)object;
        if (_progressBlock) {
            _progressBlock(progress.completedUnitCount, progress.totalUnitCount);
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)cleanParam {
    _session = nil;
    _sessionTask = nil;
    _failureBlock = nil;
    _progressBlock = nil;
    _successBlock = nil;
}

- (void)dealloc {
//    NSLog(@"uphttp client dealloc");
}

@end
