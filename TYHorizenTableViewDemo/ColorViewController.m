//
//  ColorViewController.m
//  TYHorizenTableViewDemo
//
//  Created by SunYong on 15/5/21.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "ColorViewController.h"
#import "TYHorizenTableView.h"
#import "ColorViewCell.h"
//#import "ColorXibCell.h"

@interface ColorViewController ()<TYHorizenTableViewDataSource,TYHorizenTableViewDelegate,UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, weak) TYHorizenTableView  *horizonTableView;
@property (nonatomic, weak) UITableView         *tableView;
@end

//static NSString *reuseColorXibCellId = @"ColorXibCell";
static NSString *reuseColorViewCellId = @"ColorViewCell";
@implementation ColorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self addHorizenTableView];
    
    [self addScrollButton];
    
    [self addTableview];
    
    // 注册cell
    [_horizonTableView registerClass:NSClassFromString(reuseColorViewCellId) forCellReuseIdentifier:reuseColorViewCellId];
    
    [_horizonTableView reloadData];
}

#pragma mark - addView

- (void)addHorizenTableView
{
    TYHorizenTableView *horizonTableView = [[TYHorizenTableView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 200)];
    //horizonTableView.itemSpacing = 16;
    //horizonTableView.itemWidth = 140;
    horizonTableView.delegate = self;
    horizonTableView.dataSource = self;
    
    [self.view addSubview:horizonTableView];
    _horizonTableView = horizonTableView;
}

- (void)addTableview
{
    // 添加tableView
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(60, CGRectGetMaxY(_horizonTableView.frame)+10, 200, CGRectGetWidth(self.view.frame))];
    tableView.transform = CGAffineTransformMakeRotation(M_PI/-2);
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    _tableView = tableView;
}

- (void)addScrollButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(0, 0, 320, 36);
    button.center = CGPointMake(CGRectGetWidth(self.view.frame)/2, CGRectGetMaxY(_horizonTableView.frame)+40);
    [button setTitle:@"滚动到随机页 下面是UITableView" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(scrollToIndex:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)scrollToIndex:(UIButton *)sender
{
    static NSInteger index = 2;
    index = arc4random()%19;
    NSLog(@"滚动到第%ld页",(long)index);
    BOOL animated = YES;//(index%20 != 0);
    
    [_horizonTableView scrollToIndex:index++%20 atPosition:TYHorizenTableViewPositionCenter animated:animated];
    
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:animated];
}

#pragma mark - TYHorizenTableViewDataSource

- (NSInteger)horizenTableViewOnNumberOfItems:(TYHorizenTableView *)horizenTableView
{
    return 20;
}

- (TYHorizenTableViewCell *)horizenTableView:(TYHorizenTableView *)horizenTableView cellForItemAtIndex:(NSInteger)index
{
    TYHorizenTableViewCell *cell = [horizenTableView dequeueReusableCellWithIdentifier:reuseColorViewCellId];
    
    //  使用了注册函数register 将会自动创建 不需要一下代码
    //    if (cell == nil) {
    //        cell = [[TYHorizenTableViewCell alloc]initWithReuseIdentifier:reuseColorViewCellId];
    //        cell.backgroundColor = [UIColor colorWithRed:arc4random()%255/255.0 green:arc4random()%255/255.0 blue:arc4random()%255/255.0 alpha:0.8];
    //    }
    
    return cell;
}

- (CGFloat)horizenTableView:(TYHorizenTableView *)horizenTableView widthForItemAtIndex:(NSInteger)index
{
    return 100 + arc4random()%60;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.backgroundColor = [UIColor colorWithRed:arc4random()%255/255.0 green:arc4random()%255/255.0 blue:arc4random()%255/255.0 alpha:0.8];
        cell.contentView.transform = CGAffineTransformMakeRotation(M_PI/2);
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100 + arc4random()%60;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
