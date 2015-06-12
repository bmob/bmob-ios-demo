//
//  AppDelegate.m
//  BmobSmsDemo
//
//  Created by limao on 15/6/5.
//  Copyright (c) 2015年 Bmob. All rights reserved.
//

#import "AppDelegate.h"
#import <BmobSDK/Bmob.h>
#import "LoginViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize window;
@synthesize navController;
@synthesize viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
     [Bmob registerWithAppKey:@"aaeae0170d0accf9f3feb5b96c1d62ea"];
    //用导致视图时需要添加对应的导航视图控制器
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
   
    self.window.backgroundColor = [UIColor whiteColor];
    self.viewController =  [[LoginViewController alloc]init];
    self.navController = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    
    //下移导航栏，不遮挡状态栏
    UIView *view = self.navController.view;
    self.navController.view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y+20, view.frame.size.width, view.frame.size.height);
    NSLog(@"加载前：%f %f %f %f",view.frame.origin.x, view.frame.origin.y+20, view.frame.size.width, view.frame.size.height);
    [self.window addSubview:navController.view];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
