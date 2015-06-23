//
//  ShowUserMessageViewController.m
//  ThirdPartyLogin
//
//  Created by limao on 15/6/22.
//  Copyright (c) 2015年 limaofuyuanzhang. All rights reserved.
//

#import "ShowUserMessageViewController.h"
#import <BmobSDK/Bmob.h>

@interface ShowUserMessageViewController ()

@property (weak, nonatomic) IBOutlet UITextView *showUserMessageTv;
@property (retain,nonatomic) BmobUser *user;

@end

@implementation ShowUserMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.user = [BmobUser getCurrentUser];
    self.showUserMessageTv.text = [self.user description];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
