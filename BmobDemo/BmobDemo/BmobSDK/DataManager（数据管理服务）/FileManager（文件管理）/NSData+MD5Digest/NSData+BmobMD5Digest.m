//
//  NSData+MD5Digest.m
//  NSData+MD5Digest
//
//  Created by Francis Chong on 12年6月5日.
//

#import "NSData+BmobMD5Digest.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSData (MD5)

+(NSData *)MD5Digest:(NSData *)input {
    unsigned char result[CC_SHA256_DIGEST_LENGTH];

    CC_SHA256(input.bytes, (CC_LONG)input.length, result);
    return [[NSData alloc] initWithBytes:result length:CC_SHA256_DIGEST_LENGTH];
}

-(NSData *)MD5Digest {
    return [NSData MD5Digest:self];
}

+(NSString *)MD5HexDigest:(NSData *)input {
    unsigned char result[CC_SHA256_DIGEST_LENGTH];

    CC_SHA256(input.bytes, (CC_LONG)input.length, result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x", result[i]];
    }
    return ret;
}

-(NSString *)MD5HexDigest {
    return [NSData MD5HexDigest:self];
}

@end
