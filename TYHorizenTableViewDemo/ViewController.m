//
//  ViewController.m
//  TYHorizenTableViewDemo
//
//  Created by SunYong on 15/5/8.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "ViewController.h"
#import "TYHorizenTableView.h"

@interface ViewController ()<TYHorizenTableViewDataSource,TYHorizenTableViewDelegate>
@property (nonatomic, weak) TYHorizenTableView *horizonTableView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self addHorizenTableView];
    
    [self addScrollButton];
    
    [_horizonTableView reloadData];
}

- (void)addHorizenTableView
{
    TYHorizenTableView *horizonTableView = [[TYHorizenTableView alloc]initWithFrame:CGRectMake(0, 124, CGRectGetWidth(self.view.frame), 200)];
    horizonTableView.cellSpacing = 16;
    horizonTableView.delegate = self;
    horizonTableView.dataSource = self;
    
    [self.view addSubview:horizonTableView];
    _horizonTableView = horizonTableView;
}

- (void)addScrollButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(0, 0, 100, 40);
    button.center = CGPointMake(CGRectGetWidth(self.view.frame)/2, CGRectGetMaxY(_horizonTableView.frame)+60);
    [button setTitle:@"滚动到下一页" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(scrollToIndex:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)scrollToIndex:(UIButton *)sender
{
    static NSInteger index = 2;
    NSLog(@"滚动到第%ld页",index);
    BOOL animated = YES;//(index%20 != 0);
    [_horizonTableView scrollToIndex:index++%20 atPosition:TYHorizenTableViewPositionCenter animated:animated];
}

- (NSInteger)horizenTableViewOnNumberOfItems:(TYHorizenTableView *)horizenTableView
{
    return 20;
}

- (TYHorizenTableViewCell *)horizenTableView:(TYHorizenTableView *)horizenTableView cellForItemAtIndex:(NSInteger)index
{
    TYHorizenTableViewCell *cell = [horizenTableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[TYHorizenTableViewCell alloc]initWithReuseIdentifier:@"cell"];
        cell.backgroundColor = [UIColor colorWithRed:arc4random()%255/255.0 green:arc4random()%255/255.0 blue:arc4random()%255/255.0 alpha:0.8];
    }
    
    return cell;
}

- (CGFloat)horizenTableView:(TYHorizenTableView *)horizenTableView widthForItemAtIndex:(NSInteger)index
{
    return 120 + arc4random()%60;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
