//
//  BmobAK.h
//  BmobSDK
//
//  Created by Bmob on 15-1-7.
//  Copyright (c) 2015年 Bmob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
/**
 该类主要用于管理网络请求的通过以及保存一些状态
 */
@interface BmobManager : NSObject

/**
 *  sk
 */
@property (nonatomic, copy)   NSData *sk;


@property (copy, nonatomic) NSData *apid;

/**
 *  count为0是发出通知
 */
@property (assign, nonatomic) NSInteger count;

/**
 *  本地时间和服务器时间差值
 */
@property (assign, nonatomic) int time;

/**
 *  是否初始化完成
 */
@property (assign)BOOL        initFinished;

/**
 *  请求队列
 */
@property (strong, nonatomic) NSMutableArray *requestArray;

/**
 *  请求的id
 */
@property (assign) int requestId;

/**
 *  是否已经发送推送，为了防止用户在处理初始化通知时多次收到消息（初始化失败会再次进行初始化），现在的处理方式也不太妥
 */
@property (assign) BOOL hasPostNotification;

/**
 *  是否正在获取secretkey
 */
@property (assign) BOOL isSecrecting;

/**
 *  是否正在进行初始化
 */
@property (assign) BOOL isIniting;

@property (assign, nonatomic) int upyunVersion;

@property (assign, nonatomic) CGFloat timeout;


@property (copy, nonatomic) NSDictionary *migrationDictionary;

/**
 *  返回BmobAK对象，采用单例模式，全局只有一个BmobAK对象
 */
+(instancetype)defaultManager;


@end
