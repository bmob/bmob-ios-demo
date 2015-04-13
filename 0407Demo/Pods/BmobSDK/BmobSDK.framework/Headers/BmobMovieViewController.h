//
//  BmobMovieViewController.h
//  BmobSDK
//
//  Created by Bmob on 15-1-15.
//  Copyright (c) 2015年 donson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>


@protocol BmobMovieViewControllerDelegate;

@interface BmobMovieViewController : UIViewController


@property (weak,   nonatomic) id <BmobMovieViewControllerDelegate> delegate;
@property (strong, nonatomic) UIBarButtonItem *rightBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem *leftBarButtonItem;
@property (copy  , nonatomic) NSArray *rightBarButtonItems;
@property (copy  , nonatomic) NSArray *leftBarButtonItems;

-(instancetype)initWithM3U8Filename:(NSString *)filename videoTitle:(NSString *)videoTitle;

/**
 *  设置滑动条
 *
 *  @param slider 滑动条
 */
-(void)setSlider:(UISlider *)slider;

/**
 *  设置播放按钮的图片
 *
 *  @param image         播放状态的图片
 *  @param selectedImage 暂停状态的图片
 */
-(void)setPlayButtonStateNormalImage:(UIImage *)image
                  stateSelectedImage:(UIImage *)selectedImage;

/**
 *  设置全屏按钮的图片
 *
 *  @param image         进入全屏状态的图片
 *  @param selectedImage 退出全屏状态的图片
 */
-(void)setFullscreenButtonStateNormalImage:(UIImage *)image
                        stateSelectedImage:(UIImage *)selectedImage;

/**
 *  关闭播放器
 */
-(void)closeMoviePlayer;

/**
 *  设置播放器的frame
 *
 *  @param frame 播放器的frame
 */
-(void)setMoviePlayerFrame:(CGRect)frame;

/**
 *  获取当前的播放比例,需要在关闭播放器之前调用
 *
 *  @return 已经播放的视频比例 (0.0f - 1.0f)
 */
-(CGFloat)progressOfThePlay;

/**
 *  把播放器放到self.view的最前面
 */
-(void)bringMoviePlayerToFront;

/**
 *  播放
 */
-(void)moviePlayerPlay;

/**
 *  暂停
 */
-(void)moviePlayerPause;

@end


@protocol BmobMovieViewControllerDelegate <NSObject>
@optional
-(void)verfiryErrorWithViewController:(BmobMovieViewController *)viewcontroller error:(NSError *)error;

-(void)moviePlayerDidPlay;

-(void)moviePlayerDidPause;

-(void)moviePlayerDidEnterFullscreen;

-(void)moviePlayerDidLeaveFullscreen;

@end
