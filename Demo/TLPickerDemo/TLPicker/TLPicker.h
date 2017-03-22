//
//  TLPicker.h
//
//  Created by Ian on 16/3/28.
//  Copyright © 2016年 Guangzhou Shiny Read Education Technology  Shiny Read Education. All rights reserved.
//

#import <UIKit/UIKit.h>


//dataPicker的回调
typedef BOOL(^TLSelectedBlockDate)(BOOL isCancel, NSDate *date);

/*
 * dataPicker的回调
 * @param isCancel 是不是取消按钮
 * @param results 返回的结果组成的数组
 * @param indexs  各组件所选择元素的下标组成的数组
 * 返回值BOOL 是否隐藏PickerView
 */
typedef BOOL(^TLSelectedBlockNormal)(BOOL isCancel, NSArray<NSString *> *results, NSArray<NSNumber *> *indexs);


typedef NS_ENUM(NSInteger, PickerViewState) {
    PickerViewStateInit = 0,
    PickerViewStateLoadFail = 1,
    PickerViewStateLoaded = 2,
    PickerViewStatePresent = 3,
    PickerViewStateHide = 4
};

@interface TLPicker : UIView

/*
 Common
 */
@property (nonatomic, assign) PickerViewState pickerState;
@property (assign, nonatomic) CGFloat rowHeight;

/*
 * DataPicker
 */
@property (nonatomic, copy) TLSelectedBlockNormal selectedBlockNormal;


/*
 * DatePicker
 */
@property (assign, nonatomic) UIDatePickerMode datePickerMode;
@property (nonatomic, copy) TLSelectedBlockDate selectedBlockDate;



+ (instancetype)pickDateForView:(UIView *)view initialDate:(NSDate *)date selectedBlock:(TLSelectedBlockDate)selectedBlock;

/**
 *  用于线性的数据结构,data支持种数据结构:NSArray<NSString>,NSArray<NSArray<NSString>>
 */
+ (instancetype)pickLinearData:(NSArray<NSString *> *)data forView:(UIView *)view selectedBlock:(TLSelectedBlockNormal)selectedBlock;


/**
 *  需要多级联动时使用, 作用于多重嵌套的数据结构,通过keyPath提取出需要展示和返回的value
 *
 *  @param entity         支持NSArray, NSDictionary等继承于NSObject的类
 *  @param inputKeyPath   输入路径, 根据该路径取出的值用于作为各组件的标题
 *  @param outputKeyPath  输出路径, 根据该路径取出的值用于用户选择后返回给responder
 *  keyPath指令: "->"代表往下解析, "."代表取出当前数组元素的某个值作为目标, "."的个数代表pickerView组件的个数
 *  example: @"->provices.name->cities.name"
 */
+ (instancetype)pickEntity:(id)entity
              inputKeyPath:(NSString *)inputKeyPath
             outputKeyPath:(NSString *)outputKeyPath
                   forView:(UIView *)view
             selectedBlock:(TLSelectedBlockNormal)selectedBlock;



- (void)show:(BOOL)animated;

- (void)hide:(BOOL)animated;


- (UIPickerView *)pickerView;

- (UIDatePicker *)datePicker;

//用下标来改变pickerView的当前选择(越界时选择0)
- (void)selectRow:(NSInteger)row inComponent:(NSInteger)component animation:(BOOL)animation;
- (void)selectIndexs:(NSArray<NSNumber *> *)indexs animation:(BOOL)animation;

//用特定的值来改变pickerView的当前选择
- (void)selectValue:(NSString *)value inComponent:(NSInteger)component animation:(BOOL)animation;
- (void)selectValues:(NSArray <NSString *> *)values animation:(BOOL)animation;



@end
