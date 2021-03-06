//
//  BSTDownLoadBaseModel.m
//  BSTDownLoadManager
//
//  Created by hejingjin on 17/5/5.
//  Copyright © 2017年 teamsun. All rights reserved.
//

#import "BSTDownLoadBaseModel.h"

@implementation BSTDownLoadBaseModel

- (NSString *)fileurl {
    
    
    @autoreleasepool {
        NSString *typestr;
        
        switch (self.downloadtype) {
            case BSTDownloadTypeVideo:
                typestr = @".mp4";
                break;
            case BSTDownloadTypeMusic:
                typestr = @".mp3";
                break;
            case BSTDownloadTypePDF:
                typestr = @".pdf";
                break;
            case BSTDownloadTypeDoc:
                typestr = @".doc";
                break;
            default:
                typestr = @".png";
                break;
        }
        NSString *pathName = [NSString stringWithFormat:@"/Documents/%@%@",self.filename,typestr];
        NSString *filePath = [NSHomeDirectory() stringByAppendingString:pathName];
        return filePath;
    }

}

-(void)setProgress:(CGFloat)progress{
    if (_progress != progress) {
       _progress = progress;
       
        if (self.downloadprogress) {
            self.downloadprogress(self);
        }
    }
    
}

-(void)setDownloadstatus:(BSTDownloadStatus)downloadstatus{
    if (_downloadstatus != downloadstatus) {
        _downloadstatus = downloadstatus;
        if (self.downloadstatuschanged) {
            self.downloadstatuschanged(self);
        }
    }
}
@end
