//
//  MessageComposeViewController.m
//  MessageUITest
//
//  Created by 刘奥明 on 16/4/28.
//  Copyright © 2016年 liuting. All rights reserved.
//


#import "MessageComposeViewController.h"
#import <MessageUI/MessageUI.h>

@interface MessageComposeViewController ()<MFMessageComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *receivers;//收信人文本框
@property (weak, nonatomic) IBOutlet UITextField *body;//信息正文文本框
@property (weak, nonatomic) IBOutlet UITextField *subject;//主题文本框
@property (weak, nonatomic) IBOutlet UITextField *attachments;//附件文本框

@end

@implementation MessageComposeViewController
#pragma mark - 控制器视图方法
- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - UI事件
- (IBAction)sendMessageClick:(UIButton *)sender {
    
    //如果不能发送文本信息，就直接返回
    if(![MFMessageComposeViewController canSendText]){
        return;
    }
    //创建短信发送视图控制器
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    //设置收件人
    messageController.recipients = [self.receivers.text componentsSeparatedByString:@","];
    //设置信息正文
    messageController.body = self.body.text;
    //设置代理,注意这里不是delegate而是messageComposeDelegate
    messageController.messageComposeDelegate = self;
    //判断是否支持主题
    if([MFMessageComposeViewController canSendSubject]){
        //设置主题
        messageController.subject = self.subject.text;
    }
    //判断是否支持附件
    if ([MFMessageComposeViewController canSendAttachments]) {
        //添加附件，请务必指定附件文件的后缀，否则在发送后无法正确识别文件类别
        NSArray *attachments = [self.attachments.text componentsSeparatedByString:@","];
        if (attachments.count > 0) {
            for(NSString *attachment in attachments){
                NSString *path = [[NSBundle mainBundle] pathForResource:attachment
                                                                 ofType:nil];
                NSURL *url = [NSURL fileURLWithPath:path];
                //添加附件具体方法，需要设置附件URL和附件的标识
                [messageController addAttachmentURL:url
                              withAlternateFilename:attachment];
            };
        }
    }
    //以模态弹出界面
    [self presentViewController:messageController animated:YES completion:nil];
}
#pragma mark - MFMessageComposeViewController代理方法
/* 发送完成，不管成功与否 */
-(void)messageComposeViewController:(MFMessageComposeViewController *)controller
                didFinishWithResult:(MessageComposeResult)result
{
    switch (result) {
        case MessageComposeResultSent:
            NSLog(@"发送成功.");
            break;
        case MessageComposeResultCancelled:
            NSLog(@"取消发送.");
            break;
        default:
            NSLog(@"发送失败.");
            break;
    }
    //弹回界面
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
