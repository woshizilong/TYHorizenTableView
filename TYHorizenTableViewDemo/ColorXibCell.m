//
//  ColorXibCell.m
//  TYHorizenTableViewDemo
//
//  Created by SunYong on 15/5/19.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "ColorXibCell.h"

@implementation ColorXibCell

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor colorWithRed:arc4random()%255/255.0 green:arc4random()%255/255.0 blue:arc4random()%255/255.0 alpha:0.8];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (selected) {
        NSLog(@"cell index select:%ld",self.index);
    }else {
        NSLog(@"cell index deSelect:%ld",self.index);
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
