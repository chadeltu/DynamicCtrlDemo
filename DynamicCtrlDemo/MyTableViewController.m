//
//  MyTableViewController.m
//  DynamicCtrlDemo
//
//  Created by Product Innovation on 15/1/19.
//  Copyright (c) 2015年 chadeltu. All rights reserved.
//

#import "MyTableViewController.h"

#define fPNPadding 6.0

@interface MyTableViewController ()
{
    // 键盘隐藏工具栏
    UIToolbar *keyboardHideView;
    // 保存输入框内容，输入框个数>=1
    NSMutableArray *arrContent;
}
@end

@implementation MyTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initParam];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// 初始化
- (void)initParam
{
    self.title = @"DynamicCtrlDemo";
    [self.tableView setBackgroundColor:[UIColor grayColor]];
    
    // 键盘隐藏工具栏
    keyboardHideView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 36)];
    [keyboardHideView setBarStyle:UIBarStyleBlack];
    UIBarButtonItem * hideButton = [[UIBarButtonItem alloc]initWithTitle:@"Hide" style:UIBarButtonItemStyleBordered target:self action:@selector(hideKeyboard)];
    UIBarButtonItem * btnSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(hideKeyboard)];
    NSArray * buttonsArray = [NSArray arrayWithObjects:hideButton,btnSpace,doneButton,nil];
    [keyboardHideView setItems:buttonsArray];
    
    arrContent = [[NSMutableArray alloc] init];
    // 添加第一个输入框对应文字内容，初始状态为空
    [arrContent addObject:@""];
}

// 隐藏键盘
- (void)hideKeyboard
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

// 保存用户所输内容
- (void)dataBackup
{
    NSArray *visibleCells = [self.tableView visibleCells];
    for (UITableViewCell *cell in visibleCells)
    {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        NSInteger iRow = [indexPath row];
        
        UITextView *tvContent = (UITextView *)[cell.contentView viewWithTag:ctrl_tv_text];
        [arrContent replaceObjectAtIndex:iRow withObject:tvContent.text];
    }
}

// 添加一组控件
- (void)addContent:(UIButton *)btn event:(id)event
{
    // 获取事件发生位置，哪一条list item
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:currentTouchPosition];
    int row = (int)indexPath.row;
    
    // 事发位置下面插入一组控件（内容为空）
    [arrContent insertObject:@"" atIndex:(row + 1)];
    
    [self.tableView reloadData];
}

// 删除一组控件
- (void)delContent:(UIButton *)btn event:(id)event
{
    // 多于1条记录才可以有删除操作
    if (arrContent.count > 1) {
        // 获取事件发生位置，哪一条list item
        NSSet *touches = [event allTouches];
        UITouch *touch = [touches anyObject];
        CGPoint currentTouchPosition = [touch locationInView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:currentTouchPosition];
        int row = (int)indexPath.row;
        
        [arrContent removeObjectAtIndex:row];
        
        [self.tableView reloadData];
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrContent.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MyTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        [cell setBackgroundColor:[UIColor greenColor]];
        
        float fHei = fPNPadding;
        
        // 输入框
        UITextView *tvContent = [[UITextView alloc] initWithFrame:CGRectMake(fPNPadding, fHei, self.view.frame.size.width - 2 * fPNPadding, 90.0f)];
        tvContent.tag = ctrl_tv_text;
        tvContent.delegate = self;
        tvContent.textColor = [UIColor blackColor];
        tvContent.backgroundColor = [UIColor whiteColor];
        tvContent.font = [UIFont systemFontOfSize:15.0];
        tvContent.returnKeyType = UIReturnKeyDefault;
        tvContent.scrollEnabled = YES;
        tvContent.layer.borderWidth = 1;
        tvContent.layer.cornerRadius = 4;
        tvContent.layer.borderColor = [[UIColor blackColor] CGColor];
        [cell.contentView addSubview:tvContent];
        [tvContent setInputAccessoryView:keyboardHideView];
        fHei += 90.0 + fPNPadding;
        
        // 删除按钮
        UIButton *btnDel = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 2 * (48 + fPNPadding), fHei, 48, 48)];
        btnDel.tag = ctrl_btn_del;
        [btnDel setBackgroundImage:[UIImage imageNamed:@"icon_content_delete.png"] forState:UIControlStateNormal];
        [btnDel addTarget:self action:@selector(delContent:event:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:btnDel];
        
        // 添加按钮
        UIButton *btnAdd = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 48 - fPNPadding, fHei, 48, 48)];
        btnAdd.tag = ctrl_btn_add;
        [btnAdd setBackgroundImage:[UIImage imageNamed:@"icon_content_add.png"] forState:UIControlStateNormal];
        [btnAdd addTarget:self action:@selector(addContent:event:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:btnAdd];
        fHei += 48 + fPNPadding;
    }
    
    UIButton *btnDel = (UIButton *)[cell.contentView viewWithTag:ctrl_btn_del];
    UITextView *tvContent = (UITextView *)[cell.contentView viewWithTag:ctrl_tv_text];
    
    NSInteger iRow = [indexPath row];
    tvContent.text = [arrContent objectAtIndex:iRow];
    
    if (arrContent.count == 1) {
        btnDel.hidden = YES;
    } else {
        btnDel.hidden = NO;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90 + 48 + 4 * fPNPadding;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - UITextViewDelegate
// 响应输入完成消息，保存用户所输入内容
- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self dataBackup];
}

@end
