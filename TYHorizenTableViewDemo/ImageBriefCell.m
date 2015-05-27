//
//  ImageBriefCell.m
//  TYHorizenTableViewDemo
//
//  Created by tanyang on 15/5/23.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "ImageBriefCell.h"

@implementation ImageBriefCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        
        _imageView = [[UIImageView alloc]init];
        [self addSubview:_imageView];
        
        _breifLabel = [[UILabel alloc]init];
        _breifLabel.numberOfLines = 2;
        _breifLabel.textColor = [UIColor whiteColor];
        _breifLabel.font = [UIFont systemFontOfSize:16];
        _breifLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        [self addSubview:_breifLabel];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)layoutSubviews
{
    _imageView.frame = self.bounds;
    _breifLabel.frame = CGRectMake(0, CGRectGetHeight(self.frame) -40, CGRectGetWidth(self.frame), 40);
}

@end
