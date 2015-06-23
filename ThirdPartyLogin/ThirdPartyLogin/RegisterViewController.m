//
//  RegisterViewController.m
//  ThirdPartyLogin
//
//  Created by limao on 15/6/22.
//  Copyright (c) 2015年 limaofuyuanzhang. All rights reserved.
//

#import "RegisterViewController.h"
#import "CheckUtil.h"
#import <BmobSDK/Bmob.h>

@interface RegisterViewController ()
@property (weak, nonatomic) IBOutlet UITextField *accountTf;
@property (weak, nonatomic) IBOutlet UITextField *passwordTf;
@property (weak, nonatomic) IBOutlet UITextField *verifyPasswordTf;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)registerBtn:(UIButton *)sender {
    if ([CheckUtil isStrEmpty:self.accountTf.text] ||
        [CheckUtil isStrEmpty:self.passwordTf.text]||
        [CheckUtil isStrEmpty:self.verifyPasswordTf.text]) {
        [CheckUtil showAlertWithMessage:@"输入不能为空" delegate:self];
    } else if (![self.passwordTf.text isEqualToString:self.verifyPasswordTf.text]){
        [CheckUtil showAlertWithMessage:@"两次输入密码不相同" delegate:self];
    } else {
        BmobUser *user = [[BmobUser alloc] init];
        user.username = self.accountTf.text;
        user.password = self.passwordTf.text;
        [user signUpInBackgroundWithBlock:^(BOOL isSuccessful, NSError *error) {
            if (isSuccessful) {
                [CheckUtil showAlertWithMessage:@"注册成功" delegate:self];
            } else {
                [CheckUtil showAlertWithMessage:[error description] delegate:self];
            }
        }];
    }
    
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
