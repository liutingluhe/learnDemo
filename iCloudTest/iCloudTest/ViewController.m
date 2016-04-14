//
//  ViewController.m
//  iCloudTest
//
//  Created by 刘奥明 on 16/4/13.
//  Copyright © 2016年 liuting. All rights reserved.
//

#import "ViewController.h"
#import "LTDocument.h"

#define kContainerIdentifier @"iCloud.com.liuting.icloud.iCloudTest"

@interface ViewController () <UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *documentField;/* 输入框 */
@property (weak, nonatomic) IBOutlet UILabel *documentShowLable;/* 显示栏 */
@property (weak, nonatomic) IBOutlet UITableView *documentTableView;/* 文档列表 */

@property (strong, nonatomic) NSMutableDictionary *files;/* 文档文件信息，键为文件名，值为创建日期 */
@property (strong, nonatomic) NSMetadataQuery *query;/* 查询文档对象 */
@property (strong, nonatomic) LTDocument *document;/* 当前选中文档 */

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.documentTableView.delegate = self;
    self.documentTableView.dataSource = self;
    /* 从iCloud上加载所有文档信息 */
    [self loadDocuments];
}

#pragma mark - UI点击事件
/* 点击添加文档 */
- (IBAction)addDocument:(id)sender {
    //提示信息
    if (self.documentField.text.length <= 0) {
        NSLog(@"请输入要创建的文档名");
        self.documentField.placeholder = @"请输入要创建的文档名";
        return;
    }
    //创建文档URL
    NSString *text = self.documentField.text;
    NSString *fileName = [NSString stringWithFormat:@"%@.txt",text];
    NSURL *url = [self getUbiquityFileURL:fileName];
    
    //创建云端文档对象
    LTDocument *document = [[LTDocument alloc] initWithFileURL:url];
    //设置文档内容
    NSString *dataString = @"hallo World";
    document.data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    //保存或创建文档，UIDocumentSaveForCreating是创建文档
    [document saveToURL:url
       forSaveOperation:UIDocumentSaveForCreating
      completionHandler:^(BOOL success)
    {
        if (success) {
            NSLog(@"创建文档成功.");
            self.documentField.text = @"";
            //从iCloud上加载所有文档信息
            [self loadDocuments];
        }else{
            NSLog(@"创建文档失败.");
        }
        
    }];
}
/* 点击修改文档 */
- (IBAction)saveDocument:(UIButton *)sender {
    if ([sender.titleLabel.text isEqualToString:@"修改文档"]) {
        self.documentField.text = self.documentShowLable.text;
        [sender setTitle:@"保存文档" forState:UIControlStateNormal];
    } else if([sender.titleLabel.text isEqualToString:@"保存文档"]) {
        [sender setTitle:@"修改文档" forState:UIControlStateNormal];
        self.documentField.placeholder = @"请输入修改的文档内容";
        //要保存的文档内容
        NSString *dataText = self.documentField.text;
        NSData *data = [dataText dataUsingEncoding:NSUTF8StringEncoding];
        self.document.data = data;
        //保存或创建文档，UIDocumentSaveForOverwriting是覆盖保存文档
        [self.document saveToURL:self.document.fileURL
                forSaveOperation:UIDocumentSaveForOverwriting
               completionHandler:^(BOOL success)
        {
            NSLog(@"保存成功！");
            self.documentShowLable.text = self.documentField.text;
            self.documentField.text = @"";
        }];
    }
}
/* 点击删除文档 */
- (IBAction)removeDocument:(id)sender {
    //提示信息
    if (self.documentField.text.length <= 0) {
        self.documentField.placeholder = @"请输入要删除的文档名";
        return;
    }
    //判断要删除的文档是否存在
    NSString *text = self.documentField.text;
    NSString *fileName = [NSString stringWithFormat:@"%@.txt",text];
    NSArray *fileNames = [self.files allKeys];
    if (![fileNames containsObject:fileName]) {
        NSLog(@"没有要删除的文档");
        return;
    }
    //创建要删除的文档URL
    NSURL *url = [self getUbiquityFileURL:fileName];
    NSError *error = nil;
    //删除文档文件
    [[NSFileManager defaultManager] removeItemAtURL:url error:&error];
    if (error) {
        NSLog(@"删除文档过程中发生错误，错误信息：%@",error.localizedDescription);
        return;
    }
    //从集合中删除
    [self.files removeObjectForKey:fileName];
    self.documentField.text = @"";
}
#pragma mark - 私有方法
/**
 *  取得云端存储文件的地址
 *  @param fileName 文件名，如果文件名为nil，则重新创建一个URL
 *  @return 文件地址
 */
- (NSURL *)getUbiquityFileURL:(NSString *)fileName{
    //取得云端URL基地址(参数中传入nil则会默认获取第一个容器)，需要一个容器标示
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *url = [manager URLForUbiquityContainerIdentifier:kContainerIdentifier];
    //取得Documents目录
    url = [url URLByAppendingPathComponent:@"Documents"];
    //取得最终地址
    url = [url URLByAppendingPathComponent:fileName];
    return url;
}
/* 从iCloud上加载所有文档信息 */
- (void)loadDocuments
{
    if (!self.query) {
        self.query = [[NSMetadataQuery alloc] init];
        self.query.searchScopes = @[NSMetadataQueryUbiquitousDocumentsScope];
        //注意查询状态是通过通知的形式告诉监听对象的
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(metadataQueryFinish:)
                                                     name:NSMetadataQueryDidFinishGatheringNotification
                                                   object:self.query];//数据获取完成通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(metadataQueryFinish:)
                                                     name:NSMetadataQueryDidUpdateNotification
                                                   object:self.query];//查询更新通知
    }
    //开始查询
    [self.query startQuery];
}
/* 查询更新或者数据获取完成的通知调用 */
- (void)metadataQueryFinish:(NSNotification *)notification
{
    NSLog(@"数据获取成功！");
    NSArray *items = self.query.results;//查询结果集
    self.files = [NSMutableDictionary dictionary];
    //变量结果集，存储文件名称、创建日期
    [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSMetadataItem *item = obj;
        NSString *fileName = [item valueForAttribute:NSMetadataItemFSNameKey];
        NSDate *date = [item valueForAttribute:NSMetadataItemFSContentChangeDateKey];
        NSDateFormatter *dateformate = [[NSDateFormatter alloc]init];
        dateformate.dateFormat = @"YY-MM-dd HH:mm";
        NSString *dateString = [dateformate stringFromDate:date];
        [self.files setObject:dateString forKey:fileName];
    }];
    self.documentShowLable.text = @"";
    [self.documentTableView reloadData];
}

#pragma mark - UITableView数据源
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.files.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identtityKey = @"myTableViewCellIdentityKey1";
    UITableViewCell *cell = [self.documentTableView dequeueReusableCellWithIdentifier:identtityKey];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:identtityKey];
    }
    //显示文档名和文档创建日期
    NSArray *fileNames = self.files.allKeys;
    NSString *fileName = fileNames[indexPath.row];
    cell.textLabel.text = fileName;
    cell.detailTextLabel.text = [self.files valueForKey:fileName];
    return cell;
}

#pragma mark - UITableView代理方法
/* 点击文档列表的其中一个文档调用 */
- (void)tableView:(UITableView *)tableView
        didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.documentTableView cellForRowAtIndexPath:indexPath];
    //获取文档URL
    NSURL *url = [self getUbiquityFileURL:cell.textLabel.text];
    //创建文档操作对象
    LTDocument *document = [[LTDocument alloc] initWithFileURL:url];
    self.document = document;
    //打开文档并读取文档内容
    [document openWithCompletionHandler:^(BOOL success) {
        if(success){
            NSLog(@"读取数据成功.");
            NSString *dataText = [[NSString alloc] initWithData:document.data
                                                       encoding:NSUTF8StringEncoding];
            self.documentShowLable.text = dataText;
        }else{
            NSLog(@"读取数据失败.");
        }
    }];
}

@end
