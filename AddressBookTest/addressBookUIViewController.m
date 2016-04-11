//
//  addressBookUIViewController.m
//  AddressBookTest
//
//  Created by 刘奥明 on 16/4/10.
//  Copyright © 2016年 liuting. All rights reserved.
//

#import "addressBookUIViewController.h"
#import <AddressBookUI/AddressBookUI.h>

@interface addressBookUIViewController ()  <ABNewPersonViewControllerDelegate,
                                            ABUnknownPersonViewControllerDelegate,
                                            ABPeoplePickerNavigationControllerDelegate,
                                            ABPersonViewControllerDelegate>

@end

@implementation addressBookUIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - UI事件
//点击添加联系人
- (IBAction)addPersonClick:(UIButton *)sender {
    //创建添加联系人视图控制器
    ABNewPersonViewController *newPersonController = [[ABNewPersonViewController alloc] init];
    //设置代理
    newPersonController.newPersonViewDelegate = self;
    //注意必须有一层导航控制器才能使用，否则不会出现取消和完成按钮，无法进行保存等操作
    [self.navigationController pushViewController:newPersonController animated:YES];
}
//点击未知联系人
- (IBAction)unknownPersonClick:(UIButton *)sender {
    //创建未知联系人视图控制器
    ABUnknownPersonViewController *unknownPersonController = [[ABUnknownPersonViewController alloc] init];
    //设置未知人员
    ABRecordRef recordRef=ABPersonCreate();
    ABRecordSetValue(recordRef, kABPersonFirstNameProperty, @"Kenshin", NULL);
    ABRecordSetValue(recordRef, kABPersonLastNameProperty, @"Cui", NULL);
    ABMultiValueRef multiValueRef = ABMultiValueCreateMutable(kABStringPropertyType);
    ABMultiValueAddValueAndLabel(multiValueRef, @"18500138888", kABHomeLabel, NULL);
    ABRecordSetValue(recordRef, kABPersonPhoneProperty, multiValueRef, NULL);
    unknownPersonController.displayedPerson = recordRef;
    //设置代理
    unknownPersonController.unknownPersonViewDelegate = self;
    //设置其他属性
    unknownPersonController.allowsActions = YES;//显示标准操作按钮
    unknownPersonController.allowsAddingToAddressBook = YES;//是否允许将联系人添加到地址簿
    //释放资源
    CFRelease(multiValueRef);
    CFRelease(recordRef);
    
    [self.navigationController pushViewController:unknownPersonController animated:YES];
}
//点击显示联系人
- (IBAction)showPersonClick:(UIButton *)sender {
    //创建显示联系人视图控制器
    ABPersonViewController *personController = [[ABPersonViewController alloc] init];
    //设置联系人，取得id为1的联系人记录
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    ABRecordRef recordRef = ABAddressBookGetPersonWithRecordID(addressBook, 1);
    personController.displayedPerson = recordRef;
    //设置代理
    personController.personViewDelegate = self;
    //设置其他属性
    personController.allowsActions = YES;//是否显示发送信息、共享联系人等按钮
    personController.allowsEditing = YES;//允许编辑
    
    [self.navigationController pushViewController:personController animated:YES];
}
//点击选择联系人
- (IBAction)selectPersonClick:(UIButton *)sender {
    //创建选择联系人导航视图控制器
    ABPeoplePickerNavigationController *peoplePickerController =
                [[ABPeoplePickerNavigationController alloc] init];
    //设置代理
    peoplePickerController.peoplePickerDelegate = self;
    //以模态弹出
    [self presentViewController:peoplePickerController animated:YES completion:nil];
}

#pragma mark - ABNewPersonViewController代理方法
/* 
    完成新增（点击取消和完成按钮时调用）,注意这里不用做实际的通讯录增加工作，
    此代理方法调用时已经完成新增，当保存成功的时候参数中得person会返回保存的记录，如果点击取消person为NULL
 */
- (void)newPersonViewController:(ABNewPersonViewController *)newPersonView
       didCompleteWithNewPerson:(ABRecordRef)person
{
    //如果有联系人信息
    if (person) {
        NSLog(@"%@ 信息保存成功.",(__bridge NSString *)(ABRecordCopyCompositeName(person)));
    }else{
        NSLog(@"点击了取消.");
    }
    //返回主视图窗口
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}
#pragma mark - ABUnknownPersonViewController代理方法
//保存未知联系人时触发
- (void)unknownPersonViewController:(ABUnknownPersonViewController *)unknownCardViewController
                 didResolveToPerson:(ABRecordRef)person
{
    if (person) {
        NSLog(@"%@ 信息保存成功！",(__bridge NSString *)(ABRecordCopyCompositeName(person)));
    }
    //返回主视图窗口
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - ABPersonViewController代理方法
//选择一个人员属性后触发，返回值YES表示触发默认行为操作，否则执行代理中自定义的操作
- (BOOL)personViewController:(ABPersonViewController *)personViewController
        shouldPerformDefaultActionForPerson:(ABRecordRef)person
                    property:(ABPropertyID)property
                  identifier:(ABMultiValueIdentifier)identifier
{
    if (person) {
        NSLog(@"选择了属性：%d，值：%@.",property,(__bridge NSString *)ABRecordCopyValue(person, property));
    }
    return NO;
}
#pragma mark - ABPeoplePickerNavigationController代理方法
//选择一个联系人后调用，注意这个代理方法实现后选择属性的方法将不会再调用
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
                         didSelectPerson:(ABRecordRef)person
{
    if (person) {
        NSLog(@"选择了%@.",(__bridge NSString *)(ABRecordCopyCompositeName(person)));
    }
}
//点击取消按钮后调用
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker{
    NSLog(@"取消选择.");
}

@end
