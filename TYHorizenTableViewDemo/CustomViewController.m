//
//  CoustomViewController.m
//  TYHorizenTableViewDemo
//
//  Created by SunYong on 15/5/21.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "CustomViewController.h"
#import "TYHorizenTableView.h"
#import "ImageBriefCell.h"

@interface CustomViewController ()<TYHorizenTableViewDataSource,TYHorizenTableViewDelegate>
@property (nonatomic, weak) TYHorizenTableView  *horizonTableView;
@property (nonatomic, strong) NSMutableArray *imageArray;
@property (nonatomic, strong) NSMutableArray *briefArray;
@end

static NSString *reuseImageBriefCellId = @"ImageBriefCell";

@implementation CustomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.imageArray = [NSMutableArray array];
    for (int index = 0; index < 6; ++index) {
        NSString *imageName = [NSString stringWithFormat:@"jianw3-%d.jpg",index];
        [self.imageArray addObject:imageName];
    }
    
     NSString *path = [[NSBundle mainBundle] pathForResource:@"content" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                    options:NSJSONReadingAllowFragments
                                                      error:nil];
    self.briefArray = [NSMutableArray arrayWithArray:jsonObject];
    
    [self addHorizenTableView];
    
    [_horizonTableView registerNibName:reuseImageBriefCellId forCellReuseIdentifier:reuseImageBriefCellId];
    
    [_horizonTableView reloadData];
}

- (void)addHorizenTableView
{
    TYHorizenTableView *horizonTableView = [[TYHorizenTableView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 280)];
    //horizonTableView.cellSpacing
    //horizonTableView.edgeInsets
    horizonTableView.delegate = self;
    horizonTableView.dataSource = self;
    horizonTableView.pagingEnabled = YES;
    
    [self.view addSubview:horizonTableView];
    _horizonTableView = horizonTableView;
}

#pragma mark - TYHorizenTableViewDataSource

- (NSInteger)horizenTableViewOnNumberOfItems:(TYHorizenTableView *)horizenTableView
{
    return 20;//self.imageArray.count;
}

- (TYHorizenTableViewCell *)horizenTableView:(TYHorizenTableView *)horizenTableView cellForItemAtIndex:(NSInteger)index
{
    ImageBriefCell *cell = [horizenTableView dequeueReusableCellWithIdentifier:reuseImageBriefCellId];
    
    cell.imageView.image = [UIImage imageNamed:self.imageArray[index%6]];
    cell.breifLabel.text = self.briefArray[index%6];
    
    return cell;
}

- (CGFloat)horizenTableView:(TYHorizenTableView *)horizenTableView widthForItemAtIndex:(NSInteger)index
{
    return CGRectGetWidth(self.horizonTableView.frame);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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