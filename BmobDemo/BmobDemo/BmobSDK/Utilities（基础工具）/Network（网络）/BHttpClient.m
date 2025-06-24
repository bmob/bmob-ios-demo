//
//  BmobHttpClient.m
//  BmobSDK
//
//  Created by Bmob on 16/2/18.
//  Copyright © 2016年 bmob. All rights reserved.
//

#import "BHttpClient.h"

@interface BHttpClient() <NSURLSessionDataDelegate,NSURLSessionDelegate,NSURLSessionTaskDelegate>

@property (copy) HttpProgressBlock progressBlock;
@property (copy) HttpSuccessBlock successBlock;
@property (copy) HttpFailBlock failureBlock;

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionTask *sessionTask;
/**
 *  下载
 */
@property (strong, nonatomic) NSURLSessionDownloadTask *downloadTask;

@property (nonatomic, assign) BOOL didCompleted;

@property (nonatomic, assign) NSTimeInterval timeoutForRequest;
@property (nonatomic, assign) NSTimeInterval timeoutForResource;

@end

@implementation BHttpClient

static NSInteger STATUS_OK = 200;

- (id)init {
    self = [super init];
    if (self) {
        _didCompleted = NO;
        self.timeoutForRequest = 20.0f;
        self.timeoutForResource= 20.0f;
    }
    return self;
}


- (void)cancel {
    if (self.sessionTask) {
        [self.sessionTask cancel];
    }else{
        [self.downloadTask cancel];
    }

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
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionConfig.timeoutIntervalForRequest = self.timeoutForRequest;
        sessionConfig.timeoutIntervalForResource = self.timeoutForResource;
        
        _session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
    }
    return _session;
}



- (void)uploadRequest:(NSMutableURLRequest *)request
              success:(HttpSuccessBlock)successBlock
              failure:(HttpFailBlock)failureBlock
             progress:(HttpProgressBlock)progressBlock {
    //发起请求
    _progressBlock = progressBlock;
    _successBlock = successBlock;
    _failureBlock = failureBlock;
    _sessionTask = [self.session dataTaskWithRequest:request];
    
    [_sessionTask resume];
}


- (void)downloadRequest:(NSMutableURLRequest *)request
                success:(HttpSuccessBlock)successBlock
                failure:(HttpFailBlock)failureBlock
               progress:(HttpProgressBlock)progressBlock{
    //发起请求
    _progressBlock = progressBlock;
    _successBlock = successBlock;
    _failureBlock = failureBlock;
    _downloadTask = [self.session downloadTaskWithRequest:request];

    [_downloadTask resume];

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
                upError.code > NSURLErrorZeroByteResource
                ) {
                
            }
            _failureBlock(upError);
        }
    } else {
        //判断返回状态码错误。
        if(!task || !task.response){
            if (_failureBlock) {
                NSError *upError = [NSError errorWithDomain:@"cn.bmob.www" code:20002 userInfo:@{NSLocalizedDescriptionKey:@"connect failed"}];
                _failureBlock(upError);
            }
        }else{
            NSInteger statusCode =((NSHTTPURLResponse *)task.response).statusCode;
            //        debugLog(@"statusCode %ld",(unsigned long)statusCode);
            if (statusCode == STATUS_OK) {
                if (_successBlock) {
                    _successBlock(self.httpResponse, self.didReceiveData);
                }
            }else{

                if (_failureBlock) {
                    NSError *upError = [NSError errorWithDomain:@"cn.bmob.www" code:statusCode userInfo:@{NSLocalizedDescriptionKey:@"connect failed"}];
                    _failureBlock(upError);
                }
            }
        }
        }

    [self.session finishTasksAndInvalidate];
    self.session = nil;
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    
    completionHandler(NSURLSessionResponseAllow);

    self.httpResponse = (NSHTTPURLResponse *)response;

    
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

#pragma mark - download

-(void)URLSession:(NSURLSession *)session
     downloadTask:(NSURLSessionDownloadTask *)downloadTask
     didWriteData:(int64_t)bytesWritten
totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    if (!_didCompleted) {
        NSInteger statusCode =((NSHTTPURLResponse *)downloadTask.response).statusCode;
        if (statusCode == STATUS_OK) {
            if (_progressBlock) {
                _progressBlock(totalBytesWritten, totalBytesExpectedToWrite);
            }
        }

    }
}

-(void)URLSession:(NSURLSession *)session
     downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location{
    [self.didReceiveData appendData:[NSData dataWithContentsOfURL:location]];
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


@end
