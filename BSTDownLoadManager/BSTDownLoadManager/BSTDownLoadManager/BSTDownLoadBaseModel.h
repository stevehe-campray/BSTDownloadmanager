//
//  BSTDownLoadBaseModel.h
//  BSTDownLoadManager
//
//  Created by hejingjin on 17/5/5.
//  Copyright © 2017年 teamsun. All rights reserved.
//

//下载内容基类
#import <Foundation/Foundation.h>
@class BSTDownLoadOperation;

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, BSTDownloadStatus) {
    BSTDownloadStatusNone = 0,       // 初始状态
    BSTDownloadStatusRunning = 1,    // 下载中
    BSTDownloadStatusSuspended = 2,  // 下载暂停
    BSTDownloadStatusCompleted = 3,  // 下载完成
    BSTDownloadStatusFailed  = 4,    // 下载失败
    BSTDownloadStatusWaiting = 5,    // 等待下载
    BSTDownloadStatusCancel = 6      // 取消下载
};



typedef NS_ENUM(NSInteger, BSTDownloadType) {
    BSTDownloadTypeNone = 0,       // 默认图片
    BSTDownloadTypeVideo = 1,    // voide
    BSTDownloadTypeMusic = 2,  // 音乐
    BSTDownloadTypePDF = 3,  // PDF
    BSTDownloadTypeDoc  = 4,    // doc文件
};

@interface BSTDownLoadBaseModel : NSObject

@property(nonatomic,copy)NSString *downloadurl;//服务器文件地址

@property(nonatomic,copy)NSString *fileurl; //文件存放位置

@property(nonatomic,copy)NSString *filename; //文件名

@property(nonatomic,assign)CGFloat progress;//下载进度

@property (nonatomic, strong) NSData *resumeData;//断点内容

@property (nonatomic, assign) BSTDownloadType downloadtype;

@property(nonatomic,assign)BSTDownloadStatus downloadstatus;

@property (nonatomic,strong)BSTDownLoadOperation *operation;



@end
