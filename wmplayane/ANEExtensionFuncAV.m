//
//  ANEExtensionFunc.m
//  wmaneSDK
//
//  Created by wuyoujian on 17/3/1.
//  Copyright © 2017年 Asiainfo. All rights reserved.
//

#import "ANEExtensionFuncAV.h"

#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>


#define DISPATCH_STATUS_EVENT(extensionContext, code, status) FREDispatchStatusEventAsync((extensionContext), (uint8_t*)code, (uint8_t*)status)

@interface ANEExtensionFuncAV ()
@property (nonatomic, assign) FREContext context;
@property (nonatomic, strong) AVPlayerViewController * avPlayer;
@property (nonatomic, strong) MPMoviePlayerViewController *moviePlayer;
@end

@implementation ANEExtensionFuncAV

- (instancetype)initWithContext:(FREContext)extensionContext {
    
    self = [super init];
    if (self) {
        self.context = extensionContext;
    }
    return self;
}

- (FREResult)FREObject2NString:(FREObject)object toNString:(NSString **)value {
    
    FREResult result;
    uint32_t length = 0;
    const uint8_t* tempValue = NULL;
    
    result = FREGetObjectAsUTF8( object, &length, &tempValue );
    if( result != FRE_OK ) return result;
    
    *value = [NSString stringWithUTF8String: (char*) tempValue];
    return FRE_OK;
}

- (FREObject)playAV:(FREObject)text {
    return [self play:text isLoc:NO];
}


- (FREObject)playAVForLocal:(FREObject)text {
    return [self play:text isLoc:YES];
}

- (FREObject)play:(FREObject)text isLoc:(BOOL)isLoc {
    NSString *value = nil;
    FREResult ret = [self FREObject2NString:text toNString:&value];
    if (ret == FRE_OK) {
        
        NSURL *url = [NSURL URLWithString:value];
        if (isLoc) {
            url = [NSURL fileURLWithPath:value];
        }
        if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_9_0) {
            // iOS 9.0 以上系统的处理
            [self play9:url];
        } else {
            // iOS 9.0 以下系统的处理
            [self play8:url];
        }
    }
    
    DISPATCH_STATUS_EVENT(self.context, [@"play" UTF8String], [@"play" UTF8String]);
    return NULL;
}

- (void)play8:(NSURL *)URL {
    _moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:URL];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedCallback:) name:MPMoviePlayerPlaybackDidFinishNotification object:_moviePlayer.moviePlayer];
    [_moviePlayer.moviePlayer setControlStyle: MPMovieControlStyleFullscreen];
    //[_moviePlayer.moviePlayer play];
    
    UIApplication *application = [UIApplication sharedApplication];
    UIViewController *rootVC = application.keyWindow.rootViewController;
    [rootVC presentMoviePlayerViewControllerAnimated:_moviePlayer];
}

- (void)movieFinishedCallback:(NSNotification *)notify {
    
    MPMoviePlayerController *vc = [notify object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:vc];
    
    _moviePlayer = nil;
}

- (void)play9:(NSURL *)URL {
    _avPlayer = [[AVPlayerViewController alloc] init];
    _avPlayer.player = [[AVPlayer alloc] initWithURL:URL];
    /*
     可以设置的值及意义如下：
     AVLayerVideoGravityResizeAspect   不进行比例缩放 以宽高中长的一边充满为基准
     AVLayerVideoGravityResizeAspectFill 不进行比例缩放 以宽高中短的一边充满为基准
     AVLayerVideoGravityResize     进行缩放充满屏幕
     */
    _avPlayer.videoGravity = AVLayerVideoGravityResizeAspect;
    //[_avPlayer.player play];
    
    UIApplication *application = [UIApplication sharedApplication];
    UIViewController *rootVC = application.keyWindow.rootViewController;
    [rootVC presentViewController:_avPlayer animated:YES completion:nil];
    
}


@end
