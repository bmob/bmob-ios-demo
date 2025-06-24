//
//  UMUUploaderManager.m
//  UpYunMultipartUploadSDK
//
//  Created by Jack Zhou on 6/10/14.
//
//

#import "BmobUPMutUploaderManager.h"
#import "NSData+BmobMD5Digest.h"
#import "NSString+BmobNSHash.h"
#import "BmobUPHTTPClient.h"
#import "BmobUPMultipartBody.h"
#import "UpYunBlockUpLoader.h"
#import "UpApiUtils.h"

static NSString *UPMUT_ERROR_DOMAIN = @"分块上传";

/**
 *  同一个bucket 上传文件时最大并发请求数
 */
static NSInteger MaxConcurrentOperationCount = 1;

/**
 *   默认授权时间长度（秒)
 */
static NSTimeInterval ValidTimeSpan = 600.0f;


@interface BmobUPMutUploaderManager()

@property (nonatomic, copy) NSString *bucket;
@property (nonatomic, copy) NSString *saveToken;
@property (nonatomic, copy) NSString *tokenSecret;
@property (nonatomic, strong) NSArray *filesStatus;
@property (nonatomic, strong) NSMutableArray *remainingFileBlockIndexs;
@property (nonatomic, strong) NSMutableArray *progressArray;
@property (nonatomic, strong) NSMutableArray *uploadingClientArray;

@property (nonatomic, assign) NSUInteger blockFailed;
@property (nonatomic, assign) NSUInteger blockSuccess;

@property (nonatomic, assign) BOOL isUploadTaskFinish;

//@property (nonatomic, strong) NSArray *blockDataArray;
@property (nonatomic, copy) NSString *filePathURL;

@end


@implementation BmobUPMutUploaderManager

- (instancetype)initWithBucket:(NSString *)bucket {
    if (self = [super init]) {
        self.bucket = bucket;
        _remainingFileBlockIndexs = [[NSMutableArray alloc]init];
        _progressArray = [[NSMutableArray alloc]init];
        _uploadingClientArray = [[NSMutableArray alloc]init];
    }
    return self;
}

#pragma mark - Setup Methods

+ (void)setValidTimeSpan:(NSTimeInterval)validTimeSpan {
    ValidTimeSpan = validTimeSpan;
}

#pragma mark - Public Methods

+ (NSDictionary *)getFileInfoDicWithFileData:(NSData *)fileData OrFilePath:(NSString *)filePath {
    NSUInteger fileSize = 0;
    NSString *fileHash = @"";
    if (filePath) {
        NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        fileSize = (NSUInteger)[fileDictionary fileSize];
        fileHash = [filePath FilePathMD5];
    } else {
        fileHash = [fileData MD5HexDigest];
        fileSize = fileData.length;
    }
    NSDictionary *parameters = @{
                                  @"file_hash":fileHash,
                                  @"file_size":@(fileSize)};
    return parameters;
}

#pragma mark Upload File

- (void)uploadWithFile:(NSData *)fileData
                        OrFilePath:(NSString *)filePath
                            policy:(NSString *)policy
                         signature:(NSString *)signature
                           saveKey:(NSString *)saveKey
                     progressBlock:(UPProgressBlock)progressBlock
                     completeBlock:(UPCompeleteBlock)completeBlock {
    [_uploadingClientArray removeAllObjects];
    _isUploadTaskFinish = NO;
    
    
    
    UpYunBlockUpLoader *uploader = [[UpYunBlockUpLoader alloc] init];
    
    
    //            typedef void(^UPSuccessBlock)(NSURLResponse *response, id responseData);
    //            typedef void(^UPFailBlock)(NSError *error);
    //            typedef void(^UPProgressBlock)(CGFloat percent, int64_t requestDidSendBytes);
    //            typedef void(^UPCompeleteBlock)(NSError *error, NSDictionary *result, BOOL completed);
    
    NSString *mBucket; // = [self.bucket stringByReplacingOccurrencesOfString:@".b0.upaiyun.com" withString:@""];
//    mBucket = [mBucket stringByReplacingOccurrencesOfString:@".b0.upaiyun.com" withString:@""];
    mBucket = [self.bucket componentsSeparatedByString:@"."][0];
    
    // bmob-cdn-13250.bmobcloud.com 去掉.后面的
//    NSString *md5 = nil;
    if(fileData){
//        md5 = [UpApiUtils getMD5HashFromData:fileData];
        
//        NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
        filePath = [NSString stringWithFormat:@"_t_%@", [saveKey componentsSeparatedByString:@"/"].lastObject];
        filePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:filePath];
        
        [fileData writeToFile:filePath options:NSDataWritingAtomic error:nil];
    }
//    if(!md5)
//        md5 = [UpApiUtils getMD5HashOfFileAtPath:filePath];
    
    
    [uploader uploadWithBucketName:mBucket operator:@"bmob" password:@"a5a15e08f251d517524383ba61f489d3" filePath:filePath savePath:saveKey success:^(NSHTTPURLResponse *response, NSDictionary *responseBody) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        if(completeBlock)
            completeBlock(nil, responseBody, YES);
    } failure:^(NSError *error, NSHTTPURLResponse *response, NSDictionary *responseBody) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        if(completeBlock){
            completeBlock(error, nil, NO);
        }
    } progress:^(int64_t completedBytesCount, int64_t totalBytesCount) {
        if(progressBlock)
            progressBlock((CGFloat)(completedBytesCount) / (CGFloat)(totalBytesCount) , completedBytesCount);
    }];
    
//    [uploader uploadWithBucketName:self.bucket policy:@{
//                                                        @"Date": [UpApiUtils getNowDateStr],
//                                                        @"URI": saveKey,
//                                                        @"Operator": @"bmob-cdn-13250",
//                                                        @"Content-MD5": @""
//                                                        } signature:signature filePath:filePath success:^(NSHTTPURLResponse *response, NSDictionary *responseBody) {
//
//                                                            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
//
//
//        if(completeBlock)
//            completeBlock(nil, responseBody, YES);
//    } failure:^(NSError *error, NSHTTPURLResponse *response, NSDictionary *responseBody) {
//        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
//
//        if(completeBlock)
//            completeBlock(error, responseBody, NO);
//    } progress:^(int64_t completedBytesCount, int64_t totalBytesCount) {
//        if(progressBlock)
//            progressBlock((CGFloat)(completedBytesCount) / (CGFloat)(totalBytesCount) , completedBytesCount);
//    }];
//    if(YES){
//        return;
//    }
    
    
    

//    // FIXME 分块上传弃用，采用断点续传
//    UPCompeleteBlock prepareUploadCompletedBlock = ^(NSError *error, NSDictionary *result, BOOL completed) {
//        if (error) {
//            completeBlock(error, nil, NO);
//        } else {
//            _filePathURL = filePath;
////            _blockDataArray = [BmobUPMutUploaderManager subDatasWithFileData:fileData];
//
//            NSDictionary *responseData = result[@"responseData"];
//            _saveToken = responseData[@"save_token"];
//            _filesStatus = responseData[@"status"];
//            _tokenSecret = responseData[@"token_secret"];
//
//            if (_saveToken.length == 0) {
//                NSString *errorString = [NSString stringWithFormat:@"返回参数错误: saveToken is null"];
//                NSError* errorInfo = [NSError errorWithDomain:UPMUT_ERROR_DOMAIN code:-1999 userInfo:@{@"message":errorString}];
//                completeBlock(errorInfo, nil, NO);
//                return;
//            }
//
//            for (int i=0; i<_filesStatus.count; i++) {
//                [_progressArray addObject:_filesStatus[i]];
//                if (![_filesStatus[i] boolValue]) {
//                    [_remainingFileBlockIndexs addObject:@(i)];
//                }
//            }
//
//
//
////            for (int i = 0; i<MaxConcurrentOperationCount; i++) {
////                [self uploadBlockIndex:i progressBlock:progressBlock completeBlock:completeBlock];
////            }
//        }
//    };
//    [self prepareUploadRequestWithPolicy:policy
//                               signature:signature
//                           completeBlock:prepareUploadCompletedBlock];
}

- (void)prepareUploadRequestWithPolicy:(NSString *)policy
                             signature:(NSString *)signature
                         completeBlock:(UPCompeleteBlock)completeBlock {
    
    [self ministrantRequestWithSignature:signature
                                  policy:policy
                           completeBlock:^(NSError *error,
                                           NSDictionary *result,
                                           BOOL completed) {
        if (!completeBlock) {
            return;
        }
        if (!error) {
            completeBlock(nil, result, YES);
        } else {
            completeBlock(error, nil, NO);
        }
    }];
}


#pragma mark Upload Block

// - (void)uploadBlockIndex:(NSInteger)index progressBlock:(UPProgressBlock)progressBlock
//            completeBlock:(UPCompeleteBlock)completeBlock {
//     if (index >= _progressArray.count) {
//         return;
//     }
    
//     NSData *blockData;
//     if (_filePathURL) {
//         blockData = [BmobUPMutUploaderManager getBlockWithFilePath:_filePathURL offset:index];
//     } else {
//         if (index >= _blockDataArray.count) {
//             return;
//         }
//         blockData = _blockDataArray[index];
//     }
    
//     __weak typeof(self)weakSelf = self;
    
//     id singleUploadProgressBlcok = ^(float percent) {
//         @synchronized(_progressArray) {
//                 _progressArray[index] = [NSNumber numberWithFloat:percent];
//                 float sumPercent = 0;
//                 for (NSNumber *num in _progressArray) {
//                     sumPercent += [num floatValue];
//                 }
//                 float totalPercent = sumPercent/_progressArray.count;
//                 progressBlock(totalPercent, 100);
//         }
//     };
    
    
//     UPCompeleteBlock singleUploadCompleteBlock = ^(NSError *error, NSDictionary *result, BOOL completed) {
//         if (_isUploadTaskFinish) {
//             return ;
//         }
//         if (!completed) {
//             if (completeBlock) {
//                 _isUploadTaskFinish = YES;
//                 completeBlock(error, nil, NO);
//             }
//             return;
//         }
//         if (completed) {
//             _blockSuccess++;
//         } else {
//             _blockFailed++;
//         }
        
//         if (_blockFailed < 1 && _blockSuccess == _remainingFileBlockIndexs.count) {
//             UPCompeleteBlock mergeRequestCompleteBlcok = ^(NSError *error, NSDictionary *result, BOOL completed) {
//                 completeBlock(error, result, completed);
//             };
//             [weakSelf fileMergeRequestWithSaveToken:_saveToken
//                                         tokenSecret:_tokenSecret
//                                       completeBlock:mergeRequestCompleteBlcok];
//         } else {
//             [weakSelf uploadBlockIndex:index+MaxConcurrentOperationCount progressBlock:progressBlock completeBlock:completeBlock];
//         }
//     };
//     [self uploadFileBlockWithSaveToken:_saveToken
//                             blockIndex:index
//                          fileBlockData:blockData
//                            tokenSecret:_tokenSecret
//                          progressBlock:singleUploadProgressBlcok
//                          completeBlock:singleUploadCompleteBlock];
    
// }
#pragma mark - Private Methods

- (void)cancelAllTasks {
    for (BmobUPHTTPClient *client in _uploadingClientArray) {
        [client cancel];
    }
    [_uploadingClientArray removeAllObjects];
}

// - (void)uploadFileBlockWithSaveToken:(NSString *)saveToken
//                           blockIndex:(NSInteger)blockIndex
//                        fileBlockData:(NSData *)fileBlockData
//                          tokenSecret:(NSString *)tokenSecret
//                        progressBlock:(void (^)(float percent))progressBlock
//                        completeBlock:(UPCompeleteBlock)completeBlock {
    
    
    
//     NSString *expiresIn = self.dateExpiresIn.length == 0 ? DATE_STRING(ValidTimeSpan) : self.dateExpiresIn;
    
    
//     NSDictionary *policyParameters = @{@"save_token":saveToken, @"expiration":expiresIn, @"block_index":@(blockIndex), @"block_hash":[fileBlockData MD5HexDigest]};
    
//     NSString *uploadPolicy = [self dictionaryToJSONStringBase64Encoding:policyParameters];
    
//     NSDictionary *parameters = @{@"policy":uploadPolicy, @"signature":[self createSignatureWithToken:tokenSecret parameters:policyParameters]};
    
//     NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BmobUPYUNConfig sharedInstance].MutAPIDomain, self.bucket]];
//     NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url.absoluteString]];
    
//     BmobUPMultipartBody *multiBody = [[BmobUPMultipartBody alloc]init];
//     [multiBody addDictionary:parameters];
    
//     NSString *fileName = [_filePathURL lastPathComponent];
//     if (!fileName) {
//         fileName = @"fileName";
//     }
//     [multiBody addFileData:fileBlockData fileName:fileName fileType:nil];

//     request.HTTPMethod = @"POST";
//     request.HTTPBody = [multiBody dataFromPart];
    
//     [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//     [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", multiBody.boundary] forHTTPHeaderField:@"Content-Type"];
    
    
//     __weak typeof(self)weakSelf = self;
//     BmobUPHTTPClient *client =  [[BmobUPHTTPClient alloc] init];
    
//     [client uploadRequest:request success:^(NSURLResponse *response, id responseData) {
//         NSError *error;
//         NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions
//                                                                error:&error];
//         if (error) {
//             NSLog(@"error %@", error);
//             completeBlock(error, nil, NO);
//         } else {
//             completeBlock(error, json, YES);
//         }
        
//         [_uploadingClientArray removeObject:client];
//     } failure:^(NSError *error) {
//         completeBlock(error, nil, NO);
//         [_uploadingClientArray removeObject:client];
//         [weakSelf cancelAllTasks];
//     } progress:^(int64_t completedBytesCount, int64_t totalBytesCount) {
//         @synchronized(self) {
//             float k = (float)completedBytesCount / totalBytesCount;
//             if (progressBlock) {
//                 progressBlock(k);
//             }
//         }
//     }];
    
//     [_uploadingClientArray addObject:client];
// }


- (void)fileMergeRequestWithSaveToken:(NSString *)saveToken
                          tokenSecret:(NSString *)tokenSecret
                        completeBlock:(void (^)(NSError * error,
                                                NSDictionary * result,
                                                BOOL completed))completeBlock {
    
    NSString *expiresIn = self.dateExpiresIn.length == 0 ? DATE_STRING(ValidTimeSpan) : self.dateExpiresIn;
    NSDictionary *parameters = @{@"save_token":saveToken,
                                  @"expiration":expiresIn};
    
    NSString *mergePolicy = [self dictionaryToJSONStringBase64Encoding:parameters];
    [self ministrantRequestWithSignature:[self createSignatureWithToken:tokenSecret
                                                             parameters:parameters]
                                  policy:mergePolicy
                           completeBlock:^(NSError *error, NSDictionary *result, BOOL completed) {
        if (completeBlock) {
            completeBlock(error, result, completed);
        }
     }];
}

- (void)ministrantRequestWithSignature:(NSString *)signature
                                policy:(NSString *)policy
                         completeBlock:(UPCompeleteBlock)completeBlock {

    NSDictionary *requestParameters = @{@"policy":policy, @"signature":signature};
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BmobUPYUNConfig sharedInstance].MutAPIDomain, self.bucket]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSMutableString *postParameters = [[NSMutableString alloc] init];
    for (NSString *key in requestParameters.allKeys) {
        NSString *keyValue = [NSString stringWithFormat:@"&%@=%@", key, requestParameters[key]];
        [postParameters appendString:keyValue];
    }
    if (postParameters.length > 1) {
        request.HTTPBody = [[postParameters substringFromIndex:1] dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    __weak typeof(self)weakSelf = self;
    BmobUPHTTPClient *client = [[BmobUPHTTPClient alloc]init];

    //暂时这样判断这是最后一个合并请求
    if (_blockSuccess > 1) {
        NSTimeInterval timeout = _blockSuccess * [BmobUPYUNConfig sharedInstance].SingleBlockSize / (1024 * 1024);
        if (timeout < 60) {
            timeout = 60;
        }
        
        [client timeoutIntervalForRequest:timeout];
    }
    
    [client uploadRequest:request success:^(NSURLResponse *response, id responseData) {
        if (completeBlock) {
            NSDictionary *resonseDic = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
            NSDictionary *result = @{@"response":response, @"responseData":resonseDic};
            completeBlock(nil, result, YES);
        }
        [_uploadingClientArray removeObject:client];
    } failure:^(NSError *error) {
        if (completeBlock) {
            completeBlock(error, nil, NO);
        }
        [_uploadingClientArray removeObject:client];
        [weakSelf cancelAllTasks];
    } progress:^(int64_t completedBytesCount, int64_t totalBytesCount) {
        
    }];
    
    [_uploadingClientArray addObject:client];
}


#pragma mark - Utils

// //计算文件块数
// + (NSInteger)calculateBlockCount:(NSUInteger)fileLength {
//     return ceil(fileLength*1.0/[BmobUPYUNConfig sharedInstance].SingleBlockSize);
// }

// //生成单个文件块
// + (NSData *)getBlockWithFilePath:(NSString *)filePath offset:(NSInteger)index {
//     NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:filePath];
//     NSInteger blockSize = [BmobUPYUNConfig sharedInstance].SingleBlockSize;
//     NSInteger startLocation = index * blockSize;
//     [handle seekToFileOffset:startLocation];
//     NSData *subData = [handle readDataOfLength:blockSize];
//     [handle closeFile];
//     return [subData copy];
// }

// FIX start: 180413 zwr, 修复切割文件时内存溢出的问题

// //生成文件块
// + (NSArray *)subDatasWithFileData:(NSData *)fileData {
//     NSInteger blockCount = [self calculateBlockCount:fileData.length];
//     NSLog(@"Start sub data length = %lu", (unsigned long)fileData.length);
//     NSMutableArray * blocks = [[NSMutableArray alloc]init];
//     NSInputStream *is = [[NSInputStream alloc]initWithData:fileData];
//     [is open];
//     NSInteger length = [BmobUPYUNConfig sharedInstance].SingleBlockSize;
//     for (int i = 0; i < blockCount;i++ ) {
//         NSInteger startLocation = i*length;
//         if (startLocation+length > fileData.length) {
//             length = fileData.length-startLocation;
//         }
//         uint8_t buff[length];
//         NSInteger count = [is read:buff maxLength:length];
//         [blocks addObject:[[NSData alloc] initWithBytes:buff length:count]];
//     }
//     [is close];
//     NSLog(@"Done sub data into %ld pieces", (long)blockCount);
//     return [blocks mutableCopy];
// }
// FIX over: 180413 zwr, 修复切割文件时内存溢出的问题


//根据token 计算签名
- (NSString *)createSignatureWithToken:(NSString *)token
                            parameters:(NSDictionary *)parameters {
    NSString *signature = @"";
    NSArray *keys = [parameters allKeys];
    keys = [keys sortedArrayUsingSelector:@selector(compare:)];
    for (NSString * key in keys) {
        NSString * value = parameters[key];
        signature = [NSString stringWithFormat:@"%@%@%@", signature, key, value];
    }
    signature = [signature stringByAppendingString:token];
    return [signature MD5];
}

- (NSString *)dictionaryToJSONStringBase64Encoding:(NSDictionary *)dic {
    NSData *paramesData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:paramesData
                                                 encoding:NSUTF8StringEncoding];
    return [jsonString Base64encode];
}

@end
