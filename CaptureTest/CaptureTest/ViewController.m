//
//  ViewController.m
//  CaptureTest
//
//  Created by 刘奥明 on 16/4/10.
//  Copyright © 2016年 liuting. All rights reserved.
//
#import "ViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface ViewController () <UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (strong, nonatomic) UIImagePickerController *pickerController;//拾取控制器
@property (strong, nonatomic) IBOutlet UIImageView *showImageView;//显示图片
@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化拾取控制器
    [self initPickerController];
}
/* 初始化拾取控制器 */
- (void)initPickerController{
    //创建拾取控制器
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    //设置拾取源为摄像头
    pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    //设置摄像头为后置
    pickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    pickerController.editing = YES;//设置运行编辑，即可以点击一些拾取控制器的控件
    pickerController.delegate = self;//设置代理
    self.pickerController = pickerController;
}
#pragma mark - UI点击
/* 点击拍照 */
- (IBAction)imagePicker:(id)sender {
    //设定拍照的媒体类型
    self.pickerController.mediaTypes = @[(NSString *)kUTTypeImage];
    //设置摄像头捕捉模式为捕捉图片
    self.pickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    //模式弹出拾取控制器
    [self presentViewController:self.pickerController animated:YES completion:nil];
}
/* 点击录像 */
- (IBAction)videoPicker:(id)sender {
    //设定录像的媒体类型
    self.pickerController.mediaTypes = @[(NSString *)kUTTypeMovie];
    //设置摄像头捕捉模式为捕捉视频
    self.pickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
    //设置视频质量为高清
    self.pickerController.videoQuality = UIImagePickerControllerQualityTypeHigh;
    //模式弹出拾取控制器
    [self presentViewController:self.pickerController animated:YES completion:nil];
}

#pragma mark - 代理方法
/* 拍照或录像成功，都会调用 */
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    //从info取出此时摄像头的媒体类型
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {//如果是拍照
        //获取拍照的图像
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        //保存图像到相簿
        UIImageWriteToSavedPhotosAlbum(image, self,
                                       @selector(image:didFinishSavingWithError:contextInfo:), nil);
        
    } else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {//如果是录像
        //获取录像文件路径URL
        NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
        NSString *path = url.path;
        //判断能不能保存到相簿
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path)) {
            //保存视频到相簿
            UISaveVideoAtPathToSavedPhotosAlbum(path, self,
                                                @selector(video:didFinishSavingWithError:contextInfo:), nil);
        }
        
    }
    //拾取控制器弹回
    [self dismissViewControllerAnimated:YES completion:nil];
}
/* 取消拍照或录像会调用 */
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"取消");
    //拾取控制器弹回
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 保存图片或视频完成的回调
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error
  contextInfo:(void *)contextInfo {
    NSLog(@"保存图片完成");
    self.showImageView.image = image;
    self.showImageView.contentMode = UIViewContentModeScaleToFill;
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error
  contextInfo:(void *)contextInfo {
    NSLog(@"保存视频完成");
}
@end
