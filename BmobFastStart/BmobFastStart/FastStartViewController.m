//
//  FastStartViewController.m
//  BmobFastStart
//
//  Created by Bmob on 14-5-20.
//  Copyright (c) 2014年 bmob. All rights reserved.
//

#import "FastStartViewController.h"
#import <BmobSDK/Bmob.h>


@interface FastStartViewController (){
    NSArray             *_fsArray;
    UITableView         *_fsTableView;
}

@end

@implementation FastStartViewController

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
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title              = @"快速入门Demo";
    _fsArray                = @[@"添加一行数据",@"获取一行数据",@"修改一行数据",@"删除一行数据"];

    _fsTableView            = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, 320, 45*4)];
    _fsTableView.dataSource = self;
    _fsTableView.delegate   = self;
    [self.view addSubview:_fsTableView];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)createBmobObject{
    //往GameScore表添加一条playerName为小明，分数为78的数据
    BmobObject *gameScore = [BmobObject objectWithClassName:@"GameScore"];
    [gameScore setObject:@"小明" forKey:@"playerName"];
    [gameScore setObject:@78 forKey:@"score"];
    [gameScore saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        //进行操作
    }];
}

-(void)getBmobObject{
    //查找GameScore表
    BmobQuery   *bquery = [BmobQuery queryWithClassName:@"GameScore"];
    //查找GameScore表里面id为0c6db13c的数据
    [bquery getObjectInBackgroundWithId:@"0c6db13c" block:^(BmobObject *object,NSError *error){
        if (error){
            //进行错误处理
        }else{
            //表里有id为0c6db13c的数据
            if (object) {
                //得到playerName和cheatMode
                NSString *playerName = [object objectForKey:@"playerName"];
                BOOL cheatMode = [[object objectForKey:@"cheatMode"] boolValue];
                NSLog(@"%@----%i",playerName,cheatMode);
            }
        }
    }];
}

-(void)updateBmobObject{
    //查找GameScore表
    BmobQuery   *bquery = [BmobQuery queryWithClassName:@"GameScore"];
    //查找GameScore表里面id为0c6db13c的数据
    [bquery getObjectInBackgroundWithId:@"0c6db13c" block:^(BmobObject *object,NSError *error){
        //没有返回错误
        if (!error) {
            //对象存在
            if (object) {
                //设置cheatMode为YES
                [object setObject:[NSNumber numberWithBool:YES] forKey:@"cheatMode"];
                //异步更新数据
                [object updateInBackground];
            }
        }else{
            //进行错误处理
        }
    }];
}

-(void)deleteBmobObject{
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"GameScore"];
    [bquery getObjectInBackgroundWithId:@"0c6db13c" block:^(BmobObject *object, NSError *error){
        if (error) {
            //进行错误处理
        }
        else{
            if (object) {
                //异步删除object
                [object deleteInBackground];
            }
        }
    }];
}
#pragma mark - UITableView Datasource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_fsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = [_fsArray objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - UITableView Delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            [self createBmobObject];
            break;
        case 1:
            [self getBmobObject];
            break;
        case 2:
            [self updateBmobObject];
            break;
        case 3:
            [self deleteBmobObject];
            break;
        default:
            break;
    }
}

@end
