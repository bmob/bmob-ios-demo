//
//  ResetPasswordViewController.m
//  BmobSmsDemo
//
//  Created by limao on 15/6/9.
//  Copyright (c) 2015年 Bmob. All rights reserved.
//

#import "ResetPasswordViewController.h"
#import <BmobSDK/Bmob.h>
#import "FirstPageViewController.h"

@interface ResetPasswordViewController (){
    UITextField *smsCodeTf;
    UIButton *requestSmsCodeBtn;
    UIButton *resetPasswordBtn;
    NSTimer *countDownTimer;
    unsigned secondsCountDown;
    UITextField *passwordTf;
    UITextField *verifyPasswordTf;
}
@property UITextField *smsCodeTf;
@property UIButton *requestSmsCodeBtn;
@property UIButton *resetPasswordBtn;
@property NSTimer *countDownTimer;
@property unsigned secondsCountDown;
@property UITextField *passwordTf;
@property UITextField *verityPasswordTf;
@end

@implementation ResetPasswordViewController
@synthesize smsCodeTf;
@synthesize requestSmsCodeBtn;
@synthesize resetPasswordBtn;
@synthesize countDownTimer;
@synthesize secondsCountDown;
@synthesize passwordTf;
@synthesize verityPasswordTf;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController.navigationBar setBackgroundColor:[UIColor redColor]];
    [self.navigationItem setTitle:@"手机号重置密码"];
    [self constructView];
    [self setViewLogic];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI构造
- (void)constructView{
    [self constructSmsCodeView];
    [self constructRequestSmsCodeButton];
    [self constructPasswordButton];
    [self constructVirifyPasswordView];
    [self constructResetPasswordButton];
    
}

-(void)constructSmsCodeView{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(20, 70, self.view.frame.size.width-150, 40)];
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
    self.requestSmsCodeBtn = [[UIButton alloc] initWithFrame:CGRectMake(20+self.view.frame.size.width-150+10,70 , 100, 40)];
    self.requestSmsCodeBtn.layer.cornerRadius = 10;
    
    self.requestSmsCodeBtn.backgroundColor = [UIColor redColor];
    [self.requestSmsCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    
    [self.view addSubview:self.requestSmsCodeBtn];
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

-(void)constructPasswordButton{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(20, 120, self.view.frame.size.width-40, 40)];
    view.layer.borderColor = [UIColor grayColor].CGColor;
    view.layer.borderWidth = 1;
    view.layer.cornerRadius = 5;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 75, 40)];
    label.text = @"密  码:";
    label.textAlignment = UITextAlignmentLeft;
    [view addSubview:label];
    
    self.passwordTf = [[UITextField alloc] initWithFrame:CGRectMake(78,0,self.view.frame.size.width-90,40)];
    self.passwordTf.placeholder = @"请输入密码";
    self.passwordTf.secureTextEntry = YES;
    [view addSubview:self.passwordTf];
    
    [self.view addSubview:view];
}

-(void)constructVirifyPasswordView{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(20, 170, self.view.frame.size.width-40, 40)];
    view.layer.borderColor = [UIColor grayColor].CGColor;
    view.layer.borderWidth = 1;
    view.layer.cornerRadius = 5;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 75, 40)];
    label.text = @"确认密码:";
    label.textAlignment = UITextAlignmentLeft;
    [view addSubview:label];
    
    self.verityPasswordTf = [[UITextField alloc] initWithFrame:CGRectMake(78,0,self.view.frame.size.width-90,40)];
    self.verityPasswordTf.placeholder = @"请再次输入密码";
    self.verityPasswordTf.secureTextEntry = YES;
    [view addSubview:self.verityPasswordTf];
    
    [self.view addSubview:view];
}

-(void)constructResetPasswordButton{
    self.resetPasswordBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 220, self.view.frame.size.width-40, 40)];
    self.resetPasswordBtn.layer.cornerRadius = 10;
    
    self.resetPasswordBtn.backgroundColor = [UIColor redColor];
    [self.resetPasswordBtn setTitle:@"重置密码" forState:UIControlStateNormal];
    [self.view addSubview:self.resetPasswordBtn];
}

# pragma mark - 逻辑
-(void)setViewLogic{
    [self.resetPasswordBtn addTarget:self action:@selector(setResetPasswordBtnLogic) forControlEvents:UIControlEventTouchUpInside];
    [self.requestSmsCodeBtn addTarget:self action:@selector(setRequestSmsCodeBtnLogic) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)setRequestSmsCodeBtnLogic{
    
    //获取手机号
    BmobUser *user = [BmobUser getCurrentUser];
    NSString *mobilePhoneNumber = user.mobilePhoneNumber;
    
    //请求验证码
    [BmobSMS requestSMSCodeInBackgroundWithPhoneNumber:mobilePhoneNumber andTemplate:@"test" resultBlock:^(int number, NSError *error) {
        if (error) {
            NSLog(@"%@",error);
        } else {
            //获得smsID
            NSLog(@"sms ID：%d",number);
            //设置不可点击
            [self setRequestSmsCodeBtnCountDown];
        }
    }];
}

-(void)setResetPasswordBtnLogic{
    NSString *smsCode = self.smsCodeTf.text;
    NSString *password = self.passwordTf.text;
    NSString *verifyPassword = self.verityPasswordTf.text;
    if (!smsCode || [smsCode isEqualToString:@""] || !password || [password isEqualToString:@""] || !verifyPassword || [verifyPassword isEqualToString:@""] || ![password isEqualToString:verifyPassword]) {
        UIAlertView *tip = [[UIAlertView alloc] initWithTitle:nil message:@"验证码不能为空，密码及确认密码必须相等且不为空" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [tip show];
    } else {
        [BmobUser resetPasswordInbackgroundWithSMSCode:smsCode andNewPassword:password block:^(BOOL isSuccessful, NSError *error) {
            if (isSuccessful) {
                UIAlertView *tip = [[UIAlertView alloc] initWithTitle:nil message:@"重置密码成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [tip show];
                //跳转
                FirstPageViewController *firstPageViewController = [[FirstPageViewController alloc] init];
                [self.navigationController pushViewController:firstPageViewController animated:NO];
            } else {
               UIAlertView *tip = [[UIAlertView alloc] initWithTitle:nil message:@"验证码有误" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [tip show];
            }
        }];
    }
}


@end
