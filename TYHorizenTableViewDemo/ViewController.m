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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self addHorizenTableView];
}

- (void)addHorizenTableView
{
    TYHorizenTableView *horizonTableView = [[TYHorizenTableView alloc]initWithFrame:CGRectMake(0, 64, CGRectGetWidth(self.view.frame), 260)];
    horizonTableView.delegate = self;
    horizonTableView.dataSource = self;
    
    [self.view addSubview:horizonTableView];
    
    [horizonTableView reloadData];
}

- (NSInteger)horizenTableViewOnNumberOfItems:(TYHorizenTableView *)horizenTableView
{
    return 10;
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
    return 60 + arc4random()%60;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
