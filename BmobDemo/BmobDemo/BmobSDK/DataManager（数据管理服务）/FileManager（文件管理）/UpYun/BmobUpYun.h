//
//  UpYun.h
//  UpYunSDK
//
//  Created by jack zhou on 13-8-6.
//  Copyright (c) 2013年 upyun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NSData+BmobMD5Digest.h"
#import "BmobUPYUNConfig.h"

#import "BmobUPHTTPClient.h"


#ifdef __IPHONE_9_1


#import <Photos/Photos.h>
#import <PhotosUI/PHLivePhotoView.h>

#define PATH_MOVIE_FILE  [NSTemporaryDirectory() stringByAppendingPathComponent:@"tempLivePhoto.mov"]

#define PATH_PHOTO_FILE [NSTemporaryDirectory() stringByAppendingPathComponent:@"tempLivePhoto.jpg"]

#endif

typedef NS_ENUM(NSUInteger, UPUploadMethod) {
   //UPFileSizeUpload = 1,
    UPFormUpload = 2,
    UPMutUPload = 3
};

#define DATE_STRING(expiresIn) [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970] + expiresIn]

typedef void(^UPCompeleteBlock)(NSError *error, NSDictionary *result, BOOL completed);

typedef void(^UPSuccessBlock)(NSURLResponse *response, id responseData);
typedef void(^UPFailBlock)(NSError *error);
typedef void(^UPProgressBlock)(CGFloat percent, int64_t requestDidSendBytes);
typedef NSString*(^UPSignatureBlock)(NSString *policy);
typedef NSString*(^UPPolicyBlock)();

@interface BmobUpYun : NSObject

@property (nonatomic, copy) NSString *bucket;

@property (nonatomic, assign) NSTimeInterval        expiresIn;
// 默认用户服务端生成的过期时间,防止用户手机时间不正确出现的上传错误,一般用不上
@property (nonatomic, copy) NSString           *dateExpiresIn;

@property (nonatomic, strong) NSMutableDictionary       *params;

@property (nonatomic, copy) NSString *passcode;

@property (nonatomic, assign) NSInteger mutUploadSize;

@property (nonatomic, assign) NSInteger retryTimes;

@property (nonatomic, copy) UPSuccessBlock    successBlocker;

@property (nonatomic, copy) UPFailBlock       failBlocker;

@property (nonatomic, copy) UPProgressBlock  progressBlocker;

@property (nonatomic, copy) UPSignatureBlock  signatureBlocker;

@property (nonatomic, copy) UPPolicyBlock       policyBlocker;

@property (nonatomic, assign) UPUploadMethod uploadMethod;

@property (nonatomic, readonly) BmobUPHTTPClient *client;

#ifdef __IPHONE_9_1
/**
 *	@brief	上传LivePhoto文件
 *
 *	@param 	livePhotoAsset PHLivePhoto
 *	@param 	saveKey  保存的文件名, 不带后缀
 */
- (void)uploadLivePhoto:(PHLivePhoto *)livePhotoAsset saveKey:(NSString *)saveKey;
/**
 *	@brief	上传LivePhoto文件
 *
 *	@param 	livePhotoAsset PHLivePhoto
 *	@param 	saveKey  保存的文件名, 不带后缀
 *	@param 	extParams 	上传需要额外添加的参数，如:生成另外格式的文件
 */
- (void)uploadLivePhoto:(PHLivePhoto *)livePhotoAsset saveKey:(NSString *)saveKey extParams:(NSDictionary *)extParams;
#endif


/**********************/
/**以下新增接口 建议使用**/
/**
 *	@brief	上传文件
 *
 *	@param 	file 	文件信息 可用值:  1、UIImage(会转成PNG格式，需要其他格式请先转成NSData传入 或者 传入文件路径)、
 2、NSData、
 3、NSString(文件路径)
 *	@param 	saveKey 	由开发者自定义的saveKey
 */
- (void)uploadFile:(id)file saveKey:(NSString *)saveKey;

/**
 *	@brief	上传文件
 *
 *	@param 	file 	文件信息 可用值:  1、UIImage(会转成PNG格式，需要其他格式请先转成NSData传入 或者 传入文件路径)、
 2、NSData、
 3、NSString(文件路径)
 *	@param 	saveKey 	由开发者自定义的saveKey
 *	@param 	extParams 	上传需要额外添加的参数，如:生成另外格式的文件
 */
- (void)uploadFile:(id)file saveKey:(NSString *)saveKey extParams:(NSDictionary *)extParams;
/**以上新增接口 建议使用**/
/**********************/


/**
 *	@brief	上传图片接口
 *
 *	@param 	image 	图片
 *	@param 	savekey 	savekey
 */
- (void)uploadImage:(UIImage *)image savekey:(NSString *)savekey;

/**
 *	@brief	上传图片接口
 *
 *	@param 	path 	图片path
 *	@param 	savekey 	savekey
 */
- (void)uploadImagePath:(NSString *)path savekey:(NSString *)savekey;

/**
 *	@brief	上传图片接口
 *
 *	@param 	data 	图片data
 *	@param 	savekey 	savekey
 */
- (void)uploadImageData:(NSData *)data savekey:(NSString *)savekey;


-(void)cancel;

@end
