//
//  XMVideoDownloader.m
//  WSY_XMHelper
//
//  Created by 袁仕崇 on 14/12/9.
//  Copyright (c) 2014年 wilson-yuan. All rights reserved.
//

#import "XMVideoDownloader.h"
#import <GCDObjC/GCDObjC.h>
#import "XMM3U8Handler.h"
#import "XMM3U8PlayList.h"
#import "XMM3U8SegmentInfo.h"
#import "XMM3U8SegmentDownloader.h"

@interface XMVideoDownloader ()
{
    NSMutableArray *_downloadArray;
    XMM3U8PlayList *_playList;
    float _totalProgress;
    BOOL bDownLoading;
    CGFloat _totleNumber;
}
@property (nonatomic, strong) NSMutableArray *downloadArray;
@property (nonatomic, strong) XMM3U8PlayList *playList;
@property (nonatomic, assign) float totalProgress;


@end;


@implementation XMVideoDownloader

@synthesize downloadArray = _downloadArray;
@synthesize playList = _playList;
@synthesize totalProgress = _totalProgress;


+ (XMVideoDownloader *)defaultDownloader
{
    GCDSharedInstance(^{
        return [[self alloc] init];
    })
}

- (void)downloader_StartDownLoadWithUrlString:(NSString *)urlString  failedHandler:(void (^)())failedHandler
{
    
    NSString *uuid = @"movie";
    [[XMM3U8Handler defaultHandler] handler_parseUrlString:urlString uuid:uuid completionHandler:^(XMM3U8PlayList *playList) {
        self.downloadArray = [NSMutableArray array];
        for (int i = 0; i < playList.length; i++) {
            NSString *fileName = [NSString stringWithFormat:@"id%d",i];
            XMM3U8SegmentInfo *segmentInfo = [playList list_getSegment:i];
            XMM3U8SegmentDownloader *sgDownloader = [[XMM3U8SegmentDownloader alloc] initWithUrlString:segmentInfo.locationUrl filePath:playList.uuid fileName:fileName];
            [self.downloadArray addObject:sgDownloader];
        }
        bDownLoading = YES;
        _totleNumber = self.downloadArray.count;
        for (XMM3U8SegmentDownloader *downloader in self.downloadArray) {
            [downloader startWitProgress:^(CGFloat progress) {
                NSLog(@"sg progress: %.2f", progress);
            } completion:^(XMM3U8SegmentDownloader *downloader) {
                [self.downloadArray removeObject:downloader];
                CGFloat totleProgress= (_totleNumber - self.downloadArray.count)/_totleNumber;
                NSLog(@"======totle Progress: %.2f", totleProgress);
            }];
        }
    } failedHandler:^{
        failedHandler();
    }];
}

@end
