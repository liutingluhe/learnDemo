//
//  CentralViewController.m
//  BluetoothTest
//
//  Created by 刘奥明 on 16/4/12.
//  Copyright © 2016年 liuting. All rights reserved.
//

#import "CentralViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

#define kPeripheralName         @"Liuting's Device" //外围设备名称
#define kServiceUUID            @"FFA0-FFB0" //服务的UUID
#define kCharacteristicUUID     @"FFCC-FFDD" //特征的UUID

@interface CentralViewController ()<CBCentralManagerDelegate,CBPeripheralDelegate>
@property (strong, nonatomic) CBCentralManager *centralManager;/* 中央设备管理器 */
@property (strong, nonatomic) NSMutableArray *peripherals;/* 连接的外围设备 */
@end
@implementation CentralViewController
#pragma mark - UI事件
- (void)viewDidLoad{
    [super viewDidLoad];
    self.peripherals = [NSMutableArray array];
    //创建中心设备管理器并设置当前控制器视图为代理
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}
#pragma mark - CBCentralManager代理方法
/* 中央设备管理器状态更新后调用 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    switch (central.state) {
        case CBPeripheralManagerStatePoweredOn:
            NSLog(@"BLE已打开.");
            //扫描外围设备
            [central scanForPeripheralsWithServices:nil options:nil];
            break;
        default:
            NSLog(@"此设备不支持BLE或未打开蓝牙功能，无法作为中央设备.");
            break;
    }
}
/*
 *  发现外围设备调用
 *  @param central              中央设备管理器
 *  @param peripheral        外围设备
 *  @param advertisementData 设备信息
 *  @param RSSI              信号质量（信号强度）
 */
- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI
{
    NSLog(@"发现外围设备...");
    //连接指定的外围设备，匹配设备名
    if ([peripheral.name isEqualToString:kPeripheralName]) {
        //添加保存外围设备，因为在此方法调用完外围设备对象就会被销毁
        if(![self.peripherals containsObject:peripheral]){
            [self.peripherals addObject:peripheral];
        }
        NSLog(@"开始连接外围设备...");
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
}
/* 中央设备管理器成功连接到外围设备后调用 */
- (void)centralManager:(CBCentralManager *)central
  didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"连接外围设备成功!");
    
    //停止扫描
    [self.centralManager stopScan];
    //设置外围设备的代理为当前视图控制器
    peripheral.delegate = self;
    //外围设备开始寻找服务
    [peripheral discoverServices:@[[CBUUID UUIDWithString:kServiceUUID]]];
}
/* 中央设备管理器连接外围设备失败后调用 */
- (void)centralManager:(CBCentralManager *)central
didFailToConnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error
{
    NSLog(@"连接外围设备失败!");
}
#pragma mark - CBPeripheral 代理方法
/* 外围设备寻找到服务后调用 */
- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverServices:(NSError *)error
{
    NSLog(@"已发现可用服务...");
    //遍历查找到的服务
    CBUUID *serviceUUID = [CBUUID UUIDWithString:kServiceUUID];
    CBUUID *characteristicUUID = [CBUUID UUIDWithString:kCharacteristicUUID];
    for (CBService *service in peripheral.services) {
        if([service.UUID isEqual:serviceUUID]){
            //外围设备查找指定服务中的特征，characteristics为nil，表示寻找所有特征
            [peripheral discoverCharacteristics:nil forService:service];
        }
    }
}
/* 外围设备寻找到特征后调用 */
- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverCharacteristicsForService:(CBService *)service
             error:(NSError *)error
{
    NSLog(@"已发现可用特征...");
    //遍历服务中的特征
    CBUUID *serviceUUID = [CBUUID UUIDWithString:kServiceUUID];
    CBUUID *characteristicUUID = [CBUUID UUIDWithString:kCharacteristicUUID];
    if ([service.UUID isEqual:serviceUUID]) {
        for (CBCharacteristic *characteristic in service.characteristics) {
            if ([characteristic.UUID isEqual:characteristicUUID]) {
                //情景一：通知
                /* 找到特征后设置外围设备为已通知状态（订阅特征）：
                 * 调用此方法会触发代理方法peripheral:didUpdateValueForCharacteristic:error:
                 * 调用此方法会触发外围设备管理器的订阅代理方法
                 */
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                
                //情景二：读取
                //调用此方法会触发代理方法peripheral:didUpdateValueForCharacteristic:error:
                //[peripheral readValueForCharacteristic:characteristic];
            }
        }
    }
}
/* 外围设备读取到特征值后调用 */
- (void)peripheral:(CBPeripheral *)peripheral
didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error
{
    if (characteristic.value) {
        NSString *value = [[NSString alloc] initWithData:characteristic.value
                                                encoding:NSUTF8StringEncoding];
        NSLog(@"读取到特征值：%@",value);
    }else{
        NSLog(@"未发现特征值.");
    }
}
@end
