//
//  LTCollectionHeaderView.h
//  CollectionViewTest
//
//  Created by 刘奥明 on 16/4/14.
//  Copyright © 2016年 liuting. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LTCollectionHeaderView : UICollectionReusableView

@property (strong, nonatomic) UILabel *textLabel;

/* 顶部视图的缓存池标示 */
+ (NSString *)headerViewIdentifier;
/* 获取顶部视图对象 */
+ (instancetype)headerViewWithCollectionView:(UICollectionView *)collectionView
                                forIndexPath:(NSIndexPath *)indexPath;

@end
