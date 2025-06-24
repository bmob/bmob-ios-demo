//
//  UPMultipartBody.m
//  UpYunSDK Demo
//
//  Created by 林港 on 16/1/19.
//  Copyright © 2016年 upyun. All rights reserved.
//

#import "BmobUPMultipartBody.h"
#import "BmobUPHTTPBodyPart.h"




@interface BmobUPMultipartBody()

@property (nonatomic, strong) NSMutableArray* bodyParts;

@end

@implementation BmobUPMultipartBody


- (instancetype)init {
    return [self initWithBoundary:BmobAFCreateMultipartFormBoundary()];
}

- (instancetype)initWithBoundary:(NSString*)boundary {
    self = [super init];
    if (self) {
        self.boundary = boundary;
        self.bodyParts = [NSMutableArray new];
    }
    return self;
}


- (void)addKey:(NSString*)key AndValue:(NSString*)value {
    
    BmobUPHTTPBodyPart *part = [[BmobUPHTTPBodyPart alloc]init];
    NSMutableDictionary *mutableHeaders = [NSMutableDictionary dictionary];
    [mutableHeaders setValue:[NSString stringWithFormat:@"form-data; name=\"%@\"", key] forKey:@"Content-Disposition"];
    part.headers = mutableHeaders;
    part.body = [value dataUsingEncoding:NSUTF8StringEncoding];
    [self.bodyParts addObject:part];
}

- (void)addDictionary:(NSDictionary *)parames {
    for (NSString* key in parames) {
        NSString *value = [parames objectForKey:key];
        [self addKey:key AndValue:value];
    }
}

- (void)addFilePath:(NSString*)filePath fileName:(NSString *)fileName fileType:(NSString *)fileType {
    [self addFileData:nil OrFilePath:filePath fileName:fileName fileType:fileType];
}

- (void)addFileData:(NSData*)fileData fileName:(NSString *)fileName fileType:(NSString *)fileType {
    [self addFileData:fileData OrFilePath:nil fileName:fileName fileType:fileType];
}

- (void)addFileData:(NSData*)fileData OrFilePath:(NSString *)filePath fileName:(NSString *)fileName fileType:(NSString *)fileType {
    NSMutableDictionary *mutableHeaders = [NSMutableDictionary dictionary];
    [mutableHeaders setValue:[NSString stringWithFormat:@"form-data; name=\"file\"; filename=\"%@\"", fileName] forKey:@"Content-Disposition"];
    if (fileType) {
        [mutableHeaders setValue:fileType forKey:@"Content-Type"];
    } else {
        [mutableHeaders setValue:@"application/octet-stream" forKey:@"Content-Type"];
    }
    
    BmobUPHTTPBodyPart *part = [[BmobUPHTTPBodyPart alloc]init];
    part.headers = mutableHeaders;
    
    if (fileData) {
        part.body = fileData;
    } else if (filePath) {
        part.body = filePath;
    }
    [self.bodyParts addObject:part];
}


- (NSData *)dataFromPart {
    @autoreleasepool {
    NSMutableData *data = [[NSMutableData alloc]init];
    for (int i = 0; i< self.bodyParts.count; i++) {
        BmobUPHTTPBodyPart *part = self.bodyParts[i];
        
        NSData *beginData = [BmobAFMultipartFormEncapsulationBoundary(self.boundary) dataUsingEncoding:NSUTF8StringEncoding];
        [data appendData:beginData];
        
        NSData *headerData = [[part stringForHeaders] dataUsingEncoding:NSUTF8StringEncoding];
        [data appendData:headerData];
        
        if ([part.body isKindOfClass:[NSData class]]) {
            [data appendData:part.body];
        } else if ([part.body isKindOfClass:[NSString class]]) {
            NSData *fileData = [NSData dataWithContentsOfFile:part.body];
            [data appendData:fileData];
            fileData = nil;
        }
    }
    
    NSData *endData = [BmobAFMultipartFormFinalBoundary(self.boundary) dataUsingEncoding:NSUTF8StringEncoding];
    [data appendData:endData];
    
    return [NSData dataWithData:data];
    }
}

- (void)dealloc {
    for (int i = 0; i< self.bodyParts.count; i++) {
        BmobUPHTTPBodyPart *part = self.bodyParts[i];
        part.body = nil;
        part = nil;
    }
    [self.bodyParts removeAllObjects];
}

@end
