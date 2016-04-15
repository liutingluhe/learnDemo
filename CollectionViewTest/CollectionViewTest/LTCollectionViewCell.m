//
//  LTCollectionViewCell.m
//  CollectionViewTest
//
//  Created by 刘奥明 on 16/4/14.
//  Copyright © 2016年 liuting. All rights reserved.
//

#import "LTCollectionViewCell.h"
@implementation LTCollectionViewCell
/* 方块视图的缓存池标示 */
+ (NSString *)cellIdentifier{
    static NSString *cellIdentifier = @"CollectionViewCellIdentifier";
    return cellIdentifier;
}
/* 获取方块视图对象 */
+ (instancetype)cellWithCollectionView:(UICollectionView *)collectionView
                          forIndexPath:(NSIndexPath *)indexPath
{
    //从缓存池中寻找方块视图对象，如果没有，该方法自动调用alloc/initWithFrame创建一个新的方块视图返回
    LTCollectionViewCell *cell =
        [collectionView dequeueReusableCellWithReuseIdentifier:[LTCollectionViewCell cellIdentifier]
                                                  forIndexPath:indexPath];
    return cell;
}
/* 注册了方块视图后，当缓存池中没有底部视图的对象时候，自动调用alloc/initWithFrame创建 */
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        //创建label
        UILabel *textLabel = [[UILabel alloc] init];
        //设置label尺寸
        CGFloat x = 5;
        CGFloat y = 5;
        CGFloat width = frame.size.width - 10;
        CGFloat height = frame.size.height - 10;
        textLabel.frame = CGRectMake(x, y, width, height);
        //设置label属性
        textLabel.numberOfLines = 0;
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.font = [UIFont systemFontOfSize:15];
        //添加到父控件
        [self.contentView addSubview:textLabel];
        self.textLabel = textLabel;
    }
    return self;
}
@end
