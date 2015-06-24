//
//  AppDelegate.m
//  ThirdPartyLogin
//
//  Created by limao on 15/6/22.
//  Copyright (c) 2015年 limaofuyuanzhang. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import <BmobSDK/Bmob.h>
#import "WeiboSDK.h"
#import "ShowUserMessageViewController.h"
#import "WXApi.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Override point for customization after application launch.
#warning 注意填入你自己的app key，并且添加info.plist中的url scheme
    [Bmob registerWithAppKey:@""];
    [WeiboSDK enableDebugMode:YES];
    [WeiboSDK registerApp:@""];
    [WXApi registerApp:@""];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    LoginViewController *loginViewController = [[LoginViewController alloc] init];
    loginViewController.title = @"登录";
    
    
    self.navigationController = [[UINavigationController alloc] init];
    [self.navigationController pushViewController:loginViewController animated:YES];
    
    [self.window addSubview:self.navigationController.view];
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


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    return [TencentOAuth HandleOpenURL:url] ||
    [WeiboSDK handleOpenURL:url delegate:self] ||
    [WXApi handleOpenURL:url delegate:self];;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    return [TencentOAuth HandleOpenURL:url] ||
    [WeiboSDK handleOpenURL:url delegate:self] ||
    [WXApi handleOpenURL:url delegate:self];
}

# pragma mark - 新浪回调
//收到回复时的回调
- (void)didReceiveWeiboResponse:(WBBaseResponse *)response{
    NSString *accessToken = [(WBAuthorizeResponse *)response accessToken];
    NSString *uid = [(WBAuthorizeResponse *)response userID];
    NSDate *expiresDate = [(WBAuthorizeResponse *)response expirationDate];
    NSLog(@"acessToken:%@",accessToken);
    NSLog(@"UserId:%@",uid);
    NSLog(@"expiresDate:%@",expiresDate);
    NSDictionary *dic = @{@"access_token":accessToken,@"uid":uid,@"expirationDate":expiresDate};
    
    
    //通过授权信息注册登录
    [BmobUser loginInBackgroundWithAuthorDictionary:dic platform:BmobSNSPlatformSinaWeibo block:^(BmobUser *user, NSError *error) {
        if (error) {
            NSLog(@"weibo login error:%@",error);
        } else if (user){
            NSLog(@"user objectid is :%@",user.objectId);
            //跳转
            ShowUserMessageViewController *showUser = [[ShowUserMessageViewController alloc] init];
            showUser.title = @"用户信息";
            
            [self.navigationController pushViewController:showUser animated:YES];
        }
    }];
}

//发送请求时的回调
-(void)didReceiveWeiboRequest:(WBBaseRequest *)request{
}

# pragma mark - 微信回调
-(void)onResp:(BaseReq *)resp
{
    /*
     ErrCode ERR_OK = 0(用户同意)
     ERR_AUTH_DENIED = -4（用户拒绝授权）
     ERR_USER_CANCEL = -2（用户取消）
     code    用户换取access_token的code，仅在ErrCode为0时有效
     state   第三方程序发送时用来标识其请求的唯一性的标志，由第三方程序调用sendReq时传入，由微信终端回传，state字符串长度不能超过1K
     lang    微信客户端当前语言
     country 微信用户当前国家信息
     */
    SendAuthResp *aresp = (SendAuthResp *)resp;
    if (aresp.errCode== 0) {
        NSString *code = aresp.code;
        [self getAccessToken:code];
    }
}

-(void)getAccessToken:(NSString*)code{
    //https://api.weixin.qq.com/sns/oauth2/access_token?appid=APPID&secret=SECRET&code=CODE&grant_type=authorization_code
    
#warning 在此处需要填写你自身的appid和secretkey
    NSString *url =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",@"",@"",code];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *zoneUrl = [NSURL URLWithString:url];
        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                NSDictionary *dicFromWeixin = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                /*
                 {
                 "access_token" = "OezXcEiiBSKSxW0eoylIeJDUKD6z6dmr42JANLPjNN7Kaf3e4GZ2OncrCfiKnGWiusJMZwzQU8kXcnT1hNs_ykAFDfDEuNp6waj-bDdepEzooL_k1vb7EQzhP8plTbD0AgR8zCRi1It3eNS7yRyd5A";
                 "expires_in" = 7200;
                 openid = oyAaTjsDx7pl4Q42O3sDzDtA7gZs;
                 "refresh_token" = "OezXcEiiBSKSxW0eoylIeJDUKD6z6dmr42JANLPjNN7Kaf3e4GZ2OncrCfiKnGWi2ZzH_XfVVxZbmha9oSFnKAhFsS0iyARkXCa7zPu4MqVRdwyb8J16V8cWw7oNIff0l-5F-4-GJwD8MopmjHXKiA";
                 scope = "snsapi_userinfo,snsapi_base";
                 }
                 */
                //  记录登录用户的OpenID、Token以及过期时间
                NSString *accessToken = [dicFromWeixin objectForKey:@"access_token"];
                NSString *uid = [dicFromWeixin objectForKey:@"openid"];
                NSNumber *expires_in = [dicFromWeixin objectForKey:@"expires_in"];
                NSDate *expiresDate = [NSDate dateWithTimeIntervalSinceNow:[expires_in doubleValue]];
                NSLog(@"acessToken:%@",accessToken);
                NSLog(@"UserId:%@",uid);
                NSLog(@"expiresDate:%@",expiresDate);
                NSDictionary *dic = @{@"access_token":accessToken,@"uid":uid,@"expirationDate":expiresDate};
                
                //通过授权信息注册登录
                [BmobUser loginInBackgroundWithAuthorDictionary:dic platform:BmobSNSPlatformWeiXin block:^(BmobUser *user, NSError *error) {
                    if (error) {
                        NSLog(@"weibo login error:%@",error);
                    } else if (user){
                        NSLog(@"user objectid is :%@",user.objectId);
                        //跳转
                        ShowUserMessageViewController *showUser = [[ShowUserMessageViewController alloc] init];
                        showUser.title = @"用户信息";
                        
                        [self.navigationController pushViewController:showUser animated:YES];
                    }
                }];
            }
        });
    });
}


@end
