//
//  ViewController.m
//  PickerTest
//
//  Created by 刘奥明 on 16/4/12.
//  Copyright © 2016年 liuting. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface ViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) UIImagePickerController *ipc;/* 相册选择器 */
@property (strong, nonatomic) AVPlayerViewController *playerVC;/* 视频播放器 */
@property (weak, nonatomic) IBOutlet UIImageView *showImageView;/* 显示图片 */

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置显示图片可交互
    self.showImageView.userInteractionEnabled = YES;
    //创建AVPlayerViewController控制器
    AVPlayerViewController *playerVC = [[AVPlayerViewController alloc] init];
    playerVC.view.frame = self.showImageView.bounds;
    [self.showImageView addSubview:playerVC.view];
    self.playerVC = playerVC;
    self.playerVC.view.hidden = YES;
}
#pragma mark - UI点击
/* 点击打开本地相册 */
- (IBAction)pickImage:(id)sender
{
    //如果正在播放视频，停止播放
    if (self.playerVC.player) {
        [self.playerVC.player pause];
    }
    //创建图片选择控制器
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    //判断设备是否有图册
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        //设置拾取源类型
        ipc.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
        //设置媒体类型，这里设置图册支持的所有媒体类型，图片和视频
        ipc.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:ipc.sourceType];
    }
    ipc.delegate = self;//设置代理
    ipc.allowsEditing = YES;//设置可编辑
    self.ipc = ipc;
    //弹出图片选择控制器
    [self presentViewController:ipc animated:YES completion:nil];
}
#pragma mark - UIImagePickerControllerDelegate代理方法
/* 选择了一个图片或者视频后调用 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //获取选择文件的媒体类型
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    NSURL *videoURL = nil;
    if ([mediaType isEqualToString:@"public.image"]){//选择了图片
        //获取选择的图片
        UIImage *selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        //显示图片
        self.showImageView.image = selectedImage;
        self.showImageView.contentMode = UIViewContentModeScaleAspectFill;
        NSLog(@"found an image %@",selectedImage);
        //删除视频
        self.playerVC.player = nil;
        self.playerVC.view.hidden = YES;
       
    } else if ([mediaType isEqualToString:@"public.movie"]){//选择了视频
        //获取临时保存视频的URL
        videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        NSLog(@"found a video %@",videoURL);
        //直接创建AVPlayer，它内部也是先创建AVPlayerItem，这个只是快捷方法
        AVPlayer *player = [AVPlayer playerWithURL:videoURL];
        self.playerVC.player = player;
        self.playerVC.view.hidden = NO;
    }
    [self dismissViewControllerAnimated:YES completion:^{
        if (videoURL) {
            //调用控制器的属性player的开始播放方法
            [self.playerVC.player play];
        }
    }];
}
/* 取消选择后调用 */
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{
        //取消选择后继续播放视频
        if (self.playerVC.player) {
            [self.playerVC.player play];
        }
    }];
    NSLog(@"取消选择");
}

@end
