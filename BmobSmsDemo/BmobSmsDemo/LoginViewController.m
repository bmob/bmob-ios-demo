//
//  LoginViewController.m
//  BmobSmsDemo
//
//  Created by limao on 15/6/8.
//  Copyright (c) 2015年 Bmob. All rights reserved.
//

#import "LoginViewController.h"
#import "FirstPageViewController.h"
#import "SmsCodeRegisterViewController.h"
#import <BmobSDK/Bmob.h>

@interface LoginViewController (){
    UITextField *accountTf;
    UITextField *passwordTf;
    UIButton *loginBtn;
    UIButton *registerAndLoginBtn;
}

@property UITextField *accountTf;
@property UITextField *passwordTf;
@property UIButton *loginBtn;
@property UIButton *registerAndLoginBtn;

@end

# pragma mark -

@implementation LoginViewController
@synthesize accountTf;
@synthesize passwordTf;
@synthesize loginBtn;
@synthesize registerAndLoginBtn;

- (void)viewDidLoad {
    [super viewDidLoad];
    //进入登录界面前使用logout操作，把本地缓存的用户信息删除
    [BmobUser logout];
    
    [self.navigationController.navigationBar setBackgroundColor:[UIColor redColor]];
    [self.navigationItem setTitle:@"登 录"];
    [self constructInputView];
    [self setViewLogic];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UI构造
- (void)constructInputView{
    [self constructAccountView];
    [self constructPasswordView];
    [self constructLoginButton];
    [self constructRegisterAndLoginButton];
}

-(void)constructAccountView{
    //添加账号框
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(20, 100, self.view.frame.size.width-40, 40)];
    view.layer.borderColor = [UIColor grayColor].CGColor;
    view.layer.borderWidth = 1;
    view.layer.cornerRadius = 5;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 50, 40)];
    label.text = @"账  号:";
    label.textAlignment = UITextAlignmentLeft;
    [view addSubview:label];
    
    self.accountTf = [[UITextField alloc] initWithFrame:CGRectMake(58,0,self.view.frame.size.width-90,40)];
    self.accountTf.placeholder = @"用户名/邮箱/手机号";
    [view addSubview:self.accountTf];
    
    [self.view addSubview:view];
}

-(void)constructPasswordView{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(20, 150, self.view.frame.size.width-40, 40)];
    view.layer.borderColor = [UIColor grayColor].CGColor;
    view.layer.borderWidth = 1;
    view.layer.cornerRadius = 5;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 50, 40)];
    label.text = @"密  码:";
    label.textAlignment = UITextAlignmentLeft;
    [view addSubview:label];
    
    self.passwordTf = [[UITextField alloc] initWithFrame:CGRectMake(58,0,self.view.frame.size.width-90,40)];
    self.passwordTf.placeholder = @"请输入密码";
    self.passwordTf.secureTextEntry = YES;
    [view addSubview:self.passwordTf];
    
    [self.view addSubview:view];
}

-(void)constructLoginButton{
    self.loginBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 200, self.view.frame.size.width-40, 40)];
    self.loginBtn.layer.cornerRadius = 10;
    
    self.loginBtn.backgroundColor = [UIColor redColor];
    [self.loginBtn setTitle:@"登  录" forState:UIControlStateNormal];
    
    [self.view addSubview:self.loginBtn];
}

-(void)constructRegisterAndLoginButton{
    self.registerAndLoginBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 250, self.view.frame.size.width-40, 40)];
    self.registerAndLoginBtn.layer.cornerRadius = 10;
    
    self.registerAndLoginBtn.backgroundColor = [UIColor redColor];
    [self.registerAndLoginBtn setTitle:@"手机号码一键登录" forState:UIControlStateNormal];
    
    [self.view addSubview:self.registerAndLoginBtn];
}

# pragma mark - 处理逻辑

-(void)setViewLogic{
    [self.loginBtn addTarget:self action:@selector(setLoginBtnLogic) forControlEvents:UIControlEventTouchUpInside];
    [self.registerAndLoginBtn addTarget:self action:@selector(setRegisterAndLoginBtnLogic) forControlEvents:UIControlEventTouchUpInside];
}

-(void)setLoginBtnLogic{
    //获取账号、密码
    NSString *account = self.accountTf.text;
    NSString *password = self.passwordTf.text;
    
    [BmobUser loginInbackgroundWithAccount:account andPassword:password block:^(BmobUser *user, NSError *error) {
        if (user) {
            NSLog(@"%@",user);
            
            //跳转
            FirstPageViewController *firstPageViewController = [[FirstPageViewController alloc] init];
            [self.navigationController pushViewController:firstPageViewController animated:NO];
        } else {
            NSLog(@"%@",error);
            UIAlertView *tip = [[UIAlertView alloc] initWithTitle:nil message:@"请输入正确的账号密码" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [tip show];
        }
    }];
}

-(void)setRegisterAndLoginBtnLogic{
    SmsCodeRegisterViewController *smsCodeRegisterViewController = [[SmsCodeRegisterViewController alloc] init];
    [self.navigationController pushViewController:smsCodeRegisterViewController animated:NO];
}



@end
