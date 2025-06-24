//
//  UpYunParallelBlockUpLoader.m
//  UpYunSDKDemo
//
//  Created by lingang on 2019/3/18.
//  Copyright © 2019 upyun. All rights reserved.
//

#import "UpYunConcurrentBlockUpLoader.h"
#import "UpSimpleHttpClient.h"
#import "UpYunFileDealManger.h"


NSString *ErrorDomain = @"NSErrorDomain_UpYunParallelBlockUpLoader";
NSString *TaskRecords = @"kUpYunParallelBlockUpLoaderTasksRecords";
NSString *TaskRecordsDir = @"/UpYunParallelBlockUpLoader";

typedef NS_ENUM(NSUInteger, UYBlockState) {
    UYBlockStateUnUpload = 1,
    UYBlockStateUploading = 2,
    UYBlockStateUploaded = 3,
    UYBlockStateDefault = UYBlockStateUnUpload
};


NSString * const kBlockMD5Hash = @"UY_BlockMD5Hash";
NSString * const kBlockRange = @"UY_BlockRange";
NSString * const kBlockIndex = @"UY_BlockIndex";
NSString * const kUploadstate = @"UY_UploadState";

@interface UYFileBlock : NSObject<NSCoding>
/// 文件分块数据的 MD5
@property (nonatomic, copy) NSString *blockMD5Hash;
/// 文件分块所在的 范围
@property (nonatomic, copy) NSString *blockRange;
/// 文件分块序号
@property (nonatomic, assign) NSUInteger blockIndex;
/// 文件分块 上传状态, 默认未上传
@property (nonatomic, assign) UYBlockState uploadState;

@end

@implementation UYFileBlock

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [aCoder encodeObject:_blockMD5Hash forKey:kBlockMD5Hash];
    [aCoder encodeObject:_blockRange forKey:kBlockRange];
    [aCoder encodeInteger:_blockIndex forKey:kBlockIndex];
    [aCoder encodeInteger:_uploadState forKey:kUploadstate];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    _blockMD5Hash = [aDecoder decodeObjectForKey:kBlockMD5Hash];
    _blockRange = [aDecoder decodeObjectForKey:kBlockRange];
    _blockIndex = [aDecoder decodeIntegerForKey:kBlockIndex];
    _uploadState = [aDecoder decodeIntegerForKey:kUploadstate];
    return self;
}

@end


NSString * const kUYFileInfo = @"UY_UYFileInfo";
NSString * const kUploaderIdentity = @"UY_UploaderIdentity";
NSString * const kX_Upyun_Multi_Uuid = @"UY_X_Upyun_Multi_Uuid";
NSString * const kTimestamp = @"UY_Timestamp";
NSString * const kFileMD5Hash = @"UY_FileMD5Hash";
NSString * const kFileSize = @"UY_FileSize";
NSString * const kBlocks = @"UY_Blocks";
@interface UYFileInfo : NSObject<NSCoding>
/// 文件任务 启动时间
@property (nonatomic, copy) NSString *timestamp;
/// 文件任务 服务端 标识
@property (nonatomic, copy) NSString *X_Upyun_Multi_Uuid;
/// 文件 md5
@property (nonatomic, copy) NSString *fileMD5Hash;
/// 文件大小
@property (nonatomic, copy) NSString *fileSize;
/// 文件分块属性, 包含已经上传/未上传
@property (nonatomic, copy) NSArray<UYFileBlock *> *blocks;

/// 未上传 成功的文件分块
@property (nonatomic, strong) NSMutableDictionary *unUploadedBlocks;

/// 上传中的文件分块
@property (nonatomic, strong) NSMutableDictionary *uploadingBlocks;


- (void)updateblockWithIndex: (NSUInteger)index State:(UYBlockState)state;
- (NSUInteger)getUnUploadBlockIndex;
- (NSUInteger)getUploadingBlockIndex;

@end

@implementation UYFileInfo

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [aCoder encodeObject:_X_Upyun_Multi_Uuid forKey:kX_Upyun_Multi_Uuid];
    [aCoder encodeObject:_timestamp forKey:kTimestamp];
    [aCoder encodeObject:_fileMD5Hash forKey:kFileMD5Hash];
    [aCoder encodeObject:_fileSize forKey:kFileSize];
    [aCoder encodeObject:_blocks forKey:kBlocks];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    _X_Upyun_Multi_Uuid = [aDecoder decodeObjectForKey:kX_Upyun_Multi_Uuid];
    _timestamp = [aDecoder decodeObjectForKey:kTimestamp];
    _fileMD5Hash = [aDecoder decodeObjectForKey:kFileMD5Hash];
    _fileSize = [aDecoder decodeObjectForKey:kFileSize];
    _blocks = [aDecoder decodeObjectForKey:kBlocks];

    NSMutableDictionary *unUpload = @{}.mutableCopy;
    /// 解压的时候. 没有完成的任务. 都要重新上传
    for (UYFileBlock *block in _blocks) {
        if (block.uploadState != UYBlockStateUploaded) {
            [unUpload setObject:block forKey:@(block.blockIndex).stringValue];
        }
    }
    _unUploadedBlocks = unUpload;
    _uploadingBlocks = @{}.mutableCopy;
    return self;
}

- (void)setBlocks:(NSArray<UYFileBlock *> *)blocks {
    _blocks = blocks;
    NSMutableDictionary *unUpload = @{}.mutableCopy;
    NSMutableDictionary *uploading = @{}.mutableCopy;
    for (UYFileBlock *block in _blocks) {
        if (block.uploadState == UYBlockStateUnUpload) {
            [unUpload setObject:block forKey:@(block.blockIndex).stringValue];
        } else if (block.uploadState == UYBlockStateUploading) {
            [uploading setObject:block forKey:@(block.blockIndex).stringValue];
        }
    }
    _unUploadedBlocks = unUpload;
    _uploadingBlocks = uploading;
}

- (void)updateblockWithIndex: (NSUInteger)index State:(UYBlockState)state {
    /// 加锁是为了防止多线程 并发 导致更新未完成数据错乱, 引起读取错误
    @synchronized (self) {
        if (_blocks.count <= index) {
            NSLog(@"updateblockWithIndex --越界");
            return;
        }
        UYFileBlock *block = [_blocks objectAtIndex:index];
        block.uploadState = state;

        switch (state) {
                case UYBlockStateUnUpload: {
                    [_uploadingBlocks removeObjectForKey:@(index).stringValue];
                    [_unUploadedBlocks setObject:block forKey:@(index).stringValue];
                    break;
                }
            case UYBlockStateUploading: {
                    [_unUploadedBlocks removeObjectForKey:@(index).stringValue];
                    [_uploadingBlocks setObject:block forKey:@(index).stringValue];
                    break;
                }
            case UYBlockStateUploaded: {
                    [_uploadingBlocks removeObjectForKey:@(index).stringValue];
                    break;
                }
        }
    }
}

- (NSUInteger)getUnUploadBlockIndex {
    /// 加锁是为了防止多线程 并发 导致更新未完成数据错乱, 引起读取错误
    @synchronized (self) {
        NSString *index = _unUploadedBlocks.allKeys.firstObject;
        if (index) {
            return index.integerValue;
        }
        return NSUIntegerMax;
    }
}

- (NSUInteger)getUploadingBlockIndex {
    /// 加锁是为了防止多线程 并发 导致更新未完成数据错乱, 引起读取错误
    @synchronized (self) {
        NSString *index = _uploadingBlocks.allKeys.firstObject;
        if (index) {
            return index.integerValue;
        }
        return NSUIntegerMax;
    }
}

@end
#pragma mark ------ UpYunConcurrentBlockUpLoader


@interface UpYunConcurrentBlockUpLoader()
/// 上传策略.or 上传参数
@property (nonatomic, copy) NSDictionary *policy;
/// 签名认证
@property (nonatomic, copy) NSString *signature;

/// 服务名
@property (nonatomic, copy) NSString *bucketName;
/// 操作员名
@property (nonatomic, copy) NSString *operatorName;
/// 操作员密码
@property (nonatomic, copy) NSString *operatorPassword;
/// 文件路径
@property (nonatomic, copy) NSString *filePath;
/// 文件在服务空间的存储路径. 相对路径
@property (nonatomic, copy) NSString *savePath;

@property (nonatomic, strong) UpLoaderSuccessBlock successBlock;
@property (nonatomic, strong) UpLoaderFailureBlock failureBlock;
@property (nonatomic, strong) UpLoaderProgressBlock progressBlock;
/// 上传任务信息. 初始化之前创建. 已存在则读取
@property (nonatomic, strong) UYFileInfo *fileInfo;

/// 上传信息更新队列, 串行
@property (nonatomic, strong) dispatch_queue_t uploaderQueue;
/// 利用信号量来控制并发 HTTP
@property (nonatomic, strong) dispatch_semaphore_t uploadSemaphore;
/// 一次上传文件的特征值。特征值相同，上传成功后的结果相同（文件内容和保存路径)。
@property (nonatomic, copy) NSString *taskID;

/// 是否已经取消
@property (nonatomic, assign) BOOL cancelled;
/// 是否已经进入结束步骤
@property (nonatomic, assign) BOOL completing;
/// 存储 HTTP 任务的
@property (nonatomic, strong) NSMutableArray *httpTasks;

/// 文件处理任务 参数 可为 nil
@property (nonatomic, copy) NSArray *tasks;
/// 文件处理回调地址, 可为 nil
@property (nonatomic, copy) NSString *notify_url;

@end


@implementation UpYunConcurrentBlockUpLoader

- (void)deleteTask {

}

- (void)cancel {
    dispatch_async(_uploaderQueue, ^(){
        _cancelled = YES;
        _completing = NO;
        for (UpSimpleHttpClient *client in _httpTasks) {
            [client cancel];
        }
        [_httpTasks removeAllObjects];

        _httpTasks = nil;
    });
}

- (void)canceledEnd {
    dispatch_async(_uploaderQueue, ^(){
        if (_failureBlock) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"Upload task cancelled"};
            NSError * error = [[NSError alloc] initWithDomain:ErrorDomain code: - 101 userInfo: userInfo];
            _failureBlock(error, nil, nil);
        }
        [self clean];
    });
}

- (void)clean {
    _successBlock = nil;
    _failureBlock = nil;
    _progressBlock = nil;
    for (UpSimpleHttpClient *client in _httpTasks) {
        [client cancel];
    }
    [_httpTasks removeAllObjects];
    _httpTasks = nil;
}

/// 判断是否可以续传 2024年10月25日16:49:58 magic修改
- (UYFileInfo *)checkUploadStatus {
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfFile:[self getUploaderTaskInfoFilePath] options:0 error:&error];
    if (error) {
        NSLog(@"读取文件时出错: %@", error);
        return nil;
    }

    NSError *unarchiveError = nil;
    UYFileInfo *fileInfo = [NSKeyedUnarchiver unarchivedObjectOfClass:[UYFileInfo class] fromData:data error:&unarchiveError];
    if (unarchiveError) {
        NSLog(@"解档时出错: %@", unarchiveError);
        return nil;
    }

    /// 未找到对应的断点任务
    if (fileInfo == nil) {
        NSLog(@"未找到断点任务数据");
        return nil;
    }

    // 分块上传阶段的失败或者取消。
    NSInteger timestamp = fileInfo.timestamp.integerValue;
    NSInteger timePast = [[NSDate date] timeIntervalSince1970] - timestamp;
    if (timestamp > 0 && timePast >= 86400) {
        NSLog(@"已上传分块，最长保存时间是 24 小时。您的分块已经过期，无法进行续传，现在进行重新上传");
        [self deleteUploaderTaskInfo];
        return nil;
    }

    return fileInfo;
}

#pragma mark - 上传方法

- (void)uploadWithBucketName:(NSString *)bucketName
                      policy:(NSDictionary *)policy
                   signature:(NSString *)signature
                    filePath:(NSString *)filePath
                     success:(UpLoaderSuccessBlock)successBlock
                     failure:(UpLoaderFailureBlock)failureBlock
                    progress:(UpLoaderProgressBlock)progressBlock {

    return [self uploadWithBucketName:bucketName policy:policy signature:signature filePath:filePath notify_url:nil tasks:nil success:successBlock failure:failureBlock progress:progressBlock];
}

- (void)uploadWithBucketName:(NSString *)bucketName
                      policy:(NSDictionary *)policy
                   signature:(NSString *)signature
                    filePath:(NSString *)filePath
                  notify_url:(NSString *)notify_url
                       tasks:(NSArray *)tasks
                     success:(UpLoaderSuccessBlock)successBlock
                     failure:(UpLoaderFailureBlock)failureBlock
                    progress:(UpLoaderProgressBlock)progressBlock {
    _policy = policy;
    _signature = signature;

    _operatorName = [UpApiUtils getValueInPolicyDic:_policy OfKey:@"Operator"];
    _bucketName = bucketName;
    _filePath = filePath;
    NSString *uri = [UpApiUtils getValueInPolicyDic:_policy OfKey:@"URI"];
    _savePath = [uri substringFromIndex:_bucketName.length+1];

    _notify_url = notify_url;
    _tasks = tasks;
    _successBlock = successBlock;
    _failureBlock = failureBlock;
    _progressBlock = progressBlock;
    _httpTasks = @[].mutableCopy;


    if (_operatorName.length == 0||
        uri.length == 0) {
        NSLog(@"参数错误");
        return;
    }

    if (_uploaderQueue) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"UpYunBlockUpLoader instance is unavailable，please create a new one."};
        NSError * error  = [[NSError alloc] initWithDomain:ErrorDomain
                                                      code: -102
                                                  userInfo: userInfo];
        NSLog(@"error %@",error);
        if (failureBlock) {
            failureBlock(error, nil, nil);
        }
        return;
    }
    _uploaderQueue = dispatch_queue_create("UpYunBlockUpLoader.uploaderQueue", DISPATCH_QUEUE_SERIAL);

    _taskID = [NSString stringWithFormat:@"bucketName=%@&operatorName=%@&savePath=%@&file=%@",
               _bucketName,
               _operatorName,
               _savePath,
               [UpApiUtils getMD5HashOfFileAtPath:_filePath]];

    dispatch_async(_uploaderQueue, ^(){
        if (_cancelled) {
            /// 任务已经被取消
            [self canceledEnd];
            return;
        }
        _fileInfo = [self checkUploadStatus];
        if (_fileInfo) {
            ///断点续传
            [self beginUploadFileBlock];
        } else {
            /// 崭新的上传
            _fileInfo = [self fileBlocksInfo:filePath];
            [self initiate];
        }
        if (_progressBlock) {
            //上传进度设置为 0
            _progressBlock(0, _fileInfo.fileSize.integerValue);
        }
    });
}


- (void)uploadWithBucketName:(NSString *)bucketName
                    operator:(NSString *)operatorName
                    password:(NSString *)operatorPassword
                    filePath:(NSString *)filePath
                    savePath:(NSString *)savePath
                     success:(UpLoaderSuccessBlock)successBlock
                     failure:(UpLoaderFailureBlock)failureBlock
                    progress:(UpLoaderProgressBlock)progressBlock {
    [self uploadWithBucketName:bucketName operator:operatorName password:operatorPassword filePath:filePath savePath:savePath notify_url:nil tasks:nil success:successBlock failure:failureBlock progress:progressBlock];
}


- (void)uploadWithBucketName:(NSString *)bucketName
                    operator:(NSString *)operatorName
                    password:(NSString *)operatorPassword
                    filePath:(NSString *)filePath
                    savePath:(NSString *)savePath
                  notify_url:(NSString *)notify_url
                       tasks:(NSArray *)tasks
                     success:(UpLoaderSuccessBlock)successBlock
                     failure:(UpLoaderFailureBlock)failureBlock
                    progress:(UpLoaderProgressBlock)progressBlock {

    _bucketName = bucketName;
    _operatorName = operatorName;
    _operatorPassword = operatorPassword;
    _filePath = filePath;
    _savePath = savePath;
    _notify_url = notify_url;
    _tasks = tasks;
    _successBlock = successBlock;
    _failureBlock = failureBlock;
    _progressBlock = progressBlock;
    _httpTasks = @[].mutableCopy;

    if (_uploaderQueue) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"UpYunBlockUpLoader instance is unavailable，please create a new one."};
        NSError * error  = [[NSError alloc] initWithDomain:ErrorDomain
                                                      code: -102
                                                  userInfo: userInfo];
        NSLog(@"error %@",error);
        if (failureBlock) {
            failureBlock(error, nil, nil);
        }
        return;
    }
    _uploaderQueue = dispatch_queue_create("UpYunBlockUpLoader.uploaderQueue", DISPATCH_QUEUE_SERIAL);

    _taskID = [NSString stringWithFormat:@"bucketName=%@&operatorName=%@&savePath=%@&file=%@",
               _bucketName,
               _operatorName,
               _savePath,
               [UpApiUtils getMD5HashOfFileAtPath:_filePath]];

    dispatch_async(_uploaderQueue, ^(){
        if (_cancelled) {
            /// 任务已经被取消
            [self canceledEnd];
            return;
        }
        _fileInfo = [self checkUploadStatus];
        if (_fileInfo) {
            ///断点续传
            [self beginUploadFileBlock];
        } else {
            /// 崭新的上传
            _fileInfo = [self fileBlocksInfo:filePath];
            [self initiate];
        }
        if (_progressBlock) {
            //上传进度设置为 0
            _progressBlock(0, _fileInfo.fileSize.integerValue);
        }
    });
}

//分块上传步骤1: 初始化
- (void)initiate {
    if (_cancelled) {
        /// 任务已经被取消
        [self canceledEnd];
        return;
    }

    NSString *x_upyun_multi_stage = @"initiate";
    NSString *x_upyun_multi_disorder = @"true";

    NSString *x_upyun_multi_length = _fileInfo.fileSize;
    NSString *content_length =  @"0";

    NSString *x_upyun_multi_type = [UpApiUtils mimeTypeOfFileAtPath:_filePath];
    
    NSString *authorization = @"";
    NSString *date = @"";
    NSString *md5 = @"";
    NSString *uri = @"";
    if (_policy.count > 0) {
        authorization = [NSString stringWithFormat:@"UPYUN %@:%@", _operatorName, _signature];
        date = [UpApiUtils getValueInPolicyDic:_policy OfKey:@"Date"];
        md5 = [UpApiUtils getValueInPolicyDic:_policy OfKey:@"Content-MD5"];
        uri = [UpApiUtils getValueInPolicyDic:_policy OfKey:@"uri"];
    } else {
        date = [UpApiUtils getNowDateStr];
        NSDictionary *uploadParameters = @{@"bucket": _bucketName,
                                           @"savePath": _savePath,
                                           @"date": date};
        uri = [NSString stringWithFormat:@"/%@/%@", uploadParameters[@"bucket"], uploadParameters[@"savePath"]];
        NSString *signature = [UpApiUtils getSignatureWithPassword:_operatorPassword
                                                        parameters:@[@"PUT",
                                                                     uri,
                                                                     uploadParameters[@"date"]]];
        //http headers
        authorization = [NSString stringWithFormat:@"UPYUN %@:%@", _operatorName, signature];
    }

    NSMutableDictionary *headers = @{@"Authorization": authorization,
                @"Date": date,
                @"X-Upyun-Multi-Disorder": x_upyun_multi_disorder,
                @"X-Upyun-Multi-Stage": x_upyun_multi_stage,
                @"X-Upyun-Multi-Length": x_upyun_multi_length,
                @"Content-Length": content_length,
                @"X-Upyun-Multi-Type": x_upyun_multi_type}.mutableCopy;

    NSString *urlString = [NSString stringWithFormat:@"%@%@", UpYunStorageServer, uri];

    if (md5.length > 0) {
        [headers setObject:md5 forKey:@"Content-MD5"];
    }


    UpSimpleHttpClient *client = [UpSimpleHttpClient PUT:urlString headers:headers file:nil sendProgressBlock:^(NSProgress *progress) {

    } completionHandler:^(NSError *error, id response, NSData *body) {
        NSHTTPURLResponse *res = response;
        if (res.statusCode == 204) {
            NSDictionary *resHeaders = res.allHeaderFields;
            _fileInfo.X_Upyun_Multi_Uuid = [resHeaders objectForKey:@"x-upyun-multi-uuid"];
            if (_progressBlock ) {
                /// 初始化完成就算完成了 1%
                _progressBlock((int64_t)(_fileInfo.fileSize.integerValue * 0.01), _fileInfo.fileSize.integerValue);
            }
            [self beginUploadFileBlock];
            return;
        }

        /// 错误回调都放 _uploaderQueue 里面进行处理
        dispatch_async(_uploaderQueue, ^{
            if (_failureBlock == nil) {
                return;
            }
            NSError *newError = nil;
            //如果有 http 层错误，保留这个 error，往往是本地超时，或者网络断开错误。
            if (error == nil) {
                newError = [[NSError alloc] initWithDomain:ErrorDomain
                                                   code:res.statusCode
                                               userInfo:@{NSLocalizedDescriptionKey: @"initiate task error"}];
            }

            NSDictionary *retObj = nil;
            if (body) {
                //有返回 body 尝试按照 json 解析。
                retObj = [NSJSONSerialization JSONObjectWithData:body options:kNilOptions error:&newError];
                if (retObj == nil) {
                    // body 无法解析为 json object, 将 body 直接转化为字符串添加到 error。
                    NSString *originInfo = [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
                    NSString *des = [NSString stringWithFormat:@"json 解析错误. body: %@", originInfo];
                    newError = [[NSError alloc] initWithDomain:ErrorDomain code:res.statusCode userInfo:@{NSLocalizedDescriptionKey: des}];

                }
            }

            if (!newError) {
                newError = [[NSError alloc] initWithDomain:ErrorDomain code: -102 userInfo: retObj];
            }
            _failureBlock(newError, response, retObj);
            [self clean];
        });
    }];

    [_httpTasks addObject:client];
}
/// 开始上传块, 入口
- (void)beginUploadFileBlock {

    /// 创建总数为6的信号量, 单词最多进行 6 个 Http 请求
    _uploadSemaphore = dispatch_semaphore_create(6);
    dispatch_queue_t queue = dispatch_queue_create("UpYunBlockUpLoader.taskQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        /// 只要开始上传块, 默认结束请求都未发起
        _completing = NO;

        NSUInteger un_upload_index = [_fileInfo getUnUploadBlockIndex];

        /// 没有未上传的块, 说明上传都完成, 只剩下结束请求
        if (un_upload_index == NSUIntegerMax) {
            _completing = YES;
            dispatch_async(_uploaderQueue, ^{
                NSLog(@"没有未上传的任务, 直接发起结束请求");
                [self complete];
            });
            return ;
        }

        /// 有多少未完成块, 就发起多少个请求
        NSUInteger count = _fileInfo.unUploadedBlocks.count;

        for (int i = 0; i < count; i++) {
            /// 等待超时 时间 30 秒
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 30 * NSEC_PER_SEC);
            /// 信号量总数>0，继续执行，否则等待
            dispatch_semaphore_wait(_uploadSemaphore, time);
            [self uploadFileBlock];
        }
    });
}


/// 分块上传步骤2: 上传文件块
- (void)uploadFileBlock {
    if (_cancelled) {
        NSLog(@"任务已经被取消");
        [self canceledEnd];
        dispatch_semaphore_signal(_uploadSemaphore);
        return;
    }
    if (_completing) {
        NSLog(@"结束请求已发起");
        dispatch_semaphore_signal(_uploadSemaphore);
        return;
    }

    /// 取未上传 index
    NSUInteger unUpload_block_index = [_fileInfo getUnUploadBlockIndex];
    /// 取上传中的 index
    NSUInteger uploading_block_index = [_fileInfo getUploadingBlockIndex];

    /// 两个 index 都未取到值, 则判断该任务已经完成
    if (unUpload_block_index == NSUIntegerMax && uploading_block_index == NSUIntegerMax) {
        /// 没有未上传的任务
        if (!_completing) {
            _completing = YES;
            dispatch_async(_uploaderQueue, ^{
                NSLog(@"没有未上传的任务, 发起完成请求");
                [self complete];
            });
        }
        dispatch_semaphore_signal(_uploadSemaphore);
        return;
    }

    if (unUpload_block_index == NSUIntegerMax) {
        ///已经没有未进行上传的文件快任务 进行等待
        NSLog(@"已经没有未进行上传的文件块任务 进行等待");
        dispatch_semaphore_signal(_uploadSemaphore);
        return;
    }
    if (unUpload_block_index >= _fileInfo.blocks.count) {
        NSLog(@"文件块 index 超过文件. 数据错误. 建议任务缓存后重新上传");
        dispatch_semaphore_signal(_uploadSemaphore);
        return;
    }

    UYFileBlock *block = _fileInfo.blocks[unUpload_block_index];
    NSRange range = NSRangeFromString(block.blockRange);
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:_filePath];
    [fileHandle seekToFileOffset:range.location];
    NSData *blockData = [fileHandle readDataOfLength:range.length];

    NSUInteger blocklength = blockData.length;


    NSString *x_upyun_multi_stage = @"upload";
    NSString *x_upyun_multi_uuid = _fileInfo.X_Upyun_Multi_Uuid;
    NSString *content_length = @(blocklength).stringValue;

    NSString *authorization = @"";
    NSString *date = @"";
    NSString *md5 = @"";
    NSString *uri = @"";
    if (_policy.count > 0) {
        authorization = [NSString stringWithFormat:@"UPYUN %@:%@", _operatorName, _signature];
        date = [UpApiUtils getValueInPolicyDic:_policy OfKey:@"Date"];
        md5 = [UpApiUtils getValueInPolicyDic:_policy OfKey:@"Content-MD5"];
        uri = [UpApiUtils getValueInPolicyDic:_policy OfKey:@"uri"];
    } else {
        date = [UpApiUtils getNowDateStr];
        NSDictionary *uploadParameters = @{@"bucket": _bucketName,
                                           @"savePath": _savePath,
                                           @"date": date};
        uri = [NSString stringWithFormat:@"/%@/%@", uploadParameters[@"bucket"], uploadParameters[@"savePath"]];
        NSString *signature = [UpApiUtils getSignatureWithPassword:_operatorPassword
                                                        parameters:@[@"PUT",
                                                                     uri,
                                                                     uploadParameters[@"date"]]];
        //http headers
        authorization = [NSString stringWithFormat:@"UPYUN %@:%@", _operatorName, signature];
    }

    NSMutableDictionary *headers = @{@"Authorization": authorization,
                                     @"Date": date,
                                     @"X-Upyun-Multi-Stage": x_upyun_multi_stage,
                                     @"X-Upyun-Multi-Uuid": x_upyun_multi_uuid,
                                     @"Content-Length": content_length,
                                     @"X-Upyun-Part-Id": @(unUpload_block_index).stringValue}.mutableCopy;

    NSString *urlString = [NSString stringWithFormat:@"%@%@", UpYunStorageServer, uri];

    if (md5.length > 0) {
        [headers setObject:md5 forKey:@"Content-MD5"];
    }


    [self updateFileBlockWithIndex:unUpload_block_index State:UYBlockStateUploading];


    UpSimpleHttpClient *client = [UpSimpleHttpClient PUT:urlString headers:headers file:blockData sendProgressBlock:^(NSProgress *progress) {

    } completionHandler:^(NSError *error, id response, NSData *body) {

        NSHTTPURLResponse *res = response;
        if (res.statusCode == 204) {
            /// 上传成功. 更新 文件 block 状态 为已上传, 并进行记录
            dispatch_async(_uploaderQueue, ^(){
//                NSLog(@"当前块任务已经完成-----%lu", (unsigned long)unUpload_block_index);
                /// 上传成功. 更新 文件 block 状态 为已上传, 并进行记录
                [self updateFileBlockWithIndex:unUpload_block_index State:UYBlockStateUploaded];
                /// 进行下一次 上传
                dispatch_semaphore_signal(_uploadSemaphore);

                NSUInteger un_upload_index = [_fileInfo getUnUploadBlockIndex];
                NSUInteger uploading_index = [_fileInfo getUploadingBlockIndex];
                /// 两个 index 都未取到值, 则判断该任务已经完成
                if (un_upload_index == NSUIntegerMax && uploading_index == NSUIntegerMax) {
                    [self complete];
                }

                NSUInteger total_count = _fileInfo.blocks.count;
                /// 当前已完成
                NSUInteger upload_count = total_count - _fileInfo.unUploadedBlocks.count - _fileInfo.uploadingBlocks.count;
                if (_progressBlock) {
                    /// 初始化请求. 结束请求分别要占用 1% , 进入到上传分块, 说明初始化请求肯定完成了, 所以用 0.99
                    _progressBlock( (int64_t)(0.99 * upload_count/total_count * _fileInfo.fileSize.integerValue)  , _fileInfo.fileSize.integerValue);
                }

            });
            return;
        }
        dispatch_async(_uploaderQueue, ^(){
            /// 上传失败. 更新文件 块状态 到未上传状态
            [self updateFileBlockWithIndex:unUpload_block_index State:UYBlockStateUnUpload];
            /// 进行下一次 上传
            dispatch_semaphore_signal(_uploadSemaphore);
        });

        /// 错误回调都放 _uploaderQueue 里面进行处理
        dispatch_async(_uploaderQueue, ^{
            if (_failureBlock == nil) {
                return;
            }
            NSError *newError = nil;
            //如果有 http 层错误，保留这个 error，往往是本地超时，或者网络断开错误。
            if (error == nil) {
                newError = [[NSError alloc] initWithDomain:ErrorDomain
                                                      code:res.statusCode
                                                  userInfo:@{NSLocalizedDescriptionKey: @"upload file block error"}];
            }

            NSDictionary *retObj = nil;
            if (body) {
                //有返回 body 尝试按照 json 解析。
                retObj = [NSJSONSerialization JSONObjectWithData:body options:kNilOptions error:&newError];
                if (retObj == nil) {
                    // body 无法解析为 json object, 将 body 直接转化为字符串添加到 error。
                    NSString *originInfo = [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
                    NSString *des = [NSString stringWithFormat:@"json 解析错误. body: %@", originInfo];
                    newError = [[NSError alloc] initWithDomain:ErrorDomain code:res.statusCode userInfo:@{NSLocalizedDescriptionKey: des}];

                } else {
                    int returnDetailCode = [[retObj objectForKey:@"code"] intValue];
                    if (returnDetailCode == 40011059 || returnDetailCode == 40011062) {
                        //文件已经存在，块已经存在
                        NSLog(@"文件已上传或该文件块已经上传完成, 忽略, Code=%d, Block Index = %lu", returnDetailCode, (unsigned long)unUpload_block_index);
                        /// 上传成功. 更新 文件 block 状态 为已上传, 并进行记录
                        [self updateFileBlockWithIndex:unUpload_block_index State:UYBlockStateUploaded];
                        /// 进行下一次 上传
                        dispatch_semaphore_signal(_uploadSemaphore);
                        return ;
                    }
                }
            }

            if (!newError) {
                newError = [[NSError alloc] initWithDomain:ErrorDomain code: -102 userInfo: retObj];
            }
            _failureBlock(newError, response, retObj);
            [self clean];
        });
    }];

    [_httpTasks addObject:client];
}


//分块上传步骤3: 结束上传，合并文件
- (void)complete {
    NSString *x_upyun_multi_stage = @"complete";
    NSString *x_upyun_multi_uuid = _fileInfo.X_Upyun_Multi_Uuid;
    NSString *content_length =  @"0";

    NSString *authorization = @"";
    NSString *date = @"";
    NSString *md5 = @"";
    NSString *uri = @"";
    if (_policy.count > 0) {
        authorization = [NSString stringWithFormat:@"UPYUN %@:%@", _operatorName, _signature];
        date = [UpApiUtils getValueInPolicyDic:_policy OfKey:@"Date"];
        md5 = [UpApiUtils getValueInPolicyDic:_policy OfKey:@"Content-MD5"];
        uri = [UpApiUtils getValueInPolicyDic:_policy OfKey:@"uri"];
    } else {
        date = [UpApiUtils getNowDateStr];
        NSDictionary *uploadParameters = @{@"bucket": _bucketName,
                                           @"savePath": _savePath,
                                           @"date": date};
        uri = [NSString stringWithFormat:@"/%@/%@", uploadParameters[@"bucket"], uploadParameters[@"savePath"]];
        NSString *signature = [UpApiUtils getSignatureWithPassword:_operatorPassword
                                                        parameters:@[@"PUT",
                                                                     uri,
                                                                     uploadParameters[@"date"]]];
        authorization = [NSString stringWithFormat:@"UPYUN %@:%@", _operatorName, signature];
    }
    NSMutableDictionary *headers = @{@"Authorization": authorization,
                                     @"Date": date,
                                     @"X-Upyun-Multi-Stage": x_upyun_multi_stage,
                                     @"X-Upyun-Multi-Uuid": x_upyun_multi_uuid,
                                     @"Content-Length": content_length}.mutableCopy;
    NSString *urlString = [NSString stringWithFormat:@"%@%@", UpYunStorageServer, uri];
    if (md5.length > 0) {
        [headers setObject:md5 forKey:@"Content-MD5"];
    }


    UpSimpleHttpClient *client = [UpSimpleHttpClient PUT:urlString headers:headers file:nil sendProgressBlock:^(NSProgress *progress) {
    } completionHandler:^(NSError *error, id response, NSData *body) {
        NSDictionary *retObj = nil;
        if (body) {
            //有返回 body ：尝试按照 json 解析。注：现在断点续传结束无 body。
            retObj = [NSJSONSerialization JSONObjectWithData:body options:kNilOptions error:nil];
        }
        NSHTTPURLResponse *res = response;
        if (res.statusCode == 204 ||
            res.statusCode == 201 ||
            [[retObj objectForKey:@"code"] intValue] == 40011059) {

            if (_progressBlock) {
                /// 最后一步完成了. 所以进度为 100/100
                _progressBlock(_fileInfo.fileSize.integerValue, _fileInfo.fileSize.integerValue);
            }

            dispatch_sync(_uploaderQueue, ^{
                [self deleteUploaderTaskInfo];
            });

            /// 如果有处理任务. 则进行处理任务
            if (_tasks.count > 0 && _notify_url. length > 0) {
                UpYunFileDealManger *upDeal = [[UpYunFileDealManger alloc] init];
                [upDeal dealTaskWithBucketName:_bucketName operator:_operatorName password:_operatorPassword notify_url:_notify_url source:_savePath tasks:_tasks success:_successBlock failure:_failureBlock];
            } else {
                if (_successBlock) {
                    _successBlock(response, retObj);
                }
            }

        } else {
            if (_failureBlock) {
                if (!error) {
                    error = [[NSError alloc] initWithDomain:ErrorDomain code: -102 userInfo: retObj];
                }
                _failureBlock(error, response, retObj);
            }
        }
        [self clean];
    }];

    [_httpTasks addObject:client];
}


#pragma mark - 工具方法

- (void)jsonPrase {

}




/// 预处理获取文件信息，文件分块记录
- (UYFileInfo *)fileBlocksInfo:(NSString *)filePath {

    UYFileInfo *fileInfo = [[UYFileInfo alloc] init];
    fileInfo.fileSize = [UpApiUtils lengthOfFileAtPath:filePath];

    NSUInteger fileSize = fileInfo.fileSize.integerValue;
    NSInteger blockCount = ceil(1.0 * fileSize / UpYunFileBlcokSize);

    NSMutableArray *blocks = [[NSMutableArray alloc] init];

    for (NSUInteger i = 0; i < blockCount; i++) {
        @autoreleasepool {
            UYFileBlock *block = [[UYFileBlock alloc] init];
            block.blockIndex = i;
            block.uploadState = UYBlockStateUnUpload;

            NSUInteger location = i * UpYunFileBlcokSize;
            NSUInteger len = UpYunFileBlcokSize;
            if (i == blockCount - 1) {
                len = fileSize - location;
            }
            NSRange blockRang = NSMakeRange(location, len);
            block.blockRange = NSStringFromRange(blockRang);

            NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
            [fileHandle seekToFileOffset:location];
            NSData *fileData = [fileHandle readDataOfLength:len];
            block.blockMD5Hash = [UpApiUtils getMD5HashFromData:fileData];
            [blocks addObject:block];
        }
    }

    fileInfo.blocks = blocks.copy;
    fileInfo.fileMD5Hash = [UpApiUtils getMD5HashOfFileAtPath:filePath];
    fileInfo.timestamp = @([[NSDate date] timeIntervalSince1970]).stringValue;

    return fileInfo;
}

- (void)dealloc {
//    NSLog(@"UpYunParallelBlockUpLoader dealloc %@", self);
}

- (NSString *)getUploaderTaskInfoFilePath {
    NSString *hash = [UpApiUtils getMD5HashFromData:[NSData dataWithBytes:_taskID.UTF8String length:_taskID.length]];
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES).firstObject;


    NSString *dir = [path stringByAppendingPathComponent:TaskRecordsDir];

    NSString *filePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@.data", TaskRecordsDir, hash]];

    //判断文件夹是否存在
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:dir isDirectory:nil];
    //如果不存在则创建文件夹
    if (!fileExists) {
        NSLog(@"文件夹不存在");
        //创建文件夹
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"error=%@",error.description);
        } else {
            NSLog(@"文件夹创建成功");
        }
    }
    return filePath;
}


- (void)updateFileBlockWithIndex:(NSUInteger)index State:(UYBlockState)state {
    [_fileInfo updateblockWithIndex:index State:state];
    /// 加这个判断是  只有服务队上传成功之后才会认为确实上传成功, 上传中的状态 保存的时候也是未上传
    /// 只记录成功的部分
    if (state == UYBlockStateUploaded) {
        [self updateUploaderTaskInfo];
    }
}

/// 更新断点任务记录， 这个方法只在 _uploaderQueue 队列调用
- (void)updateUploaderTaskInfo {
    NSString *filePath = [self getUploaderTaskInfoFilePath];
    /// 对正在进行上传终止的纪录，以便下次之行续传
    [NSKeyedArchiver archiveRootObject:_fileInfo toFile:filePath];
}

/// 删除断点任务记录, 成功或超时之后. 都会删除
- (void)deleteUploaderTaskInfo {
    NSString *filePath = [self getUploaderTaskInfoFilePath];
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
}


+ (void)clearCache {
    NSString *tmpDirectory = NSTemporaryDirectory();
    NSString *upYunUploaderTaskInfoDirectory = [tmpDirectory stringByAppendingPathComponent:@"/upYunUploaderTaskInfo/"];
    [[NSFileManager defaultManager] removeItemAtPath:upYunUploaderTaskInfoDirectory error:nil];
}
@end
