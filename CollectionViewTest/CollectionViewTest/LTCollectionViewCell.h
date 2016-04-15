//
//  LTCollectionViewCell.h
//  CollectionViewTest
//
//  Created by 刘奥明 on 16/4/14.
//  Copyright © 2016年 liuting. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LTCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) UILabel *textLabel;

/* 方块视图的缓存池标示 */
+ (NSString *)cellIdentifier;
/* 获取方块视图对象 */
+ (instancetype)cellWithCollectionView:(UICollectionView *)collectionView
                          forIndexPath:(NSIndexPath *)indexPath;

@end
