//
//  ViewController.m
//  TestStickHeader
//
//  Created by liqi on 17/1/9.
//  Copyright © 2017年 liqi. All rights reserved.
//

#import "ViewController.h"
#import "StickyHeaderFlowLayout.h"
#import "TestCell.h"
#import "HeaderReusableView.h"

@interface ViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, StickyHeaderFlowLayoutDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = YES;
    [self.view addSubview:self.collectionView];
}

#pragma mark - UICollectionView

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) collectionViewLayout:[self layout]];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([TestCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([TestCell class])];
        [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([HeaderReusableView class]) bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([HeaderReusableView class])];
        [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([HeaderReusableView class]) bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:NSStringFromClass([HeaderReusableView class])];
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)layout
{
    StickyHeaderFlowLayout *layout = [[StickyHeaderFlowLayout alloc] init];
    
    // 全部固定设为YES, 局部固定则设为NO, 并实现代理方法
    layout.stickyHeader = YES;
    
    return layout;
}

#pragma mark - UICollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 10;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 5) {
        return 0;
    }
    return 40;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TestCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TestCell class]) forIndexPath:indexPath];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    HeaderReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass([HeaderReusableView class]) forIndexPath:indexPath];
    if (kind == UICollectionElementKindSectionFooter) {
        header.titleLbl.text = [NSString stringWithFormat:@"footer section %ld", indexPath.section];
    }
    else {
        header.titleLbl.text = [NSString stringWithFormat:@"header section %ld", indexPath.section];
    }
    
    if (indexPath.section % 2 != 0) {
        header.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.5];
    }
    else {
        header.backgroundColor = [UIColor colorWithRed:0.3 green:0.4 blue:0.3 alpha:0.5];
    }
    return header;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) {
        if (indexPath.item == 38) {
            return CGSizeMake(50, 100);
        }
    }
    return CGSizeMake(50, 50);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if (section == 4) {
        return UIEdgeInsetsMake(0, 0, 50, 0);
    }
    return UIEdgeInsetsZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(0, 100);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    if (section == 3) {
        return CGSizeZero;
    }
    return CGSizeMake(0, 50);
}

#pragma mark - 指定固定组

- (BOOL)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout stickyHeaderForSectionAtIndex:(NSInteger)section
{
    if (section == 0 || section == 2 || section == 6) {
        return YES;
    }
    return NO;
}

@end
