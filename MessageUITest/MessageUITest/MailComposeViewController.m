//
//  MailComposeViewController.m
//  MessageUITest
//
//  Created by 刘奥明 on 16/4/28.
//  Copyright © 2016年 liuting. All rights reserved.
//

#import "MailComposeViewController.h"
#import <MessageUI/MessageUI.h>

@interface MailComposeViewController ()<MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *toTecipients;//收件人文本框
@property (weak, nonatomic) IBOutlet UITextField *ccRecipients;//抄送人文本框
@property (weak, nonatomic) IBOutlet UITextField *bccRecipients;//密送人文本框
@property (weak, nonatomic) IBOutlet UITextField *subject; //主题文本框
@property (weak, nonatomic) IBOutlet UITextField *body;//正文文本框
@property (weak, nonatomic) IBOutlet UITextField *attachments;//附件文本框
@end

@implementation MailComposeViewController
- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - UI事件
- (IBAction)sendEmailClick:(UIButton *)sender {
    //判断当前是否能够发送邮件
    if ([MFMailComposeViewController canSendMail]) {
        return;
    }
    //创建发送邮件视图控制器
    MFMailComposeViewController *mailController =
    [[MFMailComposeViewController alloc] init];
    //设置代理，注意这里不是delegate，而是mailComposeDelegate
    mailController.mailComposeDelegate = self;
    //设置收件人
    NSArray *recipients = [self.toTecipients.text componentsSeparatedByString:@","];
    [mailController setToRecipients:recipients];
    //设置抄送人
    if (self.ccRecipients.text.length > 0) {
        NSArray *ccRecipients = [self.ccRecipients.text componentsSeparatedByString:@","];
        [mailController setCcRecipients:ccRecipients];
    }
    //设置密送人
    if (self.bccRecipients.text.length > 0) {
        NSArray *bccRecipients = [self.bccRecipients.text componentsSeparatedByString:@","];
        [mailController setBccRecipients:bccRecipients];
    }
    //设置主题
    [mailController setSubject:self.subject.text];
    //设置主体内容
    [mailController setMessageBody:self.body.text isHTML:YES];
    //添加附件
    if (self.attachments.text.length > 0) {
        NSArray *attachments = [self.attachments.text componentsSeparatedByString:@","] ;
        for(NSString *attachment in attachments) {
            NSString *file = [[NSBundle mainBundle] pathForResource:attachment
                                                             ofType:nil];
            NSData *data = [NSData dataWithContentsOfFile:file];
            //第一个参数是附件数据，第二个参数是mimeType类型，jpg图片对应image/jpeg
            [mailController addAttachmentData:data
                                     mimeType:@"image/jpeg"
                                     fileName:attachment];
        };
    }
    //弹出视图
    [self presentViewController:mailController animated:YES completion:nil];
}

#pragma mark - MFMailComposeViewController代理方法
/* 发送完成会调用，不管成功与否 */
-(void)mailComposeController:(MFMailComposeViewController *)controller
         didFinishWithResult:(MFMailComposeResult)result
                       error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultSent:
            NSLog(@"发送成功.");
            break;
        case MFMailComposeResultSaved:
            //点取消会提示是否存储为草稿，存储后可以到系统邮件应用的对应草稿箱找到
            NSLog(@"邮件已保存.");
            break;
        case MFMailComposeResultCancelled:
            NSLog(@"取消发送.");
            break;
        default:
            NSLog(@"发送失败.");
            break;
    }
    if (error) {
        NSLog(@"发送邮件过程中发生错误，错误信息：%@",error.localizedDescription);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end