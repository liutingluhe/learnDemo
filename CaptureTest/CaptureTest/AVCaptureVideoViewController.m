//
//  AVCaptureVideoViewController.m
//  CaptureTest
//
//  Created by 刘奥明 on 16/4/10.
//  Copyright © 2016年 liuting. All rights reserved.
//

#import "AVCaptureVideoViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface AVCaptureVideoViewController () <AVCaptureFileOutputRecordingDelegate>
@property (strong, nonatomic) AVCaptureSession *session;//媒体管理会话
@property (strong, nonatomic) AVCaptureDeviceInput *captureInput;//输入数据对象
@property (strong, nonatomic) AVCaptureMovieFileOutput *movieOutput;//输出数据对象
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *captureLayer;//视频预览图层
@property (strong, nonatomic) IBOutlet UIButton *captureBtn;//录像按钮
@property (strong, nonatomic) IBOutlet UIButton *openCaptureBtn;//打开摄像头按钮

@end

@implementation AVCaptureVideoViewController

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
    //2. 获取麦克风设备对象
    AVCaptureDevice *audioDevice = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio].firstObject;
    if(!audioDevice) {
        NSLog(@"取得麦克风错误");
        return;
    }
    //3. 创建摄像头输入数据对象
    NSError *error = nil;
    AVCaptureDeviceInput *captureInput = [[AVCaptureDeviceInput alloc] initWithDevice:device
                                                                                error:&error];
    if (error) {
        NSLog(@"创建输入数据对象错误");
        return;
    }
    self.captureInput = captureInput;
    
    //3. 创建麦克风输入数据对象
    AVCaptureDeviceInput *audioInput = [[AVCaptureDeviceInput alloc] initWithDevice:audioDevice
                                                                              error:&error];
    if (error) {
        NSLog(@"创建输入数据对象错误");
        return;
    }
    //4. 创建视频文件输出对象
    AVCaptureMovieFileOutput *movieOutput = [[AVCaptureMovieFileOutput alloc] init];
    self.movieOutput = movieOutput;
    
    //5. 添加输入数据对象和输出对象到会话中
    if([session canAddInput:captureInput]) {
        [session addInput:captureInput];
        [session addInput:audioInput];
        //添加防抖动功能
        AVCaptureConnection *connection = [movieOutput connectionWithMediaType:AVMediaTypeVideo];
        if ([connection isVideoStabilizationSupported]) {
            connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
        }
    }
    if ([session canAddOutput:movieOutput]) {
        [session addOutput:movieOutput];
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
/* 点击录像按钮 */
- (IBAction)takeCapture:(id)sender {
    if (!self.movieOutput.isRecording) {
        NSString *outputPath = [NSTemporaryDirectory() stringByAppendingString:@"myMovie.mov"];
        NSURL *url = [NSURL fileURLWithPath:outputPath];//记住是文件URL，不是普通URL
        //开始录制并设置代理监控录制过程，录制文件会存放到指定URL路径下
        [self.movieOutput startRecordingToOutputFileURL:url recordingDelegate:self];
    } else {
        [self.movieOutput stopRecording];//结束录制
    }
}
/* 点击打开摄像头按钮 */
- (IBAction)openCapture:(id)sender {
    self.captureLayer.hidden = NO;
    self.captureBtn.hidden = NO;
    self.openCaptureBtn.hidden = YES;
    [self.session startRunning];//开始捕捉
}

#pragma mark - AVCaptureFileOutputRecordingDelegate代理
/* 开始录制会调用 */
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput
didStartRecordingToOutputFileAtURL:(NSURL *)fileURL
      fromConnections:(NSArray *)connections
{
    NSLog(@"开始录制");
}
/* 录制完成会调用 */
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput
didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
      fromConnections:(NSArray *)connections
                error:(NSError *)error
{
    NSLog(@"完成录制");
    NSString *path = outputFileURL.path;
    //保存录制视频到相簿
    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path)) {
        UISaveVideoAtPathToSavedPhotosAlbum(path, nil, nil, nil);
    }
}


@end

