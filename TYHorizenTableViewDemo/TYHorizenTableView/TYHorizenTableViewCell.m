//
//  TYHorizenTableViewCell.m
//  TYHorizenTableViewDemo
//
//  Created by SunYong on 15/5/8.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "TYHorizenTableViewCell.h"

@interface TYHorizenTableViewCell ()

@property (nonatomic, copy, readwrite)   NSString   *identifier;
@property (nonatomic, assign, readwrite) NSInteger  index;
@property (nonatomic, assign, readwrite) BOOL       selected;

@end

@implementation TYHorizenTableViewCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super init]) {
        if (reuseIdentifier) {
            self.identifier = reuseIdentifier;
        }
    }
    return self;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    _selected = selected;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end