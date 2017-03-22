//
//  ViewController.m
//  TLPickerDemo
//
//  Created by Lan on 17/3/16.
//  Copyright © 2017年 TL. All rights reserved.
//

#import "ViewController.h"
#import "TLPicker.h"

@interface ViewController ()
<
UITableViewDelegate,
UITableViewDataSource
>


@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *titleArray;
@property (strong, nonatomic) NSArray *methodArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.titleArray = @[@"日期", @"单列数据", @"多列数据", @"多级联动"];
}


#pragma mark - TLPicker Usage
- (void)pickDate {
    TLPicker *picker = [TLPicker pickDateForView:self.view initialDate:[NSDate date] selectedBlock:^BOOL(BOOL isCancel, NSDate *date) {
        
        if (isCancel) {
            return YES;
        }
        
        NSLog(@"选择的日期是: %@", date);
        return YES;
    }];
    [picker show:YES];
}

- (void)pickSingleComponentData {
    
    NSArray *data = @[@"男", @"女"];
    [[TLPicker pickLinearData:data
                      forView:self.view selectedBlock:^BOOL(BOOL isCancel, NSArray<NSString *> *selectedTitles, NSArray<NSNumber *> *indexs) {
                          if (isCancel) {
                              return YES;
                          }
                          
                          NSLog(@"选择的性别是: %@", selectedTitles[0]);
                          //NSLog(@"选择的性别是: %@", data[[indexs[0] integerValue]]);
                          return YES;
                      }] show:YES];
}

- (void)pickMultipleComponentData {
    NSArray *data = @[@[@"性别", @"男", @"女", @"其他"],
                      @[@"血型", @"A", @"B", @"AB", @"O"],
                      @[@"婚姻状况", @"单身狗", @"恩爱狗", @"晒娃狂魔"]
                      ];
    TLPicker *picker = [TLPicker pickLinearData:data
                      forView:self.view selectedBlock:^BOOL(BOOL isCancel, NSArray<NSString *> *selectedTitles, NSArray<NSNumber *> *indexs) {
                          if (isCancel) {
                              return YES;
                          }
                          
                          for (int i=0; i<indexs.count; i++) {
                              if ([indexs[i] integerValue] == 0) {
                                  NSLog(@"请选择%@", selectedTitles[i]);
                                  return NO;
                              }
                          }
                          
                          
                          for (int i=0; i<data.count; i++) {
                              NSInteger index = [indexs[i] integerValue];
                              NSLog(@"选择的%@是: %@", data[i][0], data[i][index]);
                          }
                          return YES;
                          
                      }];
    [picker selectValues:@[@"男", @"A"] animation:YES];
    [picker show:YES];
}

- (void)pickEntity {
    
    //entity可以是Dictionary, Array或实体类
    NSDictionary *entity = @{@"provinces": @[@{@"id": @1,
                                               @"name": @"广东",
                                               @"cities" : @[@{@"id": @11,
                                                               @"name": @"广州",
                                                               @"areas": @[@{@"id": @101,
                                                                             @"name": @"越秀区"
                                                                             },
                                                                           @{@"id": @102,
                                                                             @"name": @"天河区"
                                                                             },
                                                                           @{@"id": @103,
                                                                             @"name": @"海珠区"
                                                                             }
                                                                           ]
                                                               },
                                                             @{@"id": @12,
                                                               @"name": @"深圳",
                                                               @"areas": @[@{@"id": @201,
                                                                             @"name": @"罗湖区"
                                                                             },
                                                                           @{@"id": @202,
                                                                             @"name": @"福田区"}
                                                                           ]
                                                               },
                                                             @{@"id": @13,
                                                               @"name": @"清远",
                                                               @"areas": @[@{@"id": @301,
                                                                             @"name": @"连州市"
                                                                             },
                                                                           @{@"id": @302,
                                                                             @"name": @"清城区"
                                                                             },
                                                                           @{@"id": @303,
                                                                             @"name": @"连南瑶族自治县"
                                                                             }
                                                                           ]
                                                               }
                                                             ]
                                               }
                                             ]};
    
    TLPicker *picker = [TLPicker pickEntity:entity
                               inputKeyPath:@"->provinces.name->cities.name->areas.name"
                              outputKeyPath:@"->provinces.id->cities.name->areas.id"
                                    forView:self.view
                              selectedBlock:^BOOL(BOOL isCancel, NSArray<NSString *> *results, NSArray<NSNumber *> *indexs) {
                                  if (isCancel) {
                                      return YES;
                                  }
                                  
                                  NSLog(@"选择的结果输出为: %@", results);
                                  
                                  return YES;
                              }];
    [picker selectIndexs:@[@0, @1, @2] animation:YES];
//    [picker selectValues:@[@"广东", @"深圳", @"福田区"] animation:YES];
    [picker show:YES];
    
}


#pragma mark - UITableView Delegate & DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"identifier";
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:identifier];
    }
    cell.textLabel.text = self.titleArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0:
            [self pickDate];
            break;
        case 1:
            [self pickSingleComponentData];
            break;
        case 2:
            [self pickMultipleComponentData];
            break;
        case 3:
            [self pickEntity];
            break;
        default:
            break;
    }
}



@end
