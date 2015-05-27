//
//  TYHorizenTableViewCell.h
//  TYHorizenTableViewDemo
//
//  Created by SunYong on 15/5/8.
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

// 最好在layoutSubviews 中布局
@end
