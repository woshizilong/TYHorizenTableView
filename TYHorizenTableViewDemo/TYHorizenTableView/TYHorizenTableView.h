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
    TYHorizenTableViewPositionNone = 0, // 不滚动
    TYHorizenTableViewPositionLeft,     // 滚动到左边
    TYHorizenTableViewPositionRight,    //
    TYHorizenTableViewPositionCenter,   // 
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

// Called before the user changes the selection. Return a new index, or 0, to change the proposed selection.
- (NSInteger)horizenTableView:(TYHorizenTableView *)horizenTableView willSelectCellAtIndex:(NSInteger)index;

// Called after the user changes the selection.点击cell
- (void)horizenTableView:(TYHorizenTableView *)horizenTableView didSelectCellAtIndex:(NSInteger)index;
- (void)horizenTableView:(TYHorizenTableView *)horizenTableView didDeselectCellAtIndex:(NSInteger)index;

// cell will Display
- (void)horizenTableView:(TYHorizenTableView *)horizenTableView willDisplayCell:(TYHorizenTableViewCell *)cell atIndex:(NSInteger)index;
// cell did Disappear
- (void)horizenTableView:(TYHorizenTableView *)horizenTableView didEndDisplayingCell:(TYHorizenTableViewCell *)cell atIndex:(NSInteger)index;

@end

@interface TYHorizenTableView : UIScrollView

@property (nonatomic, assign) id<TYHorizenTableViewDataSource>  dataSource;
@property (nonatomic, assign) id<TYHorizenTableViewDelegate>    delegate;

@property (nonatomic, assign) CGFloat           cellSpacing;  // cell之间间隔
@property (nonatomic, assign) UIEdgeInsets      edgeInsets;   // 四边间距
@property (nonatomic, assign) NSInteger         maxReuseCount;// 最大可重用cell数 默认2

/**
 *  从缓冲池获取cell
 */
- (TYHorizenTableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;

/**
 *  注册cell 以便自动重用 初始化在这里实现 awakeFromNib
 */
- (void)registerNibName:(NSString *)nibName forCellReuseIdentifier:(NSString *)identifier;

/**
 *  注册cell 以便自动重用 初始化在这里实现 initWithReuseIdentifier
 */
- (void)registerClass:(Class)cellClass forCellReuseIdentifier:(NSString *)identifier;

/**
 *  滚动指定index位置
 */
- (void)scrollToIndex:(NSInteger)index atPosition:(TYHorizenTableViewPosition)position animated:(BOOL)animated;

// Selects and deselects cell. These methods will not call the delegate methods
/**
 *  选中指定index cell 默认TYHorizenTableViewPositionNone不滚动
 */
- (void)selectCellAtIndex:(NSInteger)index animated:(BOOL)animated scrollPosition:(TYHorizenTableViewPosition)position;

/**
 *  取消选中 指定index cell
 */
- (void)deSelectCellAtIndex:(NSInteger)index animated:(BOOL)animated;

/**
 *  获取index项cell,如果cell不可见返回nil
 */
- (TYHorizenTableViewCell *)cellForIndex:(NSInteger)index;

/**
 *  获取当可见cells
 */
- (NSArray *)visibleCells;;

/**
 *  重新读取数据
 */
- (void)reloadData;

@end


