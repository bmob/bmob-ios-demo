//
//  SmsCodeRegisterViewController.m
//  BmobSmsDemo
//
//  Created by limao on 15/6/9.
//  Copyright (c) 2015年 Bmob. All rights reserved.
//

#import "SmsCodeRegisterViewController.h"
#import <BmobSDK/Bmob.h>
#import "FirstPageViewController.h"

@interface SmsCodeRegisterViewController (){
    UITextField *mobilePhoneNumberTf;
    UITextField *smsCodeTf;
    UIButton *requestSmsCodeBtn;
    UIButton *loginBtn;
    NSTimer *countDownTimer;
    unsigned secondsCountDown;
}
@property UITextField *mobilePhoneNumberTf;
@property UITextField *smsCodeTf;
@property UIButton *requestSmsCodeBtn;
@property UIButton *loginBtn;
@property NSTimer *countDownTimer;
@property unsigned secondsCountDown;
@end


# pragma mark -
@implementation SmsCodeRegisterViewController
@synthesize mobilePhoneNumberTf;
@synthesize smsCodeTf;
@synthesize requestSmsCodeBtn;
@synthesize loginBtn;
@synthesize countDownTimer;
@synthesize secondsCountDown;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController.navigationBar setBackgroundColor:[UIColor redColor]];
    [self.navigationItem setTitle:@"手机号码一键登录"];
    [self constructView];
    [self setViewLogic];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI构造
- (void)constructView{
    [self constructMobilePhoneNumberView];
    [self constructSmsCodeView];
    [self constructRequestSmsCodeButton];
    [self constructLoginButton];
}

-(void)constructMobilePhoneNumberView{
    //添加账号框
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(20, 100, self.view.frame.size.width-40, 40)];
    view.layer.borderColor = [UIColor grayColor].CGColor;
    view.layer.borderWidth = 1;
    view.layer.cornerRadius = 5;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 70, 40)];
    label.text = @"手机号:";
    label.textAlignment = UITextAlignmentLeft;
    [view addSubview:label];
    
    self.mobilePhoneNumberTf = [[UITextField alloc] initWithFrame:CGRectMake(78,0,self.view.frame.size.width-90,40)];
    self.mobilePhoneNumberTf.placeholder = @"请输入手机号码";
    [view addSubview:self.mobilePhoneNumberTf];
    
    [self.view addSubview:view];
}

-(void)constructSmsCodeView{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(20, 150, self.view.frame.size.width-150, 40)];
    view.layer.borderColor = [UIColor grayColor].CGColor;
    view.layer.borderWidth = 1;
    view.layer.cornerRadius = 5;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 70, 40)];
    label.text = @"验证码:";
    label.textAlignment = UITextAlignmentLeft;
    [view addSubview:label];
    
    self.smsCodeTf = [[UITextField alloc] initWithFrame:CGRectMake(78,0,self.view.frame.size.width-90,40)];
    self.smsCodeTf.placeholder = @"6位验证码";
    [view addSubview:self.smsCodeTf];
    
    [self.view addSubview:view];
}

-(void)constructRequestSmsCodeButton{
    self.requestSmsCodeBtn = [[UIButton alloc] initWithFrame:CGRectMake(20+self.view.frame.size.width-150+10,150 , 100, 40)];
    self.requestSmsCodeBtn.layer.cornerRadius = 10;
    
    self.requestSmsCodeBtn.backgroundColor = [UIColor redColor];
    [self.requestSmsCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];

    [self.view addSubview:self.requestSmsCodeBtn];
}

-(void)constructLoginButton{
    self.loginBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 230, self.view.frame.size.width-40, 40)];
    self.loginBtn.layer.cornerRadius = 10;
    
    self.loginBtn.backgroundColor = [UIColor redColor];
    [self.loginBtn setTitle:@"登 录" forState:UIControlStateNormal];
    [self.view addSubview:self.loginBtn];
}

-(void)setRequestSmsCodeBtnCountDown{
    [self.requestSmsCodeBtn setEnabled:NO];
    self.requestSmsCodeBtn.backgroundColor = [UIColor grayColor];
    self.secondsCountDown = 60;
    
    countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDownTimeWithSeconds:) userInfo:nil repeats:YES];
    [countDownTimer fire];
}

-(void)countDownTimeWithSeconds:(NSTimer*)timerInfo{
    if (secondsCountDown == 0) {
        [self.requestSmsCodeBtn setEnabled:YES];
        self.requestSmsCodeBtn.backgroundColor = [UIColor redColor];
        [self.requestSmsCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        [countDownTimer invalidate];
    } else {
        [self.requestSmsCodeBtn setTitle:[[NSNumber numberWithInt:secondsCountDown] description] forState:UIControlStateNormal];
        self.secondsCountDown--;
    }
}

# pragma mark - 处理逻辑

-(void)setViewLogic{
    [self.requestSmsCodeBtn addTarget:self action:@selector(setRequestSmsCodeBtnLogic) forControlEvents:UIControlEventTouchUpInside];
    [self.loginBtn addTarget:self action:@selector(setLoginBtnLogic) forControlEvents:UIControlEventTouchUpInside];
}

-(void)setRequestSmsCodeBtnLogic{
    
    //获取手机号
    NSString *mobilePhoneNumber = self.mobilePhoneNumberTf.text;
    
    //请求验证码
    [BmobMessage requestSMSCodeInBackgroundWithPhoneNumber:mobilePhoneNumber andTemplate:@"test" resultBlock:^(int number, NSError *error) {
        if (error) {
            NSLog(@"%@",error);
            UIAlertView *tip = [[UIAlertView alloc] initWithTitle:nil message:@"请输入正确的手机号码" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [tip show];
        } else {
            //获得smsID
            NSLog(@"sms ID：%d",number);
            //设置不可点击
            [self setRequestSmsCodeBtnCountDown];
        }
    }];
}

-(void)setLoginBtnLogic{
    //获取手机号、验证码
    NSString *mobilePhoneNumber = self.mobilePhoneNumberTf.text;
    NSString *smsCode = self.smsCodeTf.text;
    
    //该方法可以进行注册和登录两步操作，如果已经注册过了就直接进行登录
    [BmobUser signOrLoginInbackgroundWithMobilePhoneNumber:mobilePhoneNumber andSMSCode:smsCode block:^(BmobUser *user, NSError *error) {
        if (user) {
            //跳转
            FirstPageViewController *firstPageViewController = [[FirstPageViewController alloc] init];
            [self.navigationController pushViewController:firstPageViewController animated:NO];
        } else {
            NSLog(@"%@",error);
            UIAlertView *tip = [[UIAlertView alloc] initWithTitle:nil message:@"验证码有误" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [tip show];
        }
    }];
    
    
//    //验证
//    [BmobMessage verifySMSCodeInBackgroundWithPhoneNumber:mobilePhoneNumber andSMSCode:smsCode resultBlock:^(BOOL isSuccessful, NSError *error) {
//        if (isSuccessful) {
//            //跳转
//            FirstPageViewController *firstPageViewController = [[FirstPageViewController alloc] init];
//            [self.navigationController pushViewController:firstPageViewController animated:NO];
//        } else {
//            NSLog(@"%@",error);
//            UIAlertView *tip = [[UIAlertView alloc] initWithTitle:nil message:@"验证码有误" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//            [tip show];
//        }
//    }];
}



@end
