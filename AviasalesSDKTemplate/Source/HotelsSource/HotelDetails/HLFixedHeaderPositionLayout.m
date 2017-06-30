//
//  HLHotelDetailsLayout.m
//  HotelLook
//
//  Created by Oleg on 18/02/14.
//  Copyright (c) 2014 Anton Chebotov. All rights reserved.
//

#import "HLFixedHeaderPositionLayout.h"


@implementation HLFixedHeaderPositionLayout

//- (CGRect)headerFrame
//{
//    newHeaderAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:indexPath];
//}

- (CGSize)collectionViewContentSize
{
    CGSize contentSize = [super collectionViewContentSize];
    if (contentSize.height <= self.collectionView.bounds.size.height) {
        contentSize = CGSizeMake(contentSize.width, self.collectionView.bounds.size.height);
    }
    
    return contentSize;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *result = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    CGPoint const contentOffset = self.collectionView.contentOffset;
    
    NSArray *attrKinds = [result valueForKeyPath:@"representedElementKind"];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    id<UICollectionViewDelegateFlowLayout> delegate = (id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate;
    CGSize headerSize = [delegate collectionView:self.collectionView layout:self referenceSizeForHeaderInSection:0];
    CGSize footerSize = [delegate collectionView:self.collectionView layout:self referenceSizeForFooterInSection:0];
    
    if (contentOffset.y > .0f) {
        NSUInteger headerIndex = [attrKinds indexOfObject:UICollectionElementKindSectionHeader];
        UICollectionViewLayoutAttributes *newHeaderAttributes = nil;
        if (headerIndex == NSNotFound) {
            newHeaderAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:indexPath];
            [result addObject:newHeaderAttributes];
        } else {
            newHeaderAttributes = [result objectAtIndex:headerIndex];
        }
        
        CGRect frame = CGRectMake(.0f, contentOffset.y, headerSize.width, headerSize.height);
        newHeaderAttributes.frame = frame;
        newHeaderAttributes.zIndex = 1024.f;
    }
    
    CGFloat yLimit = (self.collectionViewContentSize.height - self.collectionView.bounds.size.height);
    if ((self.collectionViewContentSize.height > self.collectionView.bounds.size.height) && (contentOffset.y < yLimit)) {
        NSUInteger footerIndex = [attrKinds indexOfObject:UICollectionElementKindSectionFooter];
        CGFloat yOffest = (self.collectionView.bounds.size.height - footerSize.height);
        
        if (contentOffset.y > .0f) {
            yOffest+= contentOffset.y;
        }
        
        UICollectionViewLayoutAttributes *newFooterAttributes = nil;
        if (footerIndex == NSNotFound) {
            newFooterAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter withIndexPath:indexPath];
            [result addObject:newFooterAttributes];
        } else {
            newFooterAttributes = [result objectAtIndex:footerIndex];
        }
        
        CGRect frame = CGRectMake(.0f, yOffest, footerSize.width, footerSize.height);
        newFooterAttributes.frame = frame;
        newFooterAttributes.zIndex = 1024.f;
    }
    
    return result;
}

@end
