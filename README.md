# TYHorizenTableView
TYHorizenTableView   用scrollView实现 可重用的水平滚动tableView 极致性能优化，原生体验

## ScreenShot

![image](https://raw.githubusercontent.com/12207480/TYHorizenTableView/master/screenshot/horizenTableView.gif)


## Usage

```objc
    TYHorizenTableView *horizonTableView = [[TYHorizenTableView alloc]initWithFrame:CGRectMake(0, 0,CGRectGetWidth(self.view.frame), 200)];
    //horizonTableView.itemSpacing = 16;
    //horizonTableView.itemWidth = 140; // 宽度相等时 会相应优化
    horizonTableView.delegate = self;
    horizonTableView.dataSource = self;
    
    [self.view addSubview:horizonTableView];
    _horizonTableView = horizonTableView;
```

## Delegate

```objc
@protocol TYHorizenTableViewDataSource <NSObject>
@required

// Total number of items
- (NSInteger)horizenTableViewOnNumberOfItems:(TYHorizenTableView *)horizenTableView;

//Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier
// get cell for display
- (TYHorizenTableViewCell *)horizenTableView:(TYHorizenTableView *)horizenTableView cellForItemAtIndex:(NSInteger)index;

@optional

// Variable width support. If width is equal ,you can use itemWidth
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
```
