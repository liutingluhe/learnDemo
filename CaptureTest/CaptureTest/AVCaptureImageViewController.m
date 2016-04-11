//
//  AVCaptureImageViewController.m
//  CaptureTest
//
//  Created by 刘奥明 on 16/4/10.
//  Copyright © 2016年 liuting. All rights reserved.
//

#import "AVCaptureImageViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface AVCaptureImageViewController ()
@property (strong, nonatomic) AVCaptureSession *session;//媒体管理会话
@property (strong, nonatomic) AVCaptureDeviceInput *captureInput;//输入数据对象
@property (strong, nonatomic) AVCaptureStillImageOutput *imageOutput;//输出数据对象
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *captureLayer;//视频预览图层
@property (strong, nonatomic) IBOutlet UIButton *captureBtn;//拍照按钮
@property (strong, nonatomic) IBOutlet UIButton *openCaptureBtn;//打开摄像头按钮

@end

@implementation AVCaptureImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initCapture];
    self.openCaptureBtn.hidden = NO;
    self.captureBtn.hidden = YES;
}
/* 初始化摄像头 */
- (void)initCapture{
    //1. 创建媒体管理会话
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    self.session = session;
    //判断分辨率是否支持1280*720，支持就设置为1280*720
    if( [session canSetSessionPreset:AVCaptureSessionPreset1280x720] ) {
        session.sessionPreset = AVCaptureSessionPreset1280x720;
    }
    //2. 获取后置摄像头设备对象
    AVCaptureDevice *device = nil;
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if (camera.position == AVCaptureDevicePositionBack) {//取得后置摄像头
            device = camera;
        }
    }
    if(!device) {
        NSLog(@"取得后置摄像头错误");
        return;
    }
    //3. 创建输入数据对象
    NSError *error = nil;
    AVCaptureDeviceInput *captureInput = [[AVCaptureDeviceInput alloc] initWithDevice:device
                                                                                error:&error];
    if (error) {
        NSLog(@"创建输入数据对象错误");
        return;
    }
    self.captureInput = captureInput;
    //4. 创建输出数据对象
    AVCaptureStillImageOutput *imageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *setting = @{ AVVideoCodecKey:AVVideoCodecJPEG };
    [imageOutput setOutputSettings:setting];
    self.imageOutput = imageOutput;
    //5. 添加输入数据对象和输出对象到会话中
    if ([session canAddInput:captureInput]) {
        [session addInput:captureInput];
    }
    if ([session canAddOutput:imageOutput]) {
        [session addOutput:imageOutput];
    }
    //6. 创建视频预览图层
    AVCaptureVideoPreviewLayer *videoLayer =
    [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    self.view.layer.masksToBounds = YES;
    videoLayer.frame = self.view.bounds;
    videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    //插入图层在拍照按钮的下方
    [self.view.layer insertSublayer:videoLayer below:self.captureBtn.layer];
    self.captureLayer = videoLayer;
}
#pragma mark - UI点击
/* 点击拍照按钮 */
- (IBAction)takeCapture:(id)sender {
    //根据设备输出获得连接
    AVCaptureConnection *connection = [self.imageOutput connectionWithMediaType:AVMediaTypeVideo];
    //通过连接获得设备输出的数据
    [self.imageOutput captureStillImageAsynchronouslyFromConnection:connection
                                                  completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error)
     {
         //获取输出的JPG图片数据
         NSData *imageData =
         [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
         UIImage *image = [UIImage imageWithData:imageData];
         UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);//保存到相册
         self.captureLayer.hidden = YES;
         self.captureBtn.hidden = YES;
         self.openCaptureBtn.hidden = NO;
         [self.session stopRunning];//停止捕捉
     }];
}
/* 点击打开摄像头按钮 */
- (IBAction)openCapture:(id)sender {
    self.captureLayer.hidden = NO;
    self.captureBtn.hidden = NO;
    self.openCaptureBtn.hidden = YES;
    [self.session startRunning];//开始捕捉
}
@end
