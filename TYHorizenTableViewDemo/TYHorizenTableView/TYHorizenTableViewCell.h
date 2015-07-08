//
//  TYHorizenTableViewCell.h
//  TYHorizenTableViewDemo
//
//  Created by tanyang on 15/5/8.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TYHorizenTableViewCell : UIView

@property (nonatomic, copy, readonly)   NSString    *identifier; // 可重用标识

@property (nonatomic, assign, readonly) NSInteger   index;
@property (nonatomic, assign, readonly) BOOL        selected;

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;

+ (instancetype)cellWithNib:(UINib *)nib identifier:(NSString *)reuseIdentifier;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated;

// cell放入重用池 可以重置Cell 释放内存
- (void)didDequeUnuseCell;

@end
