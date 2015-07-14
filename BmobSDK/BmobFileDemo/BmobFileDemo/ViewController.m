//
//  ViewController.m
//  BmobFileDemo
//
//  Created by limao on 15/4/28.
//  Copyright (c) 2015年 Bmob. All rights reserved.
//

#import "ViewController.h"
#import <BmobSDK/Bmob.h>
#import <BmobSDK/BmobFile.h>
#import <BmobSDK/BmobProFile.h>
@interface ViewController ()

@end

@implementation ViewController

# pragma mark - 新文件管理

- (IBAction)newUploadFileBtn:(id)sender {    
    //构造文件路径
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *path       = [mainBundle bundlePath];
    path                 = [path stringByAppendingPathComponent:@"image.jpg"];
    
    NSLog(@"%i",[[NSFileManager defaultManager] fileExistsAtPath:path]); 
    
    //上传文件
    [BmobProFile uploadFileWithPath:path block:^(BOOL isSuccessful, NSError *error, NSString *filename, NSString *url,BmobFile *bmobFile) {
        if (isSuccessful) {
//            //上传文件后将返回的文件名及url进行保存
//            BmobObject *file = [BmobObject objectWithClassName:@"filedemoNewFileRecord"];
//            [file setObject:filename forKey:@"name"];
//            [file setObject:url forKey:@"url"];
//            [file saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
//                if (isSuccessful) {
//                    //添加成功后的动作
//                    NSLog(@"%@",@"successful");
//                } else if (error){
//                    //发生错误后的动作
//                    NSLog(@"%@",error);
//                } else {
//                    NSLog(@"Unknow error");
//                }
//            }];
            
            //上传成功后返回文件名及url
            NSLog(@"filename:%@",filename);
            NSLog(@"url:%@",url);
            NSLog(@"bmobFile:%@\n",bmobFile);
            NSLog(@"error%@",error);
            

        } else{
            if(error){
                NSLog(@"error%@",error);
            }
        }
    } progress:^(CGFloat progress) {
        //上传进度，此处可编写进度条逻辑
        NSLog(@"progress %f",progress);
    }];
}

- (IBAction)newUploadFileByNSDataBtn:(id)sender {
    //构造NSData
    NSString *mainBundlePath = [[NSBundle mainBundle] bundlePath];
    NSData *data = [NSData dataWithContentsOfFile:[mainBundlePath stringByAppendingPathComponent:@"image.jpg"]];
    
    //上传文件
    [BmobProFile uploadFileWithFilename:@"image.jpg" fileData:data block:^(BOOL isSuccessful, NSError *error, NSString *filename, NSString *url,BmobFile *bmobFile) {
        if (isSuccessful) {
            //打印文件名
            NSLog(@"filename %@",filename);
            //打印url
            NSLog(@"url %@",url);
            NSLog(@"bmobFile%@\n",bmobFile);
        
        } else {
            if (error) {
                NSLog(@"error %@",error);
            }
        }
    } progress:^(CGFloat progress) {
        //上传进度，此处可编写进度条逻辑
        NSLog(@"progress %f",progress);
    }];
}

- (IBAction)uploadFileBatchByPathBtn:(UIButton *)sender {
    //构造上传文件路径数组
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *path       = [mainBundle bundlePath];
    NSString *path1 = [path stringByAppendingPathComponent:@"image.jpg"];
    NSString *path2 = [path stringByAppendingPathComponent:@"zipfile.zip"];
    NSString *path3 = [path stringByAppendingPathComponent:@"text.txt"];
    NSArray *array = @[path1,path2,path3];
    
    //上传文件
    [BmobProFile uploadFilesWithPaths:array resultBlock:^(NSArray *pathArray, NSArray *urlArray, NSArray *bmobFileArray,NSError *error) {
        //路径数组和url数组（url数组里面的元素为NSString）
        NSLog(@"urlArray %@ urlArray %@",pathArray,urlArray);
        for (BmobFile* bmobFile in bmobFileArray ) {
            NSLog(@"%@",bmobFile);
        }
    } progress:^(NSUInteger index, CGFloat progress) {
        //index表示正在上传的文件其路径在数组当中的索引，progress表示该文件的上传进度
        NSLog(@"index %lu progress %f",(unsigned long)index,progress);
    }];
}

- (IBAction)uploadFileBatchByNSDataBtn:(id)sender {
    //构造上传文件data字典数组
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *path       = [mainBundle bundlePath];
    NSString *path1 = [path stringByAppendingPathComponent:@"image.jpg"];
    NSString *path2 = [path stringByAppendingPathComponent:@"zipfile.zip"];
    NSString *path3 = [path stringByAppendingPathComponent:@"text.txt"];
    
    NSData* data1 = [NSData dataWithContentsOfFile:path1];
    NSData* data2 = [NSData dataWithContentsOfFile:path2];
    NSData* data3 = [NSData dataWithContentsOfFile:path3];
    
    NSDictionary *dic1 = [[NSDictionary alloc] initWithObjectsAndKeys:@"image.jpg",@"filename",data1,@"data",nil];
    NSDictionary *dic2 = [[NSDictionary alloc] initWithObjectsAndKeys:@"zipfile.zip",@"filename",data2,@"data",nil];
    NSDictionary *dic3 = [[NSDictionary alloc] initWithObjectsAndKeys:@"text.txt",@"filename",data3,@"data",nil];
    
    NSArray *array = @[dic1,dic2,dic3];
    
    //上传文件，dataArray 数组中存放NSDictionary，NSDictionary里面的格式为@{@"filename":@"你的文件名",@"data":文件的data}
    [BmobProFile uploadFilesWithDatas:array resultBlock:^(NSArray *filenameArray, NSArray *urlArray,NSArray *bmobFileArray, NSError *error) {
        if (error) {
            NSLog(@"%@",error);
        } else {
            //路径数组和url数组（url数组里面的元素为NSString）
            NSLog(@"fileArray %@ urlArray %@",filenameArray,urlArray);
            for (BmobFile* bmobFile in bmobFileArray ) {
                NSLog(@"%@",bmobFile);
            }
        }
    } progress:^(NSUInteger index, CGFloat progress) {
        //index表示正在上传的文件其路径在数组当中的索引，progress表示该文件的上传进度
        NSLog(@"index %lu progress %f",(unsigned long)index,progress);
    }];
}

- (IBAction)newdownloadFileBtn:(id)sender {
    //上传过的文件的文件名
    NSString *filename = @"91E6DF554A964C66A33B2E844312BA08.jpg";
    [BmobProFile downloadFileWithFilename:filename block:^(BOOL isSuccessful, NSError *error, NSString *filepath) {
        //下载的文件所存放的路径
        if (isSuccessful) {
            NSLog(@"filepath:%@",filepath);
        } else if (error) {
            NSLog(@"%@",error);
        } else {
            NSLog(@"Unknow error");
        }
    } progress:^(CGFloat progress) {
        //下载的进度
        NSLog(@"progress %f",progress);
    }];
}


- (IBAction)useSignedUrlDownloadFileBtn:(id)sender {
    NSString *signUrl = [BmobProFile signUrlWithFilename:@"91E6DF554A964C66A33B2E844312BA08.jpg" url:@"http://newfile.codenow.cn:8080/91E6DF554A964C66A33B2E844312BA08.jpg" validTime:30 accessKey:@"2fff252817f32dcf3d37382a342e08bc" secretKey:@"123456"];
    NSLog(@"%@",signUrl);
}

- (IBAction)getAcessUrlBtn:(id)sender {
    [BmobProFile getFileAcessUrlWithFileName:@"78034E68460F4F2DBD244B5666717907.jpg" callBack:^(BmobFile *file, NSError *error) {
        if (error) {
            NSLog(@"%@",error);
        } else {
            NSLog(@"%@",file);
        }
    }];
}

- (IBAction)delFileBtn:(id)sender {
    [BmobProFile deleteFileWithFileName:@"78034E68460F4F2DBD244B5666717907.jpg" callBack:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            NSLog(@"delete successfully");
        } else {
            NSLog(@"%@",error);
        }
    }];
}


# pragma mark - 旧文件管理
- (IBAction)synUploadFileBtn:(UIButton *)sender {
    //获取Document路径
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirecotry=[paths objectAtIndex:0];
    
    //打印路径
    NSLog(@"%@",documentDirecotry);
    
    BmobFile *bmobFile = [[BmobFile alloc] initWithClassName:@"filedemoUserFile"
                                                withFilePath:[documentDirecotry stringByAppendingPathComponent:@"test.txt"]];
    //如果文件保存成功，则把文件添加到filetype列
    if ([bmobFile save]) {
        BmobObject *fileRecord = [BmobObject objectWithClassName:@"filedemoUserFile"];
        [fileRecord setObject:bmobFile forKey:@"filetype"];
        [fileRecord saveInBackgroundWithResultBlock:^(BOOL isSuccessful,NSError *error){
            if (isSuccessful) {
                NSLog(@"%@",@"上传成功");
            } else {
                NSLog(@"%@",error);
            }
        }];
    }
}

- (IBAction)asynUploadFile:(id)sender {
    NSBundle    *bundle = [NSBundle mainBundle];
    NSString *fileString = [NSString stringWithFormat:@"%@/cs.txt" ,[bundle bundlePath] ];
    NSLog(@"%@",fileString);
    
    BmobObject *obj = [[BmobObject alloc] initWithClassName:@"filedemoUserFile"];
    BmobFile *file1 = [[BmobFile alloc] initWithFilePath:fileString];
    [file1 saveInBackground:^(BOOL isSuccessful, NSError *error) {
        //如果文件保存成功，则把文件添加到filetype列
        if (isSuccessful) {
            [obj setObject:file1  forKey:@"filetype"];
            [obj saveInBackground];
            //打印file文件的url地址
            NSLog(@"file1 url %@",file1.url);
        }else{
            //进行处理
        }
    }];
}

- (IBAction)uploadFileAndPrintProgress:(id)sender {
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *fileString = [NSString stringWithFormat:@"%@/test.txt" ,[bundle bundlePath] ];
    
    BmobFile *file1 = [[BmobFile alloc] initWithFilePath:fileString];
    [file1 saveInBackground:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            BmobObject *obj = [[BmobObject alloc] initWithClassName:@"filedemoUserFile"];
            [obj setObject:file1  forKey:@"filetype"];
            [obj saveInBackground];
            NSLog(@"file1 url %@",file1.url);
        } else {
            NSLog(@"%@",error);
        }
    } withProgressBlock:^(float progress) {
        NSLog(@"上传进度%.2f",progress);
    }];
}
- (IBAction)uploadByShardingBtn:(UIButton *)sender {
    NSBundle    *bundle = [NSBundle mainBundle];
    //上传cs.txt文件
    NSString *fileString = [NSString stringWithFormat:@"%@/30个头像PNG图标.zip" ,[bundle bundlePath] ];
    
    //创建BmobFile对象
    BmobFile *file1 = [[BmobFile alloc] initWithFilePath:fileString];
    [file1 saveInBackgroundByDataSharding:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            //如果成功，保存文件到userFile
            BmobObject *obj = [[BmobObject alloc] initWithClassName:@"filedemoUserFile"];
            [obj setObject:file1  forKey:@"filetype"];
            [obj saveInBackground];
        }else{
            //失败，打印错误信息
            NSLog(@"error: %@",[error description]);
        }
    } ];
}
- (IBAction)uploadByShardingPrintProgressBtn:(id)sender {
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *fileString = [NSString stringWithFormat:@"%@/30个头像PNG图标.zip",[bundle bundlePath]];
    
    BmobFile *file1 = [[BmobFile alloc] initWithFilePath:fileString];
    [file1 saveInBackgroundByDataSharding:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            BmobObject *obj = [[BmobObject alloc] initWithClassName:@"filedemoUserFile"];
            [obj setObject:file1  forKey:@"filetype"];
            [obj saveInBackground];
            NSLog(@"file1 url %@",file1.url);
        } else {
            NSLog(@"%@",error);
        }
        
    } progressBlock:^(float progress) {
        NSLog(@"上传进度%.2f",progress);
    }];
}
- (IBAction)uploadFileBatchBtn:(id)sender {
    NSBundle    *bundle = [NSBundle mainBundle];
    //文件cncc.jpg的路径
    NSString *fileString1 = [NSString stringWithFormat:@"%@/image.jpg" ,[bundle bundlePath] ];
    //文件cs.txt的路径
    NSString *fileString2 = [NSString stringWithFormat:@"%@/zipfile.zip" ,[bundle bundlePath] ];
    NSString *fileString3 = [NSString stringWithFormat:@"%@/text.txt" ,[bundle bundlePath] ];
    NSArray *filesArray = @[fileString1,fileString2,fileString3];
    
    [BmobFile filesUploadBatchWithPaths:filesArray
                          progressBlock:^(int index, float progress) {
                              //index 上传数组的下标，progress当前文件的进度
                              NSLog(@"index %d progress %f",index,progress);
                          } resultBlock:^(NSArray *array, BOOL isSuccessful, NSError *error) {
                              //array 文件数组，isSuccessful 成功或者失败,error 错误信息
                              BmobObject *obj = [[BmobObject alloc] initWithClassName:@"filedemoUserFile"];
                              for (int i = 0 ; i < array.count ;i ++) {
                                  BmobFile *file = array [i];
                                  NSString *key = [NSString stringWithFormat:@"userFile%d",i];
                                  [obj setObject:file  forKey:key];
                              }
                              [obj saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
                              }];
                          }];
}

- (IBAction)downloadFileBtn:(UIButton *)sender {
    BmobQuery *bquery = [[BmobQuery alloc] initWithClassName:@"filedemoUserFile"];
    [bquery getObjectInBackgroundWithId:@"be0cb851e4" block:^(BmobObject *object, NSError *error) {
        if (error) {
            NSLog(@"%@",error);
        } else {
            BmobFile *file = (BmobFile*)[object objectForKey:@"filetype"];
            //打印出可以下载的url
            NSLog(@"%@",file.url);
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
