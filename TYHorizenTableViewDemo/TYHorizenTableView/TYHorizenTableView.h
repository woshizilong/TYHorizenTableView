//
//  TYHorizenTableView.h
//  TYHorizenTableViewDemo
//
//  Created by SunYong on 15/5/8.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//  Horizen Scroll TableView

#import <UIKit/UIKit.h>
#import "TYHorizenTableViewCell.h"

typedef enum {
    TYHorizenTableViewPositionNone = 0,
    TYHorizenTableViewPositionLeft,
    TYHorizenTableViewPositionRight,
    TYHorizenTableViewPositionCenter,
} TYHorizenTableViewPosition;

@class TYHorizenTableView;

@protocol TYHorizenTableViewDataSource <NSObject>
@required

/**
 *  水平滚动tableview 一共有几个元素item;
 */
- (NSInteger)horizenTableViewOnNumberOfItems:(TYHorizenTableView *)horizenTableView;

/**
 *  获取对应下标Index的cell
 */
- (TYHorizenTableViewCell *)horizenTableView:(TYHorizenTableView *)horizenTableView cellForItemAtIndex:(NSInteger)index;

/**
 *  获取可变宽度
 */
- (CGFloat)horizenTableView:(TYHorizenTableView *)horizenTableView widthForItemAtIndex:(NSInteger)index;

@end

@protocol TYHorizenTableViewDelegate <UIScrollViewDelegate>
@optional

/**
 *  选中点击cell
 */
- (void)horizenTableView:(TYHorizenTableView *)horizenTableView didSelectCellAtIndex:(NSInteger)index;

/**
 *  取消选中点击cell
 */
//- (void)horizenTableView:(TYHorizenTableView *)horizenTableView didDeselectCellAtIndex:(NSInteger)index;

@end

@interface TYHorizenTableView : UIScrollView

@property (nonatomic, assign) id<TYHorizenTableViewDataSource>  dataSource;
@property (nonatomic, assign) id<TYHorizenTableViewDelegate>    delegate;

@property (nonatomic, assign) CGFloat           cellSpacing; // cell之间间隔
@property (nonatomic, assign) UIEdgeInsets      EdgeInsets;  // 四边间距

/**
 *  从缓冲池获取cell
 */
- (TYHorizenTableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;

/**
 *  滚动指定index位置
 */
- (void)scrollToIndex:(NSInteger)index atPosition:(TYHorizenTableViewPosition)position animated:(BOOL)animated;

/**
 *  选中指定index cell
 */
- (void)selectCellAtIndex:(NSInteger)index animated:(BOOL)animated;

/**
 *  取消选中 指定index cell
 */
//- (void)deselectCellAtIndex:(NSInteger)index animated:(BOOL)animated;

/**
 *  获取index项cell,如果cell不可见返回nil
 */
- (TYHorizenTableViewCell *)cellForIndex:(NSInteger)index;

/**
 *  重新读取数据
 */
- (void)reloadData;

@end


