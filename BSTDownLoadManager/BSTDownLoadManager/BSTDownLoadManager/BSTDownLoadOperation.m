//
//  BSTDownLoadOperation.m
//  BSTDownLoadManager
//
//  Created by hejingjin on 17/5/5.
//  Copyright © 2017年 teamsun. All rights reserved.
//

#import "BSTDownLoadOperation.h"
#import <objc/runtime.h>
//监听状态改变
#define kKVOBlock(KEYPATH, BLOCK) \
[self willChangeValueForKey:KEYPATH]; \
BLOCK(); \
[self didChangeValueForKey:KEYPATH];

static NSTimeInterval kTimeoutInterval = 120.0;
@interface BSTDownLoadOperation () {
    BOOL _finished; //完成
    BOOL _executing; //执行
}

@property (nonatomic, strong) NSURLSessionDownloadTask *task;
@property (nonatomic, weak) NSURLSession *session;

@end



@implementation BSTDownLoadOperation


- (instancetype)initWithModel:(BSTDownLoadBaseModel *)model session:(NSURLSession *)session{
    self = [super init];
    if (self) {
        self.model = model;
        self.session = session;
        [self startRequest];
    }
    return self;
    
}

- (void)dealloc {
    self.task = nil;
}

- (void)startRequest {
    NSURL *url = [NSURL URLWithString:self.model.downloadurl];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:kTimeoutInterval];
    self.task = [self.session downloadTaskWithRequest:request];
    [self configTask];
}



- (void)configTask {
    
    self.task.bst_downloadModel = self.model;
    
}


//懒加载 监听task任务状态
- (void)setTask:(NSURLSessionDownloadTask *)task {
    
    [_task removeObserver:self forKeyPath:@"state"];
    
    if (_task != task) {
        _task = task;
    }
    
    if (task != nil) {
        [task addObserver:self
               forKeyPath:@"state"
                  options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (NSURLSessionDownloadTask *)downloadTask {
    return self.task;
}

- (BOOL)isExecuting {
    return _executing;
}

- (BOOL)isFinished {
    return _finished;
}

- (BOOL)isConcurrent {
    return YES;
}

- (void)completeOperation {
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    
    _executing = NO;
    _finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"state"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (self.task.state) {
                case NSURLSessionTaskStateSuspended: {
                    self.model.downloadstatus = BSTDownloadStatusSuspended;
                    break;
                }
                case NSURLSessionTaskStateCompleted:
                    if (self.model.progress >= 1.0) {
                        self.model.downloadstatus = BSTDownloadStatusCompleted;
                    } else {
                        self.model.downloadstatus = BSTDownloadStatusSuspended;
                    }
                default:
                    break;
            }
        });
    }
}



//任务开始
- (void)start {
    if (self.isCancelled) {
        kKVOBlock(@"isFinished", ^{
            _finished = YES;
        });
        return;
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    if (self.model.resumeData) {
        //继续上次下载
        [self resume];
    } else {
        [self.task resume];
        self.model.downloadstatus = BSTDownloadStatusRunning;
    }
    _executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

//暂停下载
-(void)suspend{
    if (self.task) {
        __weak __typeof(self) weakSelf = self;
        __block NSURLSessionDownloadTask *weakTask = self.task;
        [self willChangeValueForKey:@"isExecuting"];
        __block BOOL isExecuting = _executing;
        
        [self.task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            weakSelf.model.resumeData = resumeData;
            weakTask = nil;
            isExecuting = NO;
            [weakSelf didChangeValueForKey:@"isExecuting"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.model.downloadstatus = BSTDownloadStatusSuspended;
            });
        }];
        
        [self.task suspend];
    }
}
//恢复下载
-(void)resume{
    if (self.model.downloadstatus == BSTDownloadStatusCompleted) {
        return;
    }
    self.model.downloadstatus = BSTDownloadStatusRunning;
    
    if (self.model.resumeData) {
        self.task = [self.session downloadTaskWithResumeData:self.model.resumeData];
        [self configTask];
    } else if (self.task == nil
               || (self.task.state == NSURLSessionTaskStateCompleted && self.model.progress < 1.0)) {
        [self startRequest];
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    [self.task resume];
    _executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
}
//下载完成
- (void)downloadFinished {
    
    [self completeOperation];
}


//取消下载
- (void)cancel{
    
    [self willChangeValueForKey:@"isCancelled"];
    [super cancel];
    [self.task cancel];
    self.task = nil;
    [self didChangeValueForKey:@"isCancelled"];
    
    [self completeOperation];
    
}


@end




static const void *h_bst_downloadModelKey = "h_bst_downloadModelKey";

@implementation NSURLSessionTask (VideoModel)


-(void)setBst_downloadModel:(BSTDownLoadBaseModel *)bst_downloadModel{
        objc_setAssociatedObject(self, h_bst_downloadModelKey, bst_downloadModel, OBJC_ASSOCIATION_ASSIGN);
}

-(BSTDownLoadBaseModel *)bst_downloadModel{
      return objc_getAssociatedObject(self, h_bst_downloadModelKey);
}


@end