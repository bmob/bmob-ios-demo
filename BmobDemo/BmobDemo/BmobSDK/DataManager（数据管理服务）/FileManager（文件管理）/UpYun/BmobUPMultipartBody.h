//
//  UPMultipartBody.h
//  UpYunSDK Demo
//
//  Created by 林港 on 16/1/19.
//  Copyright © 2016年 upyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BmobUPMultipartBody : NSObject
@property (nonatomic, copy) NSString* boundary;

- (instancetype)initWithBoundary:(NSString *)boundary;
- (void)addKey:(NSString *)key AndValue:(NSString *)value;
- (void)addDictionary:(NSDictionary *)parames;
- (void)addFilePath:(NSString *)filePath fileName:(NSString *)fileName fileType:(NSString *)fileType;
- (void)addFileData:(NSData *)fileData fileName:(NSString *)fileName fileType:(NSString *)fileType;
- (void)addFileData:(NSData *)fileData OrFilePath:(NSString *)filePath fileName:(NSString *)fileName fileType:(NSString *)fileType;

- (NSData *)dataFromPart;
@end
