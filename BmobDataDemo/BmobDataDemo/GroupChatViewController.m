//
//  GroupChatViewController.m
//  BmobDataDemo
//
//  Created by Bmob on 14-7-21.
//  Copyright (c) 2014年 bmob. All rights reserved.
//

#import "GroupChatViewController.h"
#import <BmobSDK/Bmob.h>
#import "ChatTableViewCell.h"
#import "ChatObject.h"


@interface GroupChatViewController ()<UITableViewDataSource,UITableViewDelegate,BmobEventDelegate,UITextFieldDelegate>{
    NSMutableArray          *_chatMutableArray;
    UITableView             *_chatTableView;
    BmobEvent               *_dataBmobEvent;
    UIView                  *_bottomView;//底部
    NSDateFormatter         *_dateFormatter;
}

@end


@implementation GroupChatViewController

#define kHideButtonTag 800000

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _chatMutableArray = [[NSMutableArray alloc] init];
        if (IS_iOS7) {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    
    self.title                    = @"聊天室";
    self.view.backgroundColor     = [UIColor whiteColor];
    _chatTableView                = [[UITableView alloc] init];
    _chatTableView.frame          = CGRectMake(0, ViewOriginY, 320, ScreenHeight-ViewOriginY-44);
    _chatTableView.dataSource     = self;
    _chatTableView.delegate       = self;
    _chatTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_chatTableView];
    //字视图
    [self setupViews];
    //通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChange:) name:UIKeyboardWillShowNotification object:nil];
    //数据实时
    _dataBmobEvent = [BmobEvent defaultBmobEvent];
    _dataBmobEvent.delegate = self;
    [_dataBmobEvent start];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [self.view endEditing:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    _dataBmobEvent            = nil;
    _chatTableView.dataSource = nil;
    _chatTableView.delegate   = nil;
    _chatMutableArray         = nil;
}

-(void)setupViews{
    CGFloat bottomViewOrginY = 0.0f;
    
    if (IS_iOS7) {
        bottomViewOrginY = ScreenHeight-44;
    }else{
        bottomViewOrginY = ScreenHeight -64-44;
    }
    _bottomView                            = [[UIView alloc] initWithFrame:CGRectMake(0, bottomViewOrginY, 320, 44)];
    [self.view addSubview:_bottomView];
    UIImageView *backgroundImageView       = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    backgroundImageView.image              = [UIImage imageNamed:@"chat_db_bar"];
    [_bottomView addSubview:backgroundImageView];

    //用户名
    UIImageView *inputBackgroundImageView0 = [[UIImageView alloc] initWithFrame:CGRectMake(15, 8, 60, 30)];
    inputBackgroundImageView0.image        = [UIImage imageNamed:@"chat_input"];
    [_bottomView addSubview:inputBackgroundImageView0];

    //输入框
    UITextField *userTextField            = [[UITextField alloc] initWithFrame:CGRectMake(18, 11, 60, 25)];
    userTextField.font                    = [UIFont systemFontOfSize:15];
    userTextField.delegate                = self;
    userTextField.placeholder             = @"用户名";
    userTextField.tag                     = 100;
    [_bottomView addSubview:userTextField];
    //内容
    UIImageView *inputBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(95, 8, 170, 30)];
    inputBackgroundImageView.image        = [UIImage imageNamed:@"chat_input"];
    [_bottomView addSubview:inputBackgroundImageView];
    //输入框
    UITextField *chatTextField            = [[UITextField alloc] initWithFrame:CGRectMake(98, 11, 150, 25)];
    chatTextField.font                    = [UIFont systemFontOfSize:15];
    chatTextField.delegate                = self;
    chatTextField.returnKeyType           = UIReturnKeySend;
    chatTextField.placeholder             = @"内容";
    chatTextField.tag                     = 101;
    [_bottomView addSubview:chatTextField];
    //发送按钮
    UIButton    *sendButton               = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    sendButton.frame                      = CGRectMake(265, 8, 50, 30);
    [sendButton setTitle:@"send" forState:UIControlStateNormal];
    [[sendButton titleLabel] setFont:[UIFont systemFontOfSize:15]];
    [sendButton addTarget:self action:@selector(saveMessage) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:sendButton];
    //隐藏按钮
    UIButton *hideKeyBoardButton          = [UIButton buttonWithType:UIButtonTypeCustom];
    hideKeyBoardButton.frame              = CGRectMake(0, ViewOriginY, 320, _bottomView.frame.origin.y-ViewOriginY);
    hideKeyBoardButton.tag                = kHideButtonTag;
    hideKeyBoardButton.alpha              = 0.0f;
    [hideKeyBoardButton addTarget:self action:@selector(hideBottomView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:hideKeyBoardButton];
//    hideKeyBoardButton.backgroundColor = [UIColor redColor];
}

//隐藏
-(void)hideBottomView{
    [self.view endEditing:YES];
    
    CGFloat bottomViewOrginY = 0.0f;
    if (IS_iOS7) {
        bottomViewOrginY = ScreenHeight-44;
    }else{
        bottomViewOrginY = ScreenHeight - 64-44;
    }
    [UIView animateWithDuration:0.4f animations:^{
        [_bottomView setFrame:CGRectMake(0, bottomViewOrginY, 320, 144)];
    }];
    UIButton *hideKeyBoardButton =(UIButton*) [self.view viewWithTag:kHideButtonTag];
    hideKeyBoardButton.alpha = 0.0f;
    hideKeyBoardButton.frame = CGRectMake(0, ViewOriginY, 320, _bottomView.frame.origin.y-ViewOriginY);
}


-(void)keyboardFrameChange:(NSNotification*)noti{
    if (noti) {
        NSValue *keyboardBoundsValue = [[noti userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
        CGRect keyboardEndRect       = [keyboardBoundsValue CGRectValue];
        CGFloat bottomViewOrginY = 0.0f;
        if (IS_iOS7) {
            bottomViewOrginY = ScreenHeight-44-keyboardEndRect.size.height;
        }else{
            bottomViewOrginY = ScreenHeight-64-44-keyboardEndRect.size.height;
        }
        [UIView animateWithDuration:0.4f animations:^{
            [_bottomView setFrame:CGRectMake(0, bottomViewOrginY, 320, 200)];
        }];
        UIButton *hideKeyBoardButton =(UIButton*) [self.view viewWithTag:kHideButtonTag];
        hideKeyBoardButton.alpha     = 1.0f;
        hideKeyBoardButton.frame     = CGRectMake(0, ViewOriginY, 320, _bottomView.frame.origin.y-ViewOriginY);
    }
}

#pragma mark - UITableView Datasource
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    ChatObject *co = [_chatMutableArray objectAtIndex:indexPath.row];
    if (co.content) {
        CGSize size = [co.content sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(280, 1000) lineBreakMode:NSLineBreakByCharWrapping];
        return size.height +40;
    }
    return 45;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_chatMutableArray count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    ChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil) {
        cell = [[ChatTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    ChatObject *co         = [_chatMutableArray objectAtIndex:indexPath.row];
    NSString *text = [NSString stringWithFormat:@"%@  %@",
                      co.name,
                      co.time];
    
    // If attributed text is supported (iOS6+)
    if ([cell.titleLabel respondsToSelector:@selector(setAttributedText:)]) {
        
        // Define general attributes for the entire text
        NSDictionary *attribs = @{
                                  NSForegroundColorAttributeName: cell.titleLabel.textColor,
                                  NSFontAttributeName:[UIFont systemFontOfSize:13]
                                  };
        NSMutableAttributedString *attributedText =
        [[NSMutableAttributedString alloc] initWithString:text
                                               attributes:attribs];
        
        // Red text attributes
        UIColor *redColor = [UIColor blackColor];
        NSRange redTextRange = [text rangeOfString:co.name];// * Notice that usage of rangeOfString in this case may cause some bugs - I use it here only for demonstration
        [attributedText setAttributes:@{NSForegroundColorAttributeName:redColor}
                                range:redTextRange];
        
        // Green text attributes
        UIColor *greenColor = [UIColor lightGrayColor];
        NSRange greenTextRange = [text rangeOfString:co.time];// * Notice that usage of rangeOfString in this case may cause some bugs - I use it here only for demonstration
        [attributedText setAttributes:@{NSForegroundColorAttributeName:greenColor}
                                range:greenTextRange];
        
    
        
        cell.titleLabel.attributedText = attributedText;
    }else{
        cell.titleLabel.text = text;
    }
    
    cell.contentLabel.text = co.content;
    
    return cell;
}

#pragma mark - UITableView Delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - event delegate
//
//-(void)

-(void)restart{
    [_dataBmobEvent stop];
    [_dataBmobEvent start];
}

-(void)bmobEventDidDisConnect:(BmobEvent *)event error:(NSError *)error{
    NSLog(@"bmobEventDidDisConnect error:%@",[error description]);
    [self performSelector:@selector(restart) withObject:nil afterDelay:0.7f];
}



-(void)bmobEventCanStartListen:(BmobEvent *)event{
    NSLog(@"bmobEventCanStartListen");
    [_dataBmobEvent listenTableChange:BmobActionTypeUpdateTable tableName:@"Chat"];
}

-(void)bmobEvent:(BmobEvent *)event didReceiveMessage:(NSString *)message{
    
    NSError *error = nil;
    NSDictionary  *jsonDic = [NSJSONSerialization JSONObjectWithData:[message dataUsingEncoding:NSUTF8StringEncoding]
                                                             options:NSJSONReadingMutableContainers
                                                               error:&error];
    NSLog(@"jsonDic =====:%@",[jsonDic description]);
    if (!error) {
        NSDictionary *dataDic  = [jsonDic objectForKey:@"data"];
        ChatObject *chatObject = [[ChatObject alloc] init];
        chatObject.name        = [dataDic objectForKey:@"name"];
        chatObject.time        = [dataDic objectForKey:@"createdAt"];
        chatObject.content     = [dataDic objectForKey:@"content"];
        [_chatMutableArray addObject:chatObject];
        [_chatTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[_chatMutableArray count]-1 inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
    }
}


#pragma mark textfield

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
//    if (textField.tag == 101) {
        UIButton *hideKeyBoardButton =(UIButton*) [self.view viewWithTag:kHideButtonTag];
        hideKeyBoardButton.alpha = 1.0f;
        hideKeyBoardButton.frame = CGRectMake(0, ViewOriginY, 320, _bottomView.frame.origin.y-ViewOriginY);
//    }
   
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
   
    
    
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField.tag == 101) {
        [self saveMessage];
    }
    return YES;
}


-(void)saveMessage{
    UITextField *userTextField = (UITextField *)[_bottomView viewWithTag:100];
    UITextField *chatTextField = (UITextField *)[_bottomView viewWithTag:101];
    BmobObject *obj = [[BmobObject alloc] initWithClassName:@"Chat"];
    [obj setObject:userTextField.text forKey:@"name"];
    [obj setObject:chatTextField.text forKey:@"content"];
    [obj saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
//        NSLog(@"error:%@",[error description]);
        chatTextField.text = nil;
    }];
    
    //更新
//    BmobObject *obj = [BmobObject objectWithoutDatatWithClassName:@"Chat" objectId:@"5c523b41c7"];
//    [obj setObject:userTextField.text forKey:@"name"];
//    [obj setObject:chatTextField.text forKey:@"content"];
//    [obj updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
//        NSLog(@"error:%@",[error description]);
//    }];
}
@end
