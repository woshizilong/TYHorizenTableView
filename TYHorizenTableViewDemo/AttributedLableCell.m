//
//  AttributedLableCell.m
//  TYHorizenTableViewDemo
//
//  Created by tanyang on 15/6/8.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "AttributedLableCell.h"

@implementation AttributedLableCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self addAttributedLabel];
    }
    return self;
}

- (void)addAttributedLabel
{
    TYAttributedLabel *label = [[TYAttributedLabel alloc]init];
    [self addSubview:label];
    _label = label;
}

@end
