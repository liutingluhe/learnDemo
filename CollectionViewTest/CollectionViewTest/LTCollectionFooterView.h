//
//  LTCollectionFooterView.h
//  CollectionViewTest
//
//  Created by 刘奥明 on 16/4/14.
//  Copyright © 2016年 liuting. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LTCollectionFooterView : UICollectionReusableView

@property (strong, nonatomic) UILabel *textLabel;

/* 底部视图的缓存池标示 */
+ (NSString *)footerViewIdentifier;
/* 获取底部视图对象 */
+ (instancetype)footerViewWithCollectionView:(UICollectionView *)collectionView
                                forIndexPath:(NSIndexPath *)indexPath;

@end
