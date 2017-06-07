//
//  ViewController.m
//  BmobPaySDKDemo
//
//  Created by 陈超邦 on 2017/1/11.
//  Copyright © 2017年 陈超邦. All rights reserved.
//

#import "ViewController.h"
#import <BmobPaySDK/Bmob.h>
//#import <BmobSDK/Bmob.h>  ／／使用BmobSDK总包的话导入这个文件
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *price;
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *describe;
@property (weak, nonatomic) IBOutlet UITextView *result;
@property (strong, nonatomic) NSString *orderNumber;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)keyboardHide {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

- (IBAction)WeChatPay:(id)sender {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    [BmobPay payWithPayType:BmobWechat
                      price:[NSNumber numberWithFloat:[_price.text floatValue]]
                  orderName:_name.text
                   describe:_describe.text
                     result:^(BOOL isSuccessful, NSError *error) {
                         if (isSuccessful) {
                             _result.text = @"支付成功";
                         } else {
                             _result.text = error.description;
                         }
                     }]; 
    
    [BmobPay orderInfoCallback:^(NSDictionary *orderInfo) {
        _orderNumber = orderInfo[@"orderNumber"];
    }];
}

- (IBAction)ALiPay:(id)sender {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    [BmobPay payWithPayType:BmobAlipay
                      price:[NSNumber numberWithFloat:[_price.text floatValue]]
                  orderName:_name.text
                   describe:_describe.text
                     result:^(BOOL isSuccessful, NSError *error) {
                         if (isSuccessful) {
                             _result.text = @"支付成功";
                         } else {
                             _result.text = error.description;
                         }
                     }];
    
    [BmobPay orderInfoCallback:^(NSDictionary *orderInfo) {
        _orderNumber = orderInfo[@"orderNumber"];
    }];
}


- (IBAction)query:(id)sender {
    [BmobPay queryWithOrderNumber:_orderNumber
                           result:^(NSDictionary *resultDic, NSError *error) {
                               if (resultDic) {
                                   NSData *jsonData = [NSJSONSerialization dataWithJSONObject:resultDic
                                                                                      options:NSJSONWritingPrettyPrinted
                                                                                        error:nil];
                                   _result.text = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];;
                               } else {
                                   _result.text = error.description;
                               }
                           }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
