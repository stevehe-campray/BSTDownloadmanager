//
//  BSTDownLoadOperation.h
//  BSTDownLoadManager
//
//  Created by hejingjin on 17/5/5.
//  Copyright © 2017年 teamsun. All rights reserved.
//

//下载队列
#import <Foundation/Foundation.h>
#import "BSTDownLoadBaseModel.h"

@interface NSURLSessionTask (VideoModel)

// 为了更方便去获取，而不需要遍历，采用扩展的方式，可直接提取，提高效率
@property (nonatomic, weak) BSTDownLoadBaseModel *bst_downloadModel;


@end


@interface BSTDownLoadOperation : NSOperation


@property(nonatomic,weak)BSTDownLoadBaseModel *model;

@property(nonatomic,strong,readonly)NSURLSessionTask *downloadTask;


-(instancetype)initWithModel:(BSTDownLoadBaseModel *)model session:(NSURLSession *)session;


-(void)suspend;

-(void)resume;

-(void)downloadFinished;

//-(void)cancel;
-(void)cancel;


@end
