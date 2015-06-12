//
//  FirstPageViewController.m
//  BmobSmsDemo
//
//  Created by limao on 15/6/9.
//  Copyright (c) 2015年 Bmob. All rights reserved.
//

#import "FirstPageViewController.h"
#import <BmobSDK/Bmob.h>
#import "BindMobilePhoneViewController.h"
#import "ResetPasswordViewController.h"

@interface FirstPageViewController (){
    UITextView *userMsgTv;
    BmobUser *user;
    UIButton *bindMobilePhoneBtn;
    UIButton *resetPasswordBtn;
}

@property UITextView *userMsgTv;
@property BmobUser *user;
@property UIButton *bindMobilePhoneBtn;
@property UIButton *resetPasswordBtn;
@end

@implementation FirstPageViewController

@synthesize userMsgTv;
@synthesize user;
@synthesize bindMobilePhoneBtn;
@synthesize resetPasswordBtn;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor redColor]];
    [self.navigationItem setTitle:@"首 页"];
    [self constructView];
    [self setViewLogic];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - UI
-(void)constructView{
    [self constructUserMsgTv];
    [self constructBindMobilePhoneBtn];
    [self constructResetPasswordBtn];
}

-(void)constructUserMsgTv{
    self.userMsgTv = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 300)];
    self.userMsgTv.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.userMsgTv];
}

-(void)constructBindMobilePhoneBtn{
    self.bindMobilePhoneBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 320, self.view.frame.size.width-40, 40)];
    self.bindMobilePhoneBtn.layer.cornerRadius = 10;
    
    self.bindMobilePhoneBtn.backgroundColor = [UIColor redColor];
    [self.bindMobilePhoneBtn setTitle:@"绑定手机号" forState:UIControlStateNormal];
    
    [self.view addSubview:self.bindMobilePhoneBtn];
}

-(void)constructResetPasswordBtn{
    self.resetPasswordBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 370, self.view.frame.size.width-40, 40)];
    self.resetPasswordBtn.layer.cornerRadius = 10;
    
    self.resetPasswordBtn.backgroundColor = [UIColor redColor];
    [self.resetPasswordBtn setTitle:@"重置密码" forState:UIControlStateNormal];
    
    [self.view addSubview:self.resetPasswordBtn];
    
}

# pragma mark - 逻辑
-(void)setViewLogic{
    [self showUserMsg];
    [self.bindMobilePhoneBtn addTarget:self action:@selector(bindMobilePhone) forControlEvents:UIControlEventTouchUpInside];
    [self.resetPasswordBtn addTarget:self action:@selector(resetPassword) forControlEvents:UIControlEventTouchUpInside];
}

-(void)showUserMsg{
    NSMutableString *displayMsg = [[NSMutableString alloc] initWithCapacity:1];
    
    //获取用户信息并显示
    user = [BmobUser getCurrentUser];
    if (user){
        [displayMsg appendString:[user description]];
        [displayMsg appendString:@"\n"];
    }
    
    [displayMsg appendString:@"如果您的账号只采用过手机加验证码形式登录，并未重置过密码，那么只允许继续采用手机号加验证码的形式登录，如果想要采用账号密码的形式登录，请使用手机号重置密码功能重置密码"];
         
    self.userMsgTv.text = displayMsg;
}

////判断是否已经设置了密码
//-(BOOL)isSetPassword{
//    return NO;
//}

-(void)bindMobilePhone{
   BindMobilePhoneViewController *bindMobilePhoneViewController = [[BindMobilePhoneViewController alloc] init];
    [self.navigationController pushViewController:bindMobilePhoneViewController animated:NO];
    
}

-(void)resetPassword{
    //跳转至重置界面
    if (user.mobilePhoneNumber) {
        
        ResetPasswordViewController *resetPasswordViewController = [[ResetPasswordViewController alloc] init];
        [self.navigationController pushViewController:resetPasswordViewController animated:NO];
        
    } else {
    
        UIAlertView *tip = [[UIAlertView alloc] initWithTitle:nil message:@"手机重置密码需要先绑定手机号" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [tip show];
    }
}
@end
