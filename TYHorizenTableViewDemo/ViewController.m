//
//  ViewController.m
//  TYHorizenTableViewDemo
//
//  Created by SunYong on 15/5/8.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "ViewController.h"
#import "TYHorizenTableView.h"
#import "ColorViewCell.h"
#import "ColorXibCell.h"

@interface ViewController ()<TYHorizenTableViewDataSource,TYHorizenTableViewDelegate,UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, weak) TYHorizenTableView *horizonTableView;
@end

static NSString *reuseColorXibCellId = @"ColorXibCell";
static NSString *reuseColorViewCellId = @"ColorViewCell";

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self addHorizenTableView];
    
    [self addTableview];
    
    // 注册cell
    [_horizonTableView registerClass:NSClassFromString(reuseColorViewCellId) forCellReuseIdentifier:reuseColorViewCellId];
    
    [_horizonTableView registerNibName:reuseColorXibCellId forCellReuseIdentifier:reuseColorXibCellId];
    
    [_horizonTableView reloadData];
}

- (void)addHorizenTableView
{
    TYHorizenTableView *horizonTableView = [[TYHorizenTableView alloc]initWithFrame:CGRectMake(0, 46, CGRectGetWidth(self.view.frame), 200)];
    //horizonTableView.cellSpacing = 16;
    horizonTableView.delegate = self;
    horizonTableView.dataSource = self;
    
    [self.view addSubview:horizonTableView];
    _horizonTableView = horizonTableView;
}

- (void)addTableview
{
    // 添加tableView
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(60, CGRectGetMaxY(_horizonTableView.frame)+10, 200, 320)];
    tableView.transform = CGAffineTransformMakeRotation(M_PI/-2);
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
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
    if (index%2 == 1) {
        TYHorizenTableViewCell *cell = [horizenTableView dequeueReusableCellWithIdentifier:reuseColorViewCellId];
        
        //  使用了注册函数register 将会自动创建
        //    if (cell == nil) {
        //        cell = [[TYHorizenTableViewCell alloc]initWithReuseIdentifier:reuseColorViewCellId];
        //        cell.backgroundColor = [UIColor colorWithRed:arc4random()%255/255.0 green:arc4random()%255/255.0 blue:arc4random()%255/255.0 alpha:0.8];
        //    }
        
        return cell;
    }else {
        TYHorizenTableViewCell *cell = [horizenTableView dequeueReusableCellWithIdentifier:reuseColorXibCellId];
        return cell;
    }
}

- (CGFloat)horizenTableView:(TYHorizenTableView *)horizenTableView widthForItemAtIndex:(NSInteger)index
{
    return 100 + arc4random()%60;
}

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
