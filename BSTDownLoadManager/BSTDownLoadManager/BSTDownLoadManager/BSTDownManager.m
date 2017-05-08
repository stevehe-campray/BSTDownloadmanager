//
//  BSTDownManager.m
//  BSTDownLoadManager
//
//  Created by hejingjin on 17/5/5.
//  Copyright © 2017年 teamsun. All rights reserved.
//

#import "BSTDownManager.h"
#import "BSTDownLoadOperation.h"
static BSTDownManager *_bstDownManager = nil;

@interface BSTDownManager()<NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSURLSession *session;

@end


@implementation BSTDownManager


+(instancetype)shared{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _bstDownManager = [[BSTDownManager alloc] init];
    });
    return _bstDownManager;
}



-(instancetype)init{
    
    if (self = [super init]) {
//        _videoModels = [[NSMutableArray alloc] init];
        self.queue = [[NSOperationQueue alloc] init];
        self.queue.maxConcurrentOperationCount = 4;
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        // 不能传self.queue
        self.session = [NSURLSession sessionWithConfiguration:config
                                                     delegate:self
                                                delegateQueue:nil];
    }
    
    return self;
}

-(void)startWithModel:(BSTDownLoadBaseModel *)model{
    if (model.downloadstatus != BSTDownloadStatusCompleted) {
        model.downloadstatus = BSTDownloadStatusRunning;
        
        if (model.operation == nil) {
            model.operation = [[BSTDownLoadOperation alloc] initWithModel:model
                                                            session:self.session];
            [self.queue addOperation:model.operation];
            [model.operation start];
        } else {
            [model.operation resume];
        }
    }
}

-(void)suspendWithModel:(BSTDownLoadBaseModel *)model{
    if (model.downloadstatus != BSTDownloadStatusCompleted) {
        [model.operation suspend];
    }
}

-(void)resumeWithModel:(BSTDownLoadBaseModel *)model{
    if (model.downloadstatus != BSTDownloadStatusCompleted) {
        [model.operation resume];
    }
}

-(void)stopWithModel:(BSTDownLoadBaseModel *)model{
    if (model.operation) {
        [model.operation cancel];
    }
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
        didFinishDownloadingToURL:(NSURL *)location {
        //下载完成
    
//    NSError *error = [NSError new];
    if (downloadTask.bst_downloadModel.fileurl) {
        NSURL *toURL = [NSURL fileURLWithPath:downloadTask.bst_downloadModel.fileurl];
        NSFileManager *manager = [NSFileManager defaultManager];
        [manager moveItemAtURL:location toURL:toURL error:nil];
//        [manager copyItemAtURL:location toURL:toURL error:nil];
//        [manager moveItemAtPath:location.path toPath:toURL.path error:&error];

    }
//    NSLog(@"%@",downloadTask.bst_downloadModel.fileurl);
    [downloadTask.bst_downloadModel.operation downloadFinished];
}
//结束witherror
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error == nil) {
            //下载完成
            task.bst_downloadModel.downloadstatus = BSTDownloadStatusCompleted;
            [task.bst_downloadModel.operation downloadFinished];
        } else if (task.bst_downloadModel.downloadstatus== BSTDownloadStatusSuspended) {

            task.bst_downloadModel.downloadstatus = BSTDownloadStatusSuspended;
        } else if ([error code] < 0) {
            // 网络异常
            task.bst_downloadModel.downloadstatus = BSTDownloadStatusFailed;
        }
    });
}

//下载进度
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
//    double byts =  totalBytesWritten * 1.0 / 1024 / 1024;
//    double total = totalBytesExpectedToWrite * 1.0 / 1024 / 1024;
//    NSString *text = [NSString stringWithFormat:@"%.1lfMB/%.1fMB",byts,total];
    CGFloat progress = totalBytesWritten / (CGFloat)totalBytesExpectedToWrite;
    
    dispatch_async(dispatch_get_main_queue(), ^{
//        downloadTask.bst_downloadModel.progressText = text;
        downloadTask.bst_downloadModel.progress = progress;
        NSLog(@"%f",progress);
    });
}
//
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes {
//    double byts =  fileOffset * 1.0 / 1024 / 1024;
//    double total = expectedTotalBytes * 1.0 / 1024 / 1024;
//    NSString *text = [NSString stringWithFormat:@"%.1lfMB/%.1fMB",byts,total];
    CGFloat progress = fileOffset / (CGFloat)expectedTotalBytes;
    
    dispatch_async(dispatch_get_main_queue(), ^{
//        downloadTask.hyb_videoModel.progressText = text;
        downloadTask.bst_downloadModel.progress = progress;
        NSLog(@"%f",progress);
    });
}


@end
