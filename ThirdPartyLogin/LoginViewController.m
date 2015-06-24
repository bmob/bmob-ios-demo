//
//  LoginViewController.m
//  ThirdPartyLogin
//
//  Created by limao on 15/6/22.
//  Copyright (c) 2015年 limaofuyuanzhang. All rights reserved.
//

#import "LoginViewController.h"
#import <BmobSDK/Bmob.h>
#import "CheckUtil.h"
#import "ShowUserMessageViewController.h"
#import "RegisterViewController.h"
#import "WeiboSDK.h"
#import "WXApi.h"

@interface LoginViewController (){
    
    __weak IBOutlet UITextField *accountTf;
    __weak IBOutlet UITextField *passwordTf;
}

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginBtn:(id)sender {
    if ([CheckUtil isStrEmpty:accountTf.text]) {
        [CheckUtil showAlertWithMessage:@"账号不能为空" delegate:self];
        return;
    }
    
    if ([CheckUtil isStrEmpty:passwordTf.text]) {
        [CheckUtil showAlertWithMessage:@"密码不能为空" delegate:self];
        return;
    }
    
    [BmobUser loginInbackgroundWithAccount:accountTf.text andPassword:passwordTf.text block:^(BmobUser *user, NSError *error) {
        if (user) {
            //跳转
            ShowUserMessageViewController *showUser = [[ShowUserMessageViewController alloc] init];
            showUser.title = @"用户信息";
            
            [self.navigationController pushViewController:showUser animated:YES];
        } else {
            [CheckUtil showAlertWithMessage:[error description] delegate:self];
        }
    }];
    
}

- (IBAction)registerBtn:(id)sender {
    //跳转
    RegisterViewController *registerViewController = [[RegisterViewController alloc] init];
    registerViewController.title = @"注册";
    
    [self.navigationController pushViewController:registerViewController animated:YES];
    
}

- (IBAction)weiboLogin:(id)sender {
    if([WeiboSDK isWeiboAppInstalled]){
        //向新浪发送请求
        WBAuthorizeRequest *request = [WBAuthorizeRequest request];
        request.redirectURI = @"https://api.weibo.com/oauth2/default.html";
        request.scope = @"all";
        [WeiboSDK sendRequest:request];
    } else {
        [CheckUtil showAlertWithMessage:@"没有安装微博客户端" delegate:self];
    }
}

- (IBAction)qqLogin:(id)sender {
    if ([TencentOAuth iphoneQQInstalled]) {
        //注册
        _tencentOAuth = [[TencentOAuth alloc] initWithAppId:@"1104720526" andDelegate:self];
        //授权
        NSArray *permissions = [NSArray arrayWithObjects:kOPEN_PERMISSION_GET_INFO,nil];
        [_tencentOAuth authorize:permissions inSafari:NO];
        //获取用户信息
        [_tencentOAuth getUserInfo];
    } else {
        [CheckUtil showAlertWithMessage:@"没有安装qq客户端" delegate:self];
    }

}

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

- (IBAction)weixinLogin:(id)sender {
    if ([WXApi isWXAppInstalled]){
        SendAuthReq* req =[[SendAuthReq alloc ] init];
        req.scope = @"snsapi_userinfo,snsapi_base";
        req.state = @"0744" ;
        [WXApi sendReq:req];
    } else {
        [CheckUtil showAlertWithMessage:@"没有安装微信客户端" delegate:self];
    }
}
@end
