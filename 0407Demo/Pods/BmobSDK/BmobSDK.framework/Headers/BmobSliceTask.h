//
//  SliceTask.h
//  BmobSDK
//
//  Created by Bmob on 15-1-28.
//  Copyright (c) 2015年 donson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BmobSliceTask : NSObject

/**
 *  源文件的文件名
 */
@property (copy, nonatomic) NSString *fileName;

/**
 *  音频的码率 单位：比特每秒（bit/s），常用码率：64k，128k，192k，256k，320k等
 */
@property (assign) int  audioBitrate;

/**
 *  音频的采样率,单位Hz,若没则默认22.05k 赫兹
 */
@property (assign) int  asmp;

/**
 *  视频的高
 */
@property (assign) int  height;

/**
 *  视频的宽
 */
@property (assign) int  width;

/**
 *  视频的码率,比特每秒(bit/s)，码率越大，文件越大，需要带宽也大。若没设置，采用源码率.
 *  常用视频比特率：128k=128000，125000000，5000000等。
 */
@property (assign) int  videoBitrate;

/**
 *  视频的帧率,单位赫兹(hz)，常用的24，25，30等，没设置采用源帧率
 */
@property (assign) int  videoFps;

/**
 *  ts文件的长度, 单位为秒，取值范围为>=5。默认为10秒
 */
@property (assign) int  tst;


+(instancetype)task;

@end
