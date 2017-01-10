//
//  StickyHeaderFlowLayout.m
//  TestStickHeader
//
//  Created by liqi on 17/1/9.
//  Copyright © 2017年 liqi. All rights reserved.
//

#import "StickyHeaderFlowLayout.h"

@implementation StickyHeaderFlowLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        _stickyHeaderZIndex = 1000;
        _stickyHeader = NO;
    }
    return self;
}

#pragma mark - OverRide Methods

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    // 1.得到显示屏幕 原始的属性集合数据
    NSMutableArray<UICollectionViewLayoutAttributes *> *attributes = [super layoutAttributesForElementsInRect:rect].mutableCopy;
    
    // 2.找出在显示屏幕有cell，但是header已经不在屏幕内的组
    NSMutableArray<NSNumber *> *visibleSectionsWithoutHeader = [NSMutableArray array];
    [attributes enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull attribute, NSUInteger idx, BOOL * _Nonnull stop) {
        // a.先加入集合
        if (![visibleSectionsWithoutHeader containsObject:@(attribute.indexPath.section)]) {
            [visibleSectionsWithoutHeader addObject:@(attribute.indexPath.section)];
        }
        // b.屏幕内的header 移除
        if (attribute.representedElementKind == UICollectionElementKindSectionHeader) {
            NSInteger section = [visibleSectionsWithoutHeader indexOfObject:@(attribute.indexPath.section)];
            if (section != NSNotFound) {
                [visibleSectionsWithoutHeader removeObject:@(attribute.indexPath.section)];
            }
        }
    }];
    
    // 3.超出屏幕内的header的属性加入到数组中
    [visibleSectionsWithoutHeader enumerateObjectsUsingBlock:^(NSNumber * _Nonnull sectionNumber, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([self shouldStickHeaderToTopInSection:[sectionNumber integerValue]]) {
            UICollectionViewLayoutAttributes *headerAttribute = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:[sectionNumber integerValue]]];
            // a.判断是否有header
            if (headerAttribute.size.width > 0 && headerAttribute.size.height > 0) {
                [attributes addObject:headerAttribute];
            }
        }
    }];
    
    // 4.对header的frame属性进行调整
    [attributes enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull attribute, NSUInteger idx, BOOL * _Nonnull stop) {
        if (attribute.representedElementKind == UICollectionElementKindSectionHeader) {
            if ([self shouldStickHeaderToTopInSection:attribute.indexPath.section]) {
                // a.当前组item的最小和最大Y坐标值
                CGFloat maxItemY = CGRectGetMaxY(attribute.frame);
                CGFloat minItemY = CGRectGetMaxY(attribute.frame);
                [self getYFromSection:attribute.indexPath.section maxY:&maxItemY minY:&minItemY];
                // b.contentInset偏移
                CGFloat bottomInset = self.sectionInset.bottom;
                CGFloat topInset = self.sectionInset.top;
                if ([self.collectionView.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
                    UIEdgeInsets sectionInset = [(id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:attribute.indexPath.section];
                    bottomInset = sectionInset.bottom;
                    topInset = sectionInset.top;
                }
                // c.header正常状态的 最大:与底部footer接触时 最小:与组中具有最小原点的item接触时（减去上contentInset.top）
                CGFloat headerMaxY = maxItemY + bottomInset - attribute.frame.size.height;
                CGFloat headerMinY = minItemY - topInset - attribute.frame.size.height;
                // b.header固定在顶部状态时，要根据contentOffset调整，与headerMinY相比较，取最大值,再与headerMaxY相比，取最小值
                CGFloat yOffset = self.collectionView.contentOffset.y + self.collectionView.contentInset.top;
                CGFloat headerOriginY = MAX(headerMinY, yOffset);
                headerOriginY = MIN(headerOriginY, headerMaxY);
                
                CGRect frame = attribute.frame;
                frame.origin.y = headerOriginY;
                attribute.frame = frame;
                attribute.zIndex = self.stickyHeaderZIndex;
            }
        }
    }];
    
    
    return [attributes copy];
}

#pragma mark - Private Methods

- (void)getYFromSection:(NSInteger)section maxY:(CGFloat *)maxY minY:(CGFloat *)minY
{
    NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:section];
    
    if (numberOfItems > 0) {
        for (int index = 0; index < numberOfItems; index++) {
            UICollectionViewLayoutAttributes *attributeOfItem = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:section]];
            if ((attributeOfItem.frame.origin.y + attributeOfItem.frame.size.height)>= *maxY) {
                *maxY = attributeOfItem.frame.origin.y + attributeOfItem.frame.size.height;
            }
            
            if (index == 0) {
                *minY = attributeOfItem.frame.origin.y;
            }
            else if (attributeOfItem.frame.origin.y <= *minY) {
                *minY = attributeOfItem.frame.origin.y;
            }
        }
    }
}

- (BOOL)shouldStickHeaderToTopInSection:(NSUInteger)section
{
    if (self.stickyHeader) return self.stickyHeader;
    BOOL shouldStickToTop = NO;
    if ([self.collectionView.delegate conformsToProtocol:@protocol(StickyHeaderFlowLayoutDelegate)]) {
        id<StickyHeaderFlowLayoutDelegate>stickyHeaderDelegate = (id<StickyHeaderFlowLayoutDelegate>)self.collectionView.delegate;
        if ([stickyHeaderDelegate respondsToSelector:@selector(collectionView:layout:stickyHeaderForSectionAtIndex:)]) {
            shouldStickToTop = [stickyHeaderDelegate collectionView:self.collectionView layout:self stickyHeaderForSectionAtIndex:section];
        }
    }
    return shouldStickToTop;
}

@end
