//
//  CXLSlideListViewController.m
//  CXLSlideList
//
//  Created by lawrence on 5/13/15.
//  Copyright (c) 2015 lawrence. All rights reserved.
//

#import "CXLSlideListViewController.h"

#define Main_Screen_Width [UIScreen mainScreen].bounds.size.width
#define Main_Screen_Height [UIScreen mainScreen].bounds.size.height
@interface CXLSlideListViewController ()<UITableViewDelegate>

@property (nonatomic,strong)UITableViewController *mainTableViewController;
@property (nonatomic,strong)UITableViewController *secondTableViewController;
@property (nonatomic,strong)UITableViewController *thirdTableViewcontroller;
@end

static NSIndexPath * _mainIndexPath;
static NSIndexPath * _secondIndexPath;
static NSIndexPath * _thirdIndexPath;

static CGFloat mainTableToSecondTableGap;
static CGFloat secondTableToThirdTableGap;

@implementation CXLSlideListViewController

#pragma mark - View Controller Life Cycle

-(id)initWithMainTableViewController:(UITableViewController *)mainTableViewController secondTableViewController:(UITableViewController *)secondTableViewController thirdTableViewController:(UITableViewController *)thirdTableViewController{
    
    self = [self init];
    if (self) {
        _mainTableViewController = mainTableViewController;
        _secondTableViewController = secondTableViewController;
        _thirdTableViewcontroller = thirdTableViewController;
        
        //set Default indexPath value
        NSUInteger indexes[] = {0,0};
        _mainIndexPath = [[NSIndexPath alloc] initWithIndexes:indexes length:2];
        _secondIndexPath = [[NSIndexPath alloc] initWithIndexes:indexes length:2];
        _thirdIndexPath = [[NSIndexPath alloc] initWithIndexes:indexes length:2];
        
        //Set Default Gap Value
        mainTableToSecondTableGap = [UIScreen mainScreen].bounds.size.width/3;
        secondTableToThirdTableGap = [UIScreen mainScreen].bounds.size.width/3;
        if (_thirdTableViewcontroller == nil) {
            mainTableToSecondTableGap = [UIScreen mainScreen].bounds.size.width/2;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self resizeMainTableViewController];
    [self resizeSecondTableViewController];
    [self resizeThirdTableViewController];
    
    UISwipeGestureRecognizer *swipToRightGuesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipToRightGuesture:)];
    swipToRightGuesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipToRightGuesture];
    
    UISwipeGestureRecognizer *swipToLeftGuesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipToLeftGuesture:)];
    swipToRightGuesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipToLeftGuesture];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Resize TableView 
-(void)resizeMainTableViewController{
    [self.mainTableViewController.tableView setFrame:CGRectMake(0, 0,Main_Screen_Width,Main_Screen_Height)];
    [self.view addSubview:self.mainTableViewController.tableView];
    self.mainTableViewController.tableView.delegate = self;
}

-(void)resizeSecondTableViewController{
    [self.secondTableViewController.tableView setFrame:CGRectMake(Main_Screen_Width, 0, Main_Screen_Width-mainTableToSecondTableGap, Main_Screen_Height)];
    [self.view addSubview:self.secondTableViewController.tableView];
    self.secondTableViewController.tableView.delegate = self;
}

-(void)resizeThirdTableViewController{
    [self.thirdTableViewcontroller.tableView setFrame:CGRectMake(Main_Screen_Width, 0, Main_Screen_Width-mainTableToSecondTableGap-secondTableToThirdTableGap, Main_Screen_Height)];
    [self.view addSubview:self.thirdTableViewcontroller.tableView];
    self.thirdTableViewcontroller.tableView.delegate = self;
}


#pragma mark - is table view out
-(BOOL)isSecondTableViewOut{
    if (!self.secondTableViewController) {
        return NO;
    }
    CGFloat offX = self.secondTableViewController.tableView.frame.origin.x;
    if (offX < Main_Screen_Width) {
        return YES;
    }
   
    return NO;
}

-(BOOL)isThirdTableViewOut{
    if (!self.thirdTableViewcontroller) {
        return NO;
    }
    CGFloat offX = self.thirdTableViewcontroller.tableView.frame.origin.x;
    if (offX < Main_Screen_Width) {
        return YES;
    }
    return NO;
}

#pragma mark - TableView Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.mainTableViewController.tableView) {
        [self slideSecondTableViewOutAtIndexPath:indexPath];
    }
    else if (tableView == self.secondTableViewController.tableView){
        [self slideThirdTableViewOutAtIndexPath:indexPath];
    }else{
        _thirdIndexPath = indexPath;
        [[NSNotificationCenter defaultCenter] postNotificationName:CXLDidClickThirdTableViewCellNotification object:self];
    }
}

#pragma mark - Guesture
-(void)swipToRightGuesture:(UISwipeGestureRecognizer *)swipGuesture{
    if (![self isSecondTableViewOut]) {
        CGPoint point = [swipGuesture locationInView:self.mainTableViewController.tableView];
        NSIndexPath *indexPath = [self.mainTableViewController.tableView indexPathForRowAtPoint:point];
        [self slideSecondTableViewOutAtIndexPath:indexPath];
    }else if([self isSecondTableViewOut] && ![self isThirdTableViewOut]){
        CGPoint point = [swipGuesture locationInView:self.secondTableViewController.tableView];
        NSIndexPath *indexPath = [self.secondTableViewController.tableView indexPathForRowAtPoint:point];
        [self slideThirdTableViewOutAtIndexPath:indexPath];
    }else{
        return;
    }
    
}

-(void)swipToLeftGuesture:(UISwipeGestureRecognizer *)swipGuesture{
    if ([self isSecondTableViewOut] && [self isThirdTableViewOut]) {
        [self slideThirdTableViewIn];
    }else if([self isSecondTableViewOut] && ![self isThirdTableViewOut]){
        [self slideSecondTableViewIn];
    }else{
        return;
    }
}

#pragma mark - Slide TableView In&Out
-(void)slideSecondTableViewOutAtIndexPath:(NSIndexPath *)indexPath{
    
    _mainIndexPath = indexPath;
    [[NSNotificationCenter defaultCenter] postNotificationName:CXLDidClickMainTableViewCellNotification object:self];
    
    [UIView animateWithDuration:0.5 animations:^{
        if (self.secondTableViewController) {
            [self.secondTableViewController.tableView setFrame:CGRectMake(mainTableToSecondTableGap, 0, Main_Screen_Width-mainTableToSecondTableGap, Main_Screen_Height)];
        }
    } completion:^(BOOL finished) {
        if (self.thirdTableViewcontroller) {
            [self.thirdTableViewcontroller.tableView setFrame:CGRectMake(Main_Screen_Width, 0, Main_Screen_Width-mainTableToSecondTableGap-secondTableToThirdTableGap, Main_Screen_Height)];
        }
    }];
}

-(void)slideThirdTableViewOutAtIndexPath:(NSIndexPath *)indexPath{
    _secondIndexPath = indexPath;
    [[NSNotificationCenter defaultCenter] postNotificationName:CXLDidClickSecondTableViewCellNotification object:self];
    
    [UIView animateWithDuration:0.5 animations:^{
        if (self.thirdTableViewcontroller) {
         [self.thirdTableViewcontroller.tableView setFrame:CGRectMake(mainTableToSecondTableGap+secondTableToThirdTableGap, 0, Main_Screen_Width-mainTableToSecondTableGap-secondTableToThirdTableGap, Main_Screen_Height)];
        }
    }];
}

-(void)slideSecondTableViewIn{
  [UIView animateWithDuration:0.5 animations:^{
      if (self.secondTableViewController) {
          [self.secondTableViewController.tableView setFrame:CGRectMake(Main_Screen_Width, 0, Main_Screen_Width-mainTableToSecondTableGap, Main_Screen_Height)];
      }
  }];
}

-(void)slideThirdTableViewIn{
  [UIView animateWithDuration:0.5 animations:^{
      if (self.thirdTableViewcontroller) {
          [self.thirdTableViewcontroller.tableView setFrame:CGRectMake(Main_Screen_Width, 0, Main_Screen_Width-mainTableToSecondTableGap-secondTableToThirdTableGap, Main_Screen_Height)];
      }
  }];
}


#pragma mark - Get IndexPath
+(NSIndexPath *)getMainTableViewIndexPath{
    return _mainIndexPath;
}

+(NSIndexPath *)getSecondTableViewIndexPath{
    return _secondIndexPath;
}

+(NSIndexPath *)getThirdTableViewIndexPath{
    return _thirdIndexPath;
}

#pragma mark - Set TableView Gap
+(void)setMainTableToSecondTableGap:(CGFloat)gap{
    mainTableToSecondTableGap = gap;
}

+(void)setSecondTableToThirdTableGap:(CGFloat)gap{
    secondTableToThirdTableGap = gap;
}

@end
