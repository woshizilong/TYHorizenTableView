//
//  AttribtedLabelController.m
//  TYHorizenTableViewDemo
//
//  Created by tanyang on 15/6/8.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "AttribtedLabelController.h"
#import "TYHorizenTableView.h"
#import "AttributedLableCell.h"
#import "TYTextStorage.h"
#import "TYImageStorage.h"
#import "RegexKitLite.h"

#define RGB(r,g,b,a)	[UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

@interface AttribtedLabelController ()<TYHorizenTableViewDataSource,TYHorizenTableViewDelegate>
@property (nonatomic, weak) TYHorizenTableView  *horizonTableView;
@property (nonatomic, strong) TYTextContainer *textContainer;
@end

static NSString *reuseAttribtedLabelCellId = @"AttributedLableCell";

@implementation AttribtedLabelController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self addHorizenTableView];
    
    [self addAttributedString];
    
    [_horizonTableView registerClass:[AttributedLableCell class] forCellReuseIdentifier:reuseAttribtedLabelCellId];
    
    [_horizonTableView reloadData];
}

- (void)addAttributedString
{
    NSString *text = @"[CYLoLi]其实所有漂泊的人，[haha,15,15]不过是为了有一天能够不再漂泊，[haha,15,15]能用自己的力量撑起身后的家人和自己爱的人。[avatar,60,60]\n\t任何值得去的地方，都没有捷径；\n\t任何值得等待的人，都会迟来一些；\n\t任何值得追逐的梦想，都必须在一路艰辛中备受嘲笑。\n\t所以，不要怕，不要担心你所追逐的有可能是错的。\n\t因为，不被嘲笑的梦想不是梦想。";
    
    // 属性文本生成器
    TYTextContainer *attStringCreater = [[TYTextContainer alloc]init];
    attStringCreater.text = text;
    NSMutableArray *tmpArray = [NSMutableArray array];
    
    // 正则匹配图片信息
    [text enumerateStringsMatchedByRegex:@"\\[(\\w+?),(\\d+?),(\\d+?)\\]" usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        
        if (captureCount > 3) {
            // 图片信息储存
            TYImageStorage *imageStorage = [[TYImageStorage alloc]init];
            imageStorage.imageName = capturedStrings[1];
            imageStorage.range = capturedRanges[0];
            imageStorage.size = CGSizeMake([capturedStrings[2]intValue], [capturedStrings[3]intValue]);
            
            [tmpArray addObject:imageStorage];
        }
    }];
    
    [attStringCreater addImageWithName:@"CYLoLi" range:[text rangeOfString:@"[CYLoLi]"] size:CGSizeMake(CGRectGetWidth(self.view.frame)-20, 180)];
    
    // 添加图片信息数组到label
    [attStringCreater addTextStorageArray:tmpArray];
    
    TYTextStorage *textStorage = [[TYTextStorage alloc]init];
    textStorage.range = [text rangeOfString:@"[CYLoLi]其实所有漂泊的人，"];
    textStorage.textColor = RGB(213, 0, 0, 1);
    textStorage.font = [UIFont systemFontOfSize:16];
    [attStringCreater addTextStorage:textStorage];
    
    textStorage = [[TYTextStorage alloc]init];
    textStorage.range = [text rangeOfString:@"不过是为了有一天能够不再漂泊，"];
    textStorage.textColor = RGB(0, 155, 0, 1);
    textStorage.font = [UIFont systemFontOfSize:18];
    [attStringCreater addTextStorage:textStorage];
    
    _textContainer = [attStringCreater createTextContainerWithTextWidth:CGRectGetWidth(self.view.frame)-20];
}

- (void)addHorizenTableView
{
    TYHorizenTableView *horizonTableView = [[TYHorizenTableView alloc]initWithFrame:self.view.bounds];
    //horizonTableView.itemSpacing = 8;
    //horizonTableView.edgeInsets
    horizonTableView.delegate = self;
    horizonTableView.dataSource = self;
    horizonTableView.itemWidth = CGRectGetWidth(self.view.frame);
    horizonTableView.pagingEnabled = YES;
    
    [self.view addSubview:horizonTableView];
    _horizonTableView = horizonTableView;
}

#pragma mark - TYHorizenTableViewDataSource

- (NSInteger)horizenTableViewOnNumberOfItems:(TYHorizenTableView *)horizenTableView
{
    return 20;
}

- (TYHorizenTableViewCell *)horizenTableView:(TYHorizenTableView *)horizenTableView cellForItemAtIndex:(NSInteger)index
{
    AttributedLableCell *cell = [horizenTableView dequeueReusableCellWithIdentifier:reuseAttribtedLabelCellId];
    
    // 如果没有register 需要 if(cell == nil)
    cell.label.textContainer = _textContainer;
    [cell.label setFrameWithOrign:CGPointMake(10, 10) Width:CGRectGetWidth(self.view.frame)-20];
    
    return cell;
}

- (CGFloat)horizenTableView:(TYHorizenTableView *)horizenTableView widthForItemAtIndex:(NSInteger)index
{
    return CGRectGetWidth(horizenTableView.frame);
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
