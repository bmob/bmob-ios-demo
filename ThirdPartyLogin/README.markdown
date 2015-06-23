---
title: Bmob第三方登录详解
tags: Bmob,第三方登录
---

# 简介

本文主要介绍新浪微博,QQ,微信的登录接入以及如何配合BmobSDK中的第三方登录功能实现第三方登录。

在使用之前请先按照[快速入门][1]创建好可以调用BmobSDK的工程。

## 新浪微博登录

1.下载[新浪SDK][2]，并按照上面给的文档说明，在新浪的后台创建应用并配置好工程。

2.在AppDelegate中实现回调。

```
AppDelegate.h

@interface AppDelegate : UIResponder <UIApplicationDelegate,WeiboSDKDelegate>

AppDelegate.m

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    return [WeiboSDK handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    return [WeiboSDK handleOpenURL:url delegate:self];
}
```

3.请求授权信息，可在点击登录处实现

```
    //向新浪发送请求
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = @"https://api.weibo.com/oauth2/default.html";
    request.scope = @"all";
    [WeiboSDK sendRequest:request];
```

4.接收回调信息并与Bmob账号进行绑定，首次登录时Bmob后台会创建一个账号。
```
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
        }
    }];
```

# QQ登录

1.进入[腾讯开放平台][3]注册用户，创建应用（需要审核）;

2.按照开发文档导入SDK，然后把注册成功后获取到的Key加入到Url Schemes中，格式为:tencentXXXX;

3.在AppDelegate.m中实现下面方法

```
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation  {  
    return [TencentOAuth HandleOpenURL:url];  
}  
  
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url  {  
    return [TencentOAuth HandleOpenURL:url];  
}  
```

4.注册并实现授权

```
    //注册
    _oauth = [[TencentOAuth alloc] initWithAppId:@"1104720526" andDelegate:self];
    //授权
    NSArray *permissions = [NSArray arrayWithObjects:kOPEN_PERMISSION_GET_INFO,nil];
    [_oauth authorize:permissions inSafari:NO];
    //获取用户信息
    [_oauth getUserInfo];
```

5.获取AccessToken等信息,此处为实现TencentSessionDelegate中的方法，并进行绑定。

```
- (void)tencentDidLogin{
    if (_tencentOAuth.accessToken && 0 != [_tencentOAuth.accessToken length]){
        //  记录登录用户的OpenID、Token以及过期时间
        NSString *accessToken = _tencentOAuth.accessToken;
        NSString *uid = _tencentOAuth.openId;
        NSDate *expiresDate = _tencentOAuth.expirationDate;
        NSLog(@"acessToken:%@",accessToken);
        NSLog(@"UserId:%@",uid);
        NSLog(@"expiresDate:%@",expiresDate);
        NSDictionary *dic = @{@"access_token":accessToken,@"uid":uid,@"expirationDate":expiresDate};
        
        //通过授权信息注册登录
        [BmobUser loginInBackgroundWithAuthorDictionary:dic platform:BmobSNSPlatformQQ block:^(BmobUser *user, NSError *error) {
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

}

- (void)tencentDidNotLogin:(BOOL)cancelled{
}

- (void)tencentDidNotNetWork{
}

```

# 微信
1.到[微信开放平台][4]注册账号并提交应用审核;

2.按照官方文档配置好SDK，导入相应的依赖包，添加URL scheme;

3.在AppDelegate实现下面方法；

```
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation  {  
    return [TencentOAuth HandleOpenURL:url] ||  
    [WeiboSDK handleOpenURL:url delegate:self] ||  
    [WXApi handleOpenURL:url delegate:self];;  
}  
  
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {  
    return [TencentOAuth HandleOpenURL:url] ||  
    [WeiboSDK handleOpenURL:url delegate:self] ||  
    [WXApi handleOpenURL:url delegate:self];;  
}  
```

4.实现点击发送授权请求

```
- (IBAction)weixinLogin:(id)sender {
    SendAuthReq* req =[[SendAuthReq alloc ] init];
    req.scope = @"snsapi_userinfo,snsapi_base";
    req.state = @"0744" ;
    [WXApi sendReq:req];
}
```
5.发送授权后到完成绑定需要经过两步。
1）获取code
2）利用code获取token，openId和expiresDate

代码在AppDelegate.m中实现。如下：

```
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
    NSString *url =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",@"填入你的appid",@"填入你的secretkey",code];
    
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
                    }
                }];
            }
        });
    });
}
```

  [1]: http://docs.bmob.cn/ios/faststart/index.html?menukey=fast_start&key=start_ios
  [2]: https://github.com/sinaweibosdk/weibo_ios_sdk
  [3]: http://open.qq.com
  [4]: https://open.weixin.qq.com