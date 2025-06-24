//
//  UpYunParallelBlockUpLoader.h
//  UpYunSDKDemo
//
//  Created by lingang on 2019/3/18.
//  Copyright © 2019 upyun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UpYunUploader.h"

/*实现的存储接口及文档
 REST API。文档地址：https://help.upyun.com/knowledge-base/rest_api/#e5b9b6e8a18ce5bc8fe696ade782b9e7bbade4bca0
 认证鉴权－在 Header 中包含签名。 文档地址：http://docs.upyun.com/api/authorization/#header
 */


@interface UpYunConcurrentBlockUpLoader : NSObject

/**并行式断点续传接口
 参数  bucketName:           服务名
 参数  policy:               上传策略/ 签名的参数.
     @{@"Operator":operator_name, @"URI":uri, @"Date":date, @"Content-MD5":md5}
     其中 Content-MD5 可选, 其他 key 必须传值

 参数  signature:            签名认证

 参数参考 https://help.upyun.com/knowledge-base/object_storage_authorization/#e694bee59ca8-http-header-e4b8ad

 参数  filePath:             上传文件本地路径
 参数  successBlock:         上传成功回调
 参数  failureBlock:         上传失败回调
 参数  progressBlock:        上传进度回调
 */

- (void)uploadWithBucketName:(NSString *)bucketName
                      policy:(NSDictionary *)policy
                   signature:(NSString *)signature
                    filePath:(NSString *)filePath
                     success:(UpLoaderSuccessBlock)successBlock
                     failure:(UpLoaderFailureBlock)failureBlock
                    progress:(UpLoaderProgressBlock)progressBlock;

/**并行式断点续传后处理接口
 参数  bucketName:           服务名
 参数  policy:               上传策略/ 签名的参数.
        @{@"Operator":operator_name, @"URI":uri, @"Date":date, @"Content-MD5" : md5}
        其中 Content-MD5 可选, 其他 key 必须传值
 参数  signature:            签名认证

 参考: https://help.upyun.com/knowledge-base/object_storage_authorization/#e694bee59ca8-http-header-e4b8ad
 参数  filePath:             上传文件本地路径

 * 参数  notify_url:           回调通知地址, 详见 https://docs.upyun.com/cloud/av/#notify_url
 * 参数  tasks:                任务信息, 详见 https://docs.upyun.com/cloud/av/#tasks
 * 参数  successBlock:         上传成功回调
 * 参数  failureBlock:         上传失败回调
 * 参数  progressBlock:        上传进度回调
 */

//- (void)uploadWithBucketName:(NSString *)bucketName
//                      policy:(NSDictionary *)policy
//                   signature:(NSString *)signature
//                    filePath:(NSString *)filePath
//                  notify_url:(NSString *)notify_url
//                       tasks:(NSArray *)tasks
//                     success:(UpLoaderSuccessBlock)successBlock
//                     failure:(UpLoaderFailureBlock)failureBlock
//                    progress:(UpLoaderProgressBlock)progressBlock;

/**并行式断点续传接口
 参数  bucketName:           服务名
 参数  operator:             操作员
 参数  operatorPassword:     操作员密码

 服务名、操作员、操作员密码, 可以在 upyun 控制台获取：https://console.upyun.com/dashboard/ 导航栏>云产品>云存储>创建服务

 参数  filePath:             上传文件本地路径
 参数  savePath:             上传文件的保存路径, 例如：“/2015/0901/file1.jpg”
 参数  successBlock:         上传成功回调
 参数  failureBlock:         上传失败回调
 参数  progressBlock:        上传进度回调
 */

- (void)uploadWithBucketName:(NSString *)bucketName
                    operator:(NSString *)operatorName
                    password:(NSString *)operatorPassword
                    filePath:(NSString *)filePath
                    savePath:(NSString *)savePath
                     success:(UpLoaderSuccessBlock)successBlock
                     failure:(UpLoaderFailureBlock)failureBlock
                    progress:(UpLoaderProgressBlock)progressBlock;

/**并行式断点续传后处理接口

 参数  bucketName:           服务名
 参数  operator:             操作员
 参数  operatorPassword:     操作员密码

 服务名、操作员、操作员密码, 可以在 upyun 控制台获取：https://console.upyun.com/dashboard/ 导航栏>云产品>云存储>创建服务
 * 参数  filePath:             上传文件本地路径
 * 参数  savePath:             上传文件的保存路径, 例如：“/2015/0901/file1.jpg”
 * 参数  notify_url:           回调通知地址, 详见 https://docs.upyun.com/cloud/av/#notify_url
 * 参数  tasks:                任务信息, 详见 https://docs.upyun.com/cloud/av/#tasks
 * 参数  successBlock:         上传成功回调
 * 参数  failureBlock:         上传失败回调
 * 参数  progressBlock:        上传进度回调
 */

- (void)uploadWithBucketName:(NSString *)bucketName
                    operator:(NSString *)operatorName
                    password:(NSString *)operatorPassword
                    filePath:(NSString *)filePath
                    savePath:(NSString *)savePath
                  notify_url:(NSString *)notify_url
                       tasks:(NSArray *)tasks
                     success:(UpLoaderSuccessBlock)successBlock
                     failure:(UpLoaderFailureBlock)failureBlock
                    progress:(UpLoaderProgressBlock)progressBlock;
/// 取消/暂停上传
- (void)cancel;
/// 删除上传, 会清除断点记录, 下次上传需要重新上传
- (void)deleteTask;


/*删除本地缓存
 使用场景1: 失败的上传任务将记录在本地以实现续传，为避免将错误状态持久化在本地，而产生无法恢复的上传，可调用此方法清除本地记录。
 使用场景2: 可在开发过程中使用此方法进行调试。
 使用场景3: 推荐将此方法放到 app 的“清除缓存”的功能功能中。
 使用场景4: 当上传出现失败，可以提供多个选项供用户操作，比如：接着续传或者重新上传，如果需要重新上传就需要调用此方法。
 */
+ (void)clearCache;




@end
