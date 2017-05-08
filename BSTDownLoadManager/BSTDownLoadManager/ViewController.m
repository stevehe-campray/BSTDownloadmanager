//
//  ViewController.m
//  BSTDownLoadManager
//
//  Created by hejingjin on 17/5/5.
//  Copyright © 2017年 teamsun. All rights reserved.
//

#import "ViewController.h"
#import "BSTDownLoadBaseModel.h"
#import "BSTDownManager.h"
@interface ViewController ()
@property(nonatomic,strong)BSTDownLoadBaseModel *downloadmodel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    BSTDownLoadBaseModel *downloadmodel = [[BSTDownLoadBaseModel alloc] init];
    downloadmodel.downloadurl = @"https://gss0.baidu.com/-Po3dSag_xI4khGko9WTAnF6hhy/zhidao/pic/item/8c1001e93901213f9b28233756e736d12e2e95c5.jpg";
    downloadmodel.filename = @"12";
    _downloadmodel = downloadmodel;
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    [button setBackgroundColor:[UIColor redColor]];
    [button addTarget:self action:@selector(buttonpressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    // Do any additional setup after loading the view, typically from a nib.
}


-(void)buttonpressed:(UIButton *)sender{
    
    sender.selected = !sender.selected;
    if (_downloadmodel.downloadstatus == BSTDownloadStatusNone) {
        [[BSTDownManager shared] startWithModel:_downloadmodel];
    }else if (!sender.selected){
        [[BSTDownManager shared] suspendWithModel:_downloadmodel];
    }else{
        [[BSTDownManager shared] resumeWithModel:_downloadmodel];
    }
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
