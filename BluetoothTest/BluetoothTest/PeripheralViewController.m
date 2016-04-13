//
//  PeripheralViewController.m
//  BluetoothTest
//
//  Created by 刘奥明 on 16/4/12.
//  Copyright © 2016年 liuting. All rights reserved.
//

#import "PeripheralViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

#define kPeripheralName         @"Liuting's Device" //外围设备名称，自定义
#define kServiceUUID            @"FFA0-FFB0" //服务的UUID，自定义
#define kCharacteristicUUID     @"FFCC-FFDD" //特征的UUID，自定义

@interface PeripheralViewController ()<CBPeripheralManagerDelegate>
@property (strong, nonatomic) CBPeripheralManager *peripheralManager;/* 外围设备管理器 */
@property (strong, nonatomic) NSMutableArray *centralM;/* 订阅的中央设备 */
@property (strong, nonatomic) CBMutableCharacteristic *characteristicM;/* 特征 */
@end
@implementation PeripheralViewController
- (void)viewDidLoad{
    [super viewDidLoad];
    self.centralM = [NSMutableArray array];
    //创建外围设备管理器
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self
                                                                     queue:nil];
}
#pragma mark - UI事件
/* 点击更新特征值 */
- (IBAction)changeCharacteristicValue:(id)sender {
    //特征值,这里是更新特征值为当前时间
    NSString *valueStr = [NSString stringWithFormat:@"%@",[NSDate date]];
    NSData *value = [valueStr dataUsingEncoding:NSUTF8StringEncoding];
    //更新特征值
    [self.peripheralManager updateValue:value
                      forCharacteristic:self.characteristicM
                   onSubscribedCentrals:nil];
}
#pragma mark - 私有方法
/* 创建特征、服务并添加服务到外围设备 */
- (void)addMyService{
    /*1.创建特征*/
    //创建特征的UUID对象
    CBUUID *characteristicUUID = [CBUUID UUIDWithString:kCharacteristicUUID];
    /* 创建特征
     * 参数
     * uuid:特征标识
     * properties:特征的属性，例如：可通知、可写、可读等
     * value:特征值
     * permissions:特征的权限
     */
    CBMutableCharacteristic *characteristicM =
    [[CBMutableCharacteristic alloc] initWithType:characteristicUUID
                                       properties:CBCharacteristicPropertyNotify
                                            value:nil
                                      permissions:CBAttributePermissionsReadable];
    self.characteristicM = characteristicM;
    //创建服务UUID对象
    CBUUID *serviceUUID = [CBUUID UUIDWithString:kServiceUUID];
    //创建服务
    CBMutableService *serviceM = [[CBMutableService alloc] initWithType:serviceUUID
                                                                primary:YES];
    //设置服务的特征
    [serviceM setCharacteristics:@[characteristicM]];
    //将服务添加到外围设备
    [self.peripheralManager addService:serviceM];
}

#pragma mark - CBPeripheralManager代理方法
/* 外围设备状态发生变化后调用 */
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{
    //判断外围设备管理器状态
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn:
        {
            NSLog(@"BLE已打开.");
            //添加服务
            [self addMyService];
            break;
        }
        default:
        {
            NSLog(@"此设备不支持BLE或未打开蓝牙功能，无法作为外围设备.");
            break;
        }
    }
}
/* 外围设备恢复状态时调用 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral
         willRestoreState:(NSDictionary *)dict
{
    NSLog(@"状态恢复");
}
/* 外围设备管理器添加服务后调用 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral
            didAddService:(CBService *)service
                    error:(NSError *)error
{
    //设置设备信息dict，CBAdvertisementDataLocalNameKey是设置设备名
    NSDictionary *dict = @{CBAdvertisementDataLocalNameKey:kPeripheralName};
    //开始广播
    [self.peripheralManager startAdvertising:dict];
    NSLog(@"向外围设备添加了服务并开始广播...");
}
/* 外围设备管理器启动广播后调用 */
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral
                                       error:(NSError *)error
{
    if (error) {
        NSLog(@"启动广播过程中发生错误，错误信息：%@",error.localizedDescription);
        return;
    }
    NSLog(@"启动广播...");
}
/* 中央设备订阅特征时调用 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral
                  central:(CBCentral *)central
didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"中心设备：%@ 已订阅特征：%@.",central,characteristic);
    //把订阅的中央设备存储下来
    if (![self.centralM containsObject:central]) {
        [self.centralM addObject:central];
    }
}
/* 中央设备取消订阅特征时调用 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral
                  central:(CBCentral *)central
didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"中心设备：%@ 取消订阅特征：%@",central,characteristic);
}

/* 外围设备管理器收到中央设备写请求时调用 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral
  didReceiveWriteRequests:(CBATTRequest *)request
{
    NSLog(@"收到写请求");
}
@end