//
//  UPHTTPBodyPart.h
//  UpYunSDK Demo
//
//  Created by 林港 on 16/1/19.
//  Copyright © 2016年 upyun. All rights reserved.
//

#import <Foundation/Foundation.h>



#pragma mark ---copy from AFNetworking

static NSString * BmobAFCreateMultipartFormBoundary() {
    return [NSString stringWithFormat:@"UpYunSDKFormBoundary2016v3%08X%08X", arc4random(), arc4random()];
}

static NSString * const kBmobAFMultipartFormCRLF = @"\r\n";

static inline NSString * BmobAFMultipartFormInitialBoundary(NSString *boundary) {
    return [NSString stringWithFormat:@"--%@%@", boundary, kBmobAFMultipartFormCRLF];
}

static inline NSString * BmobAFMultipartFormEncapsulationBoundary(NSString *boundary) {
    return [NSString stringWithFormat:@"%@--%@%@", kBmobAFMultipartFormCRLF, boundary, kBmobAFMultipartFormCRLF];
}

static inline NSString * BmobAFMultipartFormFinalBoundary(NSString *boundary) {
    return [NSString stringWithFormat:@"%@--%@--%@", kBmobAFMultipartFormCRLF, boundary, kBmobAFMultipartFormCRLF];
}

static inline NSString * BmobAFContentTypeForPathExtension(NSString *extension) {
#ifdef __UTTYPE__
    NSString *UTI = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)extension, NULL);
    NSString *contentType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)UTI, kUTTagClassMIMEType);
    if (!contentType) {
        return @"application/octet-stream";
    } else {
        return contentType;
    }
#else
#pragma unused (extension)
    return @"application/octet-stream";
#endif
}




@interface BmobUPHTTPBodyPart : NSObject
@property (nonatomic, assign) NSStringEncoding stringEncoding;
@property (nonatomic, strong) NSDictionary *headers;
@property (nonatomic, strong) id body;
@property (nonatomic, assign) unsigned long long bodyContentLength;
@property (nonatomic, strong) NSInputStream *inputStream;

@property (nonatomic, assign) BOOL hasInitialBoundary;
@property (nonatomic, assign) BOOL hasFinalBoundary;

@property (readonly, nonatomic, assign, getter = hasBytesAvailable) BOOL bytesAvailable;
@property (readonly, nonatomic, assign) unsigned long long contentLength;


- (NSString *)stringForHeaders;
@end
