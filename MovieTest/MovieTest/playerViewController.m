//
//  playerViewController.m
//  MovieTest
//
//  Created by 刘奥明 on 16/4/10.
//  Copyright © 2016年 liuting. All rights reserved.
//

#import "playerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface playerViewController ()
@property (strong, nonatomic) AVPlayerViewController *playerVC;
@end

@implementation playerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //创建URL
    NSURL *url = [NSURL URLWithString:@"http://192.168.6.147/1.mp4"];
    //直接创建AVPlayer，它内部也是先创建AVPlayerItem，这个只是快捷方法
    AVPlayer *player = [AVPlayer playerWithURL:url];
    //创建AVPlayerViewController控制器
    AVPlayerViewController *playerVC = [[AVPlayerViewController alloc] init];
    playerVC.player = player;
    playerVC.view.frame = self.view.frame;
    [self.view addSubview:playerVC.view];
    self.playerVC = playerVC;
    //调用控制器的属性player的开始播放方法
    [self.playerVC.player play];
}

@end
