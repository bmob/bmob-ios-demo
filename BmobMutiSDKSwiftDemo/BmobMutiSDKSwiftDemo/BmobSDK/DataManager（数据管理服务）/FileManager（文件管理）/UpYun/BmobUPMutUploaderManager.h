//
//  UMUUploaderManager.h
//  UpYunMultipartUploadSDK
//
//  Created by Jack Zhou on 6/10/14.
//
//

#import <Foundation/Foundation.h>
#import "BmobUpYun.h"


@interface BmobUPMutUploaderManager : NSObject

#pragma mark - setup Methods

/**
 *  设置授权时间长度（秒）默认为600秒
 */
+ (void)setValidTimeSpan:(NSTimeInterval)validTimeSpan;

#pragma mark - init Method

- (instancetype)initWithBucket:(NSString *)bucket;

@property (nonatomic, copy) NSString   *dateExpiresIn;

#pragma mark - Method

/**
 *  获取文件元信息 计算policy、signature需要此信息
 *
 *  @param fileData 文件数据
 *  @param filePath 文件路径
 *  @return 获取文件元信息 字典
 */
+ (NSDictionary *)getFileInfoDicWithFileData:(NSData *)fileData OrFilePath:(NSString *)filePath ;


/**
 *  上传文件
 *
 *  @param fileData             文件数据
 *  @param policy               策略信息
 *  @param signature            签名
 *  @param progressBlock        进度回调
 *  @param completeBlock        结束回调: 当completed
 *                                   为  YES 上传成功，可以从result中获取返回信息，
 *                                   为  NO  上传失败，可以从error 获取失败信息
 */
- (void)uploadWithFile:(NSData *)fileData OrFilePath:(NSString *)filePath
                                  policy:(NSString *)policy
             signature:(NSString *)signature
             saveKey:(NSString *)saveKey
                           progressBlock:(UPProgressBlock)progressBlock
                           completeBlock:(UPCompeleteBlock)completeBlock;

/**
 *  取消所有请求
 */
- (void)cancelAllTasks;

@end
