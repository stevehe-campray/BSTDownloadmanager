//
//  BSTDownManager.h
//  BSTDownLoadManager
//
//  Created by hejingjin on 17/5/5.
//  Copyright © 2017年 teamsun. All rights reserved.
//

//下载管理器  单例模式  各个地方都能进行访问
#import <Foundation/Foundation.h>


#import "BSTDownLoadBaseModel.h"


@interface BSTDownManager : NSObject


+(instancetype)shared;

-(void)startWithModel:(BSTDownLoadBaseModel *)model;

-(void)suspendWithModel:(BSTDownLoadBaseModel *)model;

-(void)resumeWithModel:(BSTDownLoadBaseModel *)model;

-(void)stopWithModel:(BSTDownLoadBaseModel *)model;


@end
