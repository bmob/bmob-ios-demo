//
//  ViewController.m
//  BmobRelationDemo
//
//  Created by limao on 15/4/27.
//  Copyright (c) 2015年 Bmob. All rights reserved.
//

#import "ViewController.h"
#import <BmobSDK/Bmob.h>
#import <BmobSDK/BmobProFile.h>

@interface ViewController ()

@end

@implementation ViewController
- (IBAction)addPostBtn:(UIButton *)sender {
    BmobObject  *post = [BmobObject objectWithClassName:@"Post"];
    //设置文章的标题和内容
    [post setObject:@"title4" forKey:@"title"];
    [post setObject:@"content4" forKey:@"content"];
    
    //设置文章关联的作者记录，此处关联objectId为EL0VAAAH的作者
    BmobObject *author = [BmobObject objectWithoutDatatWithClassName:@"Author" objectId:@"E3Nc222D"];
    [post setObject:author forKey:@"author"];
    
    //异步保存
    [post saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            //创建成功，返回objectId，updatedAt，createdAt等信息
            //打印objectId
            NSLog(@"objectid :%@",post.objectId);
        }else{
            if (error) {
                NSLog(@"%@",error);
            }
        }
    }];
}


- (IBAction)queryAuthorBtn:(id)sender {
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Post"];
    
    //声明该次查询需要将author关联对象信息一并查询出来
    [bquery includeKey:@"author"];
    
    //进行异步查询，查询objectId为6a85f14654的文章信息
    [bquery getObjectInBackgroundWithId:@"6a85f14654" block:^(BmobObject *object, NSError *error) {
        
        //打印文章标题，内容
        BmobObject *post = object;
        NSLog(@"title:%@",[post objectForKey:@"title"]);
        NSLog(@"content:%@",[post objectForKey:@"content"]);
        
        //取得文章的关联作者对象
        BmobObject *author = [post objectForKey:@"author"];
        //打印文章的关联作者对象的相关信息
        NSLog(@"objectId:%@",author.objectId);
        NSLog(@"name:%@",[author objectForKey:@"name"]);
    }];
}

//查询作者为author1的文章
- (IBAction)restrictQueryRelationBtn:(UIButton *)sender {
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Post"];
    
    //构造约束条件
    BmobQuery *inQuery = [BmobQuery queryWithClassName:@"Author"];
    [inQuery whereKey:@"name" equalTo:@"author1"];
    
    //匹配查询
    [bquery whereKey:@"author" matchesQuery:inQuery];
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (error) {
            NSLog(@"%@",error);
        } else {
            for (BmobObject *post in array) {
                NSLog(@"%@",[post objectForKey:@"title"]);
            }
        }
    }];
}

- (IBAction)modifyAuthorBtn:(UIButton *)sender {
    BmobQuery   *bquery = [BmobQuery queryWithClassName:@"Post"];
    //获得objectId为bcc68a38ca的文章
    [bquery getObjectInBackgroundWithId:@"bcc68a38ca" block:^(BmobObject *object,NSError *error){
        if (error){
            NSLog(@"%@",error);
        }else{
            if (object) {
                BmobObject *post = object;
                //获得BmobObject对象
                BmobObject *user = [BmobObject objectWithoutDatatWithClassName:@"Author" objectId:@"1t8j666C"];
                //设置post的author值为新获得的BmobUser对象
                [post setObject:user forKey:@"author"];
                //进行更新
                [post updateInBackground];
            }
        }
    }];
}

- (IBAction)deleteAuthorBtn:(id)sender {
    BmobQuery   *bquery = [BmobQuery queryWithClassName:@"Post"];
    //获得objectId为bcc68a38ca的文章
    [bquery getObjectInBackgroundWithId:@"bcc68a38ca" block:^(BmobObject *object,NSError *error){
        if (error){
            NSLog(@"%@",error);
        }else{
            if (object) {
                BmobObject *post = object;
                //将author列的值置为空
                [post deleteForKey:@"author"];
                //进行更新
                [post updateInBackground];
            }
        }
    }];
}

- (IBAction)addRelationPostToUserBtn:(UIButton *)sender {
    //获取要添加关联关系的author
    BmobObject *author = [BmobObject objectWithoutDatatWithClassName:@"Author" objectId:@"E3Nc222D"];
    
    //新建relation对象
    BmobRelation *relation = [[BmobRelation alloc] init];
    [relation addObject:[BmobObject objectWithoutDatatWithClassName:@"Post" objectId:@"bcc68a38ca"]];
    [relation addObject:[BmobObject objectWithoutDatatWithClassName:@"Post" objectId:@"x31oCCCr"]];
    
    //添加关联关系到postlist列中
    [author addRelation:relation forKey:@"postlist"];
    //异步更新obj的数据
    [author updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            NSLog(@"successful");
        }else{
            NSLog(@"error %@",[error description]);
        }
    }];
}

- (IBAction)queryRelationPostBtn:(UIButton *)sender {
    //关联对象表
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Post"];

    //需要查询的列
    BmobObject *author = [BmobObject objectWithoutDatatWithClassName:@"Author" objectId:@"E3Nc222D"];
    [bquery whereObjectKey:@"postlist" relatedTo:author];
    
    
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (error) {
            NSLog(@"%@",error);
        } else {
            for (BmobObject *post in array) {
                NSLog(@"%@",[post objectForKey:@"title"]);
            }
        }
    }];
}

- (IBAction)modifyRelationPostBtn:(UIButton *)sender {
    //获取要添加关联关系的author
    BmobObject *author = [BmobObject objectWithoutDatatWithClassName:@"Author" objectId:@"E3Nc222D"];
    
    //新建relation对象
    BmobRelation *relation = [[BmobRelation alloc] init];
    [relation addObject:[BmobObject objectWithoutDatatWithClassName:@"Post" objectId:@"ahi8EEEP"]];
    //添加关联关系到postlist列中
    [author addRelation:relation forKey:@"postlist"];
    
    //异步更新obj的数据
    [author updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            NSLog(@"successful");
        }else{
            NSLog(@"error %@",[error description]);
        }
    }];
}

- (IBAction)delRelationPostBtn:(id)sender {
    //获取要添加关联关系的author
    BmobObject *author = [BmobObject objectWithoutDatatWithClassName:@"Author" objectId:@"E3Nc222D"];
    
    //新建relation对象
    BmobRelation *relation = [[BmobRelation alloc] init];
    [relation removeObject:[BmobObject objectWithoutDatatWithClassName:@"Post" objectId:@"ahi8EEEP"]];
    //添加关联关系到postlist列中
    [author addRelation:relation forKey:@"postlist"];
    
    //异步更新obj的数据
    [author updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            NSLog(@"successful");
        }else{
            NSLog(@"error %@",[error description]);
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
