//
//  StickyHeaderFlowLayout.h
//  TestStickHeader
//
//  Created by liqi on 17/1/9.
//  Copyright © 2017年 liqi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StickyHeaderFlowLayoutDelegate <UICollectionViewDelegateFlowLayout>
@optional

/**
 指定具体header是否固定在上部

 @param collectionView       当前collectionView
 @param collectionViewLayout 当前collectionViewLayout
 @param section              当前section

 @return YES 固定在上部， NO 不是
 */
- (BOOL)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout stickyHeaderForSectionAtIndex:(NSInteger)section;

@end

@interface StickyHeaderFlowLayout : UICollectionViewFlowLayout

/** 是否固定在上部, 默认为 NO (设置此值后，忽略代理方法) */
@property (nonatomic, assign) BOOL stickyHeader;

/** 在Ｚ方向的显示大小 默认为 1000 */
@property (nonatomic, assign) CGFloat stickyHeaderZIndex;

@end
