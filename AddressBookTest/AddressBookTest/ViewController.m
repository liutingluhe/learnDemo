//
//  ViewController.m
//  AddressBookTest
//
//  Created by 刘奥明 on 16/4/10.
//  Copyright © 2016年 liuting. All rights reserved.
//

#import "ViewController.h"
#import <AddressBook/AddressBook.h>

@interface ViewController () <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, assign) ABAddressBookRef addressBook;//通讯录
@property (nonatomic, strong) NSMutableArray *allPerson;//所有记录
@property (weak, nonatomic) IBOutlet UITableView *tableView;//表格
@property (nonatomic, assign) ABRecordID lastID;//存储最后一个记录的ID

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    //请求访问通讯录并获取通讯录所有记录
    [self requestAddressBook];
}

//由于在整个视图控制器周期内addressBook都驻留在内存中，所以当控制器视图销毁时销毁该对象
- (void)dealloc{
    if (self.addressBook != NULL) {
        CFRelease(self.addressBook);
    }
}

#pragma mark - TableView代理和数据源
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    if (!self.allPerson) {
        return 0;
    }
    return self.allPerson.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *key = @"cellIdentify";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:key];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:key];
    }
    
    //取得一条人员记录
    ABRecordRef recordRef = (__bridge ABRecordRef)self.allPerson[indexPath.row];
    //取得记录中得信息，注意这里进行了强转，不用自己释放资源
    NSString *firstName = (__bridge NSString *)ABRecordCopyValue(recordRef, kABPersonFirstNameProperty);
    NSString *lastName = (__bridge NSString *)ABRecordCopyValue(recordRef, kABPersonLastNameProperty);
    //获取手机号，注意手机号是ABMultiValueRef类，有可能有多条
    ABMultiValueRef phoneNumbersRef = ABRecordCopyValue(recordRef, kABPersonPhoneProperty);
    long count = ABMultiValueGetCount(phoneNumbersRef);
    for(int i = 0;i < count;++i){
        NSString *phoneLabel = (__bridge NSString *)(ABMultiValueCopyLabelAtIndex(phoneNumbersRef, i));
        NSString *phoneNumber = (__bridge NSString *)(ABMultiValueCopyValueAtIndex(phoneNumbersRef, i));
        NSLog(@"%@:%@",phoneLabel,phoneNumber);
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",firstName,lastName];
    if (count > 0) {
        cell.detailTextLabel.text = (__bridge NSString *)(ABMultiValueCopyValueAtIndex(phoneNumbersRef, 0));
    }
    //使用cell的tag存储记录ID
    cell.tag = ABRecordGetRecordID(recordRef);
    //记录最后一个记录的ID
    if (indexPath.row == self.allPerson.count - 1) {
        self.lastID = ABRecordGetRecordID(recordRef);
    }
    return cell;
}

#pragma mark - UI点击
- (IBAction)addPerson:(id)sender {
    //添加联系人
    [self addPersonWithFirstName:@"liu"
                        lastName:@"ting"
                      workNumber:@"13412321332"];
    //获取所有通讯录记录
    [self initAllPerson];
    //刷新表格
    [self.tableView reloadData];
}
- (IBAction)removePerson:(id)sender {
    //删除联系人
    [self removePersonWithName:@"liu ting"];
    //获取所有通讯录记录
    [self initAllPerson];
    //刷新表格
    [self.tableView reloadData];
}
- (IBAction)changePerson:(id)sender {
    [self modifyPersonWithRecordID:self.lastID
                         firstName:@"XXXX"
                          lastName:@"YYY"
                        workNumber:@"1111111111"];
    //获取所有通讯录记录
    [self initAllPerson];
    //刷新表格
    [self.tableView reloadData];
}

#pragma mark - 私有方法
/* 请求访问通讯录并获取通讯录所有记录 */
- (void)requestAddressBook{
    //创建通讯录对象
    self.addressBook = ABAddressBookCreate();
    
    //请求访问用户通讯录,注意无论成功与否block都会调用
    ABAddressBookRequestAccessWithCompletion(self.addressBook, ^(bool granted, CFErrorRef error) {
        if (!granted) {
            NSLog(@"未获得通讯录访问权限！");
        }
        //获取所有通讯录记录
        [self initAllPerson];
        //刷新表格
        [self.tableView reloadData];
    });
}

/* 取得所有通讯录记录 */
- (void)initAllPerson{
    //取得通讯录访问授权
    ABAuthorizationStatus authorization = ABAddressBookGetAuthorizationStatus();
    //如果未获得授权
    if (authorization != kABAuthorizationStatusAuthorized) {
        NSLog(@"尚未获得通讯录访问授权！");
        return ;
    }
    //取得通讯录中所有人员记录
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(self.addressBook);
    self.allPerson = (__bridge NSMutableArray *)allPeople;
    //释放资源
    CFRelease(allPeople);
}

/* 删除指定的记录 */
- (void)removePersonWithRecord:(ABRecordRef)recordRef{
    ABAddressBookRemoveRecord(self.addressBook, recordRef, NULL);//删除
    ABAddressBookSave(self.addressBook, NULL);//删除之后提交更改
}
/* 根据姓名删除记录 */
- (void)removePersonWithName:(NSString *)personName{
    CFStringRef personNameRef = (__bridge CFStringRef)(personName);
    //根据人员姓名查找
    CFArrayRef recordsRef = ABAddressBookCopyPeopleWithName(self.addressBook, personNameRef);
    CFIndex count = CFArrayGetCount(recordsRef);//取得记录数
    for (CFIndex i=0; i<count; ++i) {
        ABRecordRef recordRef = CFArrayGetValueAtIndex(recordsRef, i);//取得指定的记录
        ABAddressBookRemoveRecord(self.addressBook, recordRef, NULL);//删除
    }
    //删除之后提交更改
    ABAddressBookSave(self.addressBook, NULL);
    CFRelease(recordsRef);
}

/**
 *  添加一条记录
 *
 *  @param firstName  名
 *  @param lastName   姓
 *  @param iPhoneName iPhone手机号
 */
- (void)addPersonWithFirstName:(NSString *)firstName
                      lastName:(NSString *)lastName
                    workNumber:(NSString *)workNumber
{
    //创建一条记录
    ABRecordRef recordRef = ABPersonCreate();
    //添加名
    ABRecordSetValue(recordRef, kABPersonFirstNameProperty, (__bridge CFTypeRef)(firstName), NULL);
    //添加姓
    ABRecordSetValue(recordRef, kABPersonLastNameProperty, (__bridge CFTypeRef)(lastName), NULL);
    //创建一个多值属性，因为手机号可以有多个
    ABMutableMultiValueRef multiValueRef = ABMultiValueCreateMutable(kABStringPropertyType);
    //向多值属性中添加工作电话
    ABMultiValueAddValueAndLabel(multiValueRef, (__bridge CFStringRef)(workNumber), kABWorkLabel, NULL);
    //添加属性到指定记录，这里添加的是多值属性
    ABRecordSetValue(recordRef, kABPersonPhoneProperty, multiValueRef, NULL);
    //添加记录到通讯录
    ABAddressBookAddRecord(self.addressBook, recordRef, NULL);
    //保存通讯录，提交更改
    ABAddressBookSave(self.addressBook, NULL);
    //释放资源
    CFRelease(recordRef);
    CFRelease(multiValueRef);
}

/**
 *  根据记录ID修改联系人信息
 *
 *  @param recordID   记录唯一ID
 *  @param firstName  姓
 *  @param lastName   名
 *  @param homeNumber 工作电话
 */
- (void)modifyPersonWithRecordID:(ABRecordID)recordID
                       firstName:(NSString *)firstName
                        lastName:(NSString *)lastName
                      workNumber:(NSString *)workNumber
{
    //根据记录ID获取一条记录
    ABRecordRef recordRef = ABAddressBookGetPersonWithRecordID(self.addressBook, recordID);
    //添加名
    ABRecordSetValue(recordRef, kABPersonFirstNameProperty, (__bridge CFTypeRef)(firstName), NULL);
    //添加姓
    ABRecordSetValue(recordRef, kABPersonLastNameProperty, (__bridge CFTypeRef)(lastName), NULL);
    //创建一个多值属性，因为手机号可以有多个
    ABMutableMultiValueRef multiValueRef = ABMultiValueCreateMutable(kABStringPropertyType);
    //向多值属性中添加工作电话
    ABMultiValueAddValueAndLabel(multiValueRef, (__bridge CFStringRef)(workNumber), kABWorkLabel, NULL);
    //添加属性到指定记录，这里添加的是多值属性
    ABRecordSetValue(recordRef, kABPersonPhoneProperty, multiValueRef, NULL);
    //保存记录，提交更改
    ABAddressBookSave(self.addressBook, NULL);
    //释放资源
    CFRelease(multiValueRef);
}

@end
