//
//  ViewController.m
//  MovieTest
//
//  Created by 刘奥明 on 16/4/10.
//  Copyright © 2016年 liuting. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()
@property (strong, nonatomic) AVPlayer *player;//视频播放器
@property (strong, nonatomic) AVPlayerLayer *playerLayer;//视频播放图层
@property (strong, nonatomic) IBOutlet UIView *movieView;//播放容器视图
@property (strong, nonatomic) IBOutlet UIProgressView *progressView;//进度条
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentView;//选择栏
@property (strong, nonatomic) NSArray *playerItemArray;//视频播放URL列表
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //属性初始化
    self.segmentView.selectedSegmentIndex = 0;
    self.progressView.progress = 0;
    self.playerItemArray = @[@"http://192.168.6.147/1.mp4",
                             @"http://192.168.6.147/2.mp4",
                             @"http://192.168.6.147/3.mp4"];
    //视频播放器初始化
    [self initAVPlayer];
    //视频播放器显示图层初始化
    [self initAVPlayerLayer];
    //视频开始播放
    [self.player play];
    
}
- (void)dealloc {
    //移除监听和通知
    [self removeObserverFromPlayerItem:self.player.currentItem];
    [self removeNotificationFromPlayerItem];
}
#pragma mark UI点击
/* 点击播放按钮 */
- (IBAction)playMovie:(UIButton *)sender {
    sender.enabled = NO;
    if ( self.player.rate == 0 ) {//播放速度为0，表示播放暂停
        sender.titleLabel.text = @"暂停";
        [self.player play];//启动播放
    } else if ( self.player.rate == 1.0 ) {//播放速度为1.0，表示正在播放
        sender.titleLabel.text = @"播放";
        [self.player pause];//暂停播放
    }
    sender.enabled = YES;
}
/* 选择视频播放列表 */
- (IBAction)segmentValueChange:(UISegmentedControl *)sender {
    //先移除对AVPlayerItem的所有监听
    [self removeNotificationFromPlayerItem];
    [self removeObserverFromPlayerItem:self.player.currentItem];
    //获取新的播放内容
    AVPlayerItem *playerItem = [self getPlayItemByNum:sender.selectedSegmentIndex];
    //添加属性监听
    [self addObserverToPlayerItem:playerItem];
    //替换视频内容
    [self.player replaceCurrentItemWithPlayerItem:playerItem];
    //添加播放完成监听
    [self addNotificationToPlayerItem];
}

/* 获取播放内容对象，一个AVPlayerItem对应一个视频文件 */
- (AVPlayerItem *)getPlayItemByNum:(NSInteger)num {
    if (num >= self.playerItemArray.count) {
        return nil;
    }
    //创建URL
    NSString *urlStr = self.playerItemArray[num];
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlStr];
    //创建播放内容对象
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
    return item;
}

/* 初始化视频播放器 */
- (void)initAVPlayer {
    //获取播放内容
    AVPlayerItem *item = [self getPlayItemByNum:0];
    //创建视频播放器
    AVPlayer *player = [AVPlayer playerWithPlayerItem:item];
    self.player = player;
    //添加播放进度监听
    [self addProgressObserver];
    //添加播放内容KVO监听
    [self addObserverToPlayerItem:item];
    //添加通知中心监听播放完成
    [self addNotificationToPlayerItem];
}

#pragma mark - 初始化
/* 初始化播放器图层对象 */
- (void)initAVPlayerLayer {
    //创建视频播放器图层对象
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    layer.frame = self.movieView.bounds;//尺寸大小
    layer.videoGravity = AVLayerVideoGravityResizeAspect;//视频填充模式
    //添加进控件图层
    [self.movieView.layer addSublayer:layer];
    self.playerLayer = layer;
    self.movieView.layer.masksToBounds = YES;
}

#pragma mark - 通知中心
- (void)addNotificationToPlayerItem {
    //添加通知中心监听视频播放完成
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerDidFinished:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.player.currentItem];
}
- (void)removeNotificationFromPlayerItem {
    //移除通知中心的通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
/* 播放完成后会调用 */
- (void)playerDidFinished:(NSNotification *)notification {
    //自动播放下一个视频
    NSInteger currentIndex = self.segmentView.selectedSegmentIndex;
    self.segmentView.selectedSegmentIndex = (currentIndex + 1)%self.playerItemArray.count;
    [self segmentValueChange:self.segmentView];
}

#pragma mark - KVO监听属性
/* 添加KVO，监听播放状态和缓冲加载状况 */
- (void)addObserverToPlayerItem:(AVPlayerItem *)item {
    //监控状态属性
    [item addObserver:self
           forKeyPath:@"status"
              options:NSKeyValueObservingOptionNew
              context:nil];
    //监控缓冲加载情况属性
    [item addObserver:self
           forKeyPath:@"loadedTimeRanges"
              options:NSKeyValueObservingOptionNew
              context:nil];
}
/* 移除KVO */
- (void)removeObserverFromPlayerItem:(AVPlayerItem *)item {
    [item removeObserver:self forKeyPath:@"status"];
    [item removeObserver:self forKeyPath:@"loadedTimeRanges"];
}
/* 属性发生变化，KVO响应函数 */
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context
{
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"]) {//状态发生改变
        AVPlayerStatus status = [[change objectForKey:@"new"] integerValue];
        if (status == AVPlayerStatusReadyToPlay) {
            NSLog(@"正在播放..，视频总长度为:%.2f",CMTimeGetSeconds(playerItem.duration));
        }
    } else if ( [keyPath isEqualToString:@"loadedTimeRanges"] ) {//缓冲区域变化
        NSArray *array = playerItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//已缓冲范围
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度
        NSLog(@"共缓冲：%.2f",totalBuffer);
    }
}

#pragma mark - 进度监听
- (void)addProgressObserver {
    AVPlayerItem *item = self.player.currentItem;
    UIProgressView *progress = self.progressView;
    //进度监听
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0)
                                              queue:dispatch_get_main_queue()
                                         usingBlock:^(CMTime time)
     {
         //CMTime是表示视频时间信息的结构体，包含视频时间点、每秒帧数等信息
         //获取当前播放到的秒数
         float current = CMTimeGetSeconds(time);
         //获取视频总播放秒数
         float total = CMTimeGetSeconds(item.duration);
         if (current) {
             [progress setProgress:(current/total) animated:YES];
         }
     }];
}

@end
