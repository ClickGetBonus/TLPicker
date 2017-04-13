//
//  TLPicker.m
//
//  Created by Ian on 16/3/28.
//  Copyright © 2016年 Guangzhou Shiny Read Education Technology  Shiny Read Education. All rights reserved.
//

#import "TLPicker.h"
#import "TLUtil.h"
#import "Extracter.h"

static CGFloat const kControlButtonHeight = 25;
static CGFloat const kControlButtonWidth = 50;

static CGFloat const kPickerViewHeight= 250;

static CGFloat const kControlBarHeight = 40;


typedef NS_ENUM(NSInteger, TLPickerType)
{
    TLPickerTypeNormal,
    TLPickerTypeDate
};

typedef NS_ENUM(NSInteger, DataStructure)
{
    DataStructureLinear,
    DataStructureMultiple
};



@interface TLPicker () <UIPickerViewDataSource, UIPickerViewDelegate>


/**
 *  Common Tool
 */
@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, strong) UIView *pickerContentView;

@property (nonatomic, strong) UIView *controlBar;

@property (nonatomic, strong) UIButton *confirmButton;

@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, strong) UIDatePicker *datePicker;

@property (nonatomic, strong) UIPickerView *pickerView;

@property (nonatomic, assign) TLPickerType type;

@property (nonatomic, assign) DataStructure dataStructure;


@property (nonatomic, copy) id sourceData;
@property (nonatomic, copy) NSArray<NSArray< NSString *> *> *pickerData;

/**
 *  User By Multiple Structure
 */
@property (nonatomic, strong) Extracter *inputDataModel;
@property (nonatomic, strong) Extracter *outputDataModel;

@property (nonatomic, assign) NSInteger sectionCount;
@property (nonatomic, copy) NSString *inputKeyPath;
@property (nonatomic, copy) NSString *outputKeyPath;

@property (nonatomic, strong) NSMutableArray *selectedIndexs;

@end


@implementation TLPicker


#pragma mark - Usage
+ (instancetype)pickDateForView:(UIView *)view initialDate:(NSDate *)date selectedBlock:(TLSelectedBlockDate)selectedBlock
{
    
    TLPicker *datePicker = [[TLPicker alloc] initWithFrame:view.bounds type:TLPickerTypeDate];
    [view addSubview:datePicker];
    
    datePicker.initialDate = date ? date : [NSDate date];
    datePicker.selectedBlockDate = selectedBlock;
    datePicker.pickerState = PickerViewStateLoaded;
    
    return datePicker;
}


+ (instancetype)pickLinearData:(NSArray<NSString *> *)data forView:(UIView *)view selectedBlock:(TLSelectedBlockNormal)selectedBlock
{
    
    TLPicker *pickerView = [[TLPicker alloc] initWithFrame:view.bounds type:TLPickerTypeNormal];
    
    [view addSubview:pickerView];
    
    pickerView.selectedBlockNormal = selectedBlock;
    
    pickerView.sourceData = data;
    pickerView.dataStructure = DataStructureLinear;
    [pickerView analysisData:data];
    
    return pickerView;
}

+ (instancetype)pickEntity:(id)entity
              inputKeyPath:(NSString *)inputKeyPath
             outputKeyPath:(NSString *)outputKeyPath
                   forView:(UIView *)view
             selectedBlock:(TLSelectedBlockNormal)selectedBlock
{
    
    TLPicker *pickerView = [[TLPicker alloc] initWithFrame:view.bounds
                                                      type:TLPickerTypeNormal];
    
    [view addSubview:pickerView];
    
    pickerView.selectedBlockNormal = selectedBlock;
    
    pickerView.sourceData = entity;
    pickerView.inputKeyPath = inputKeyPath;
    pickerView.outputKeyPath = outputKeyPath;
    pickerView.dataStructure = DataStructureMultiple;
    pickerView.sectionCount = inputKeyPath.length - [inputKeyPath stringByReplacingOccurrencesOfString:@"." withString:@""].length;
    
    pickerView.inputDataModel = [Extracter parseEntity:entity keyPath:inputKeyPath];
    pickerView.outputDataModel = [Extracter parseEntity:entity keyPath:outputKeyPath];
    
    if (!pickerView.inputDataModel || !pickerView.outputDataModel) {
        DLog(@"TLPicker keyPath 解析失败");
    }
    
    return pickerView;
}

- (void)show:(BOOL)animated
{
    
    if (animated)
    {
        [UIView animateWithDuration:0.5 animations:^{
            self.alpha = 1;
        }];
    }
    else
    {
        self.alpha = 1;
    }
    
    self.pickerState = PickerViewStatePresent;
}

- (void)hide:(BOOL)animated
{
    if (animated)
    {
        
        [UIView animateWithDuration:0.5 animations:^{
            self.alpha = 0;
        }];
    }
    else
    {
        self.alpha = 0;
    }
    
    self.pickerState = PickerViewStateHide;
}

#pragma mark - Initial
- (instancetype)initWithFrame:(CGRect)frame type:(TLPickerType)type
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor clearColor];
        self.alpha = 0;
        _type = type;
        _rowHeight = 44;
        
        [self addSubview:self.backgroundView];
        [self addSubview:self.pickerContentView];
        
        if (type == TLPickerTypeDate)
        {
            [self.pickerContentView addSubview:self.datePicker];
        }
        else if (type == TLPickerTypeNormal)
        {
            [self.pickerContentView addSubview:self.pickerView];
        }
        
        self.pickerState = PickerViewStateInit;
    }
    
    return self;
}


#pragma mark - Input Configure
- (void)analysisData:(id)data
{
    
    if ([[data firstObject] isKindOfClass:[NSString class]]) {
        self.pickerData = @[data];
    }
    else if ([[data firstObject] isKindOfClass:[NSArray class]]) {
        self.pickerData = data;
    } else {
        DLog(@"TLPicker \n 传入参数格式错误");
        self.pickerState = PickerViewStateLoadFail;
    }
}


#pragma mark - Action
- (void)onConfirm
{
    
    if (self.pickerState == PickerViewStateLoadFail) {
        [self hide:YES];
        return;
    }
    
    if (self.type == TLPickerTypeDate)
    {
        
        if (self.selectedBlockDate)
        {
            if (self.selectedBlockDate(NO, self.datePicker.date)) {
                [self hide:YES];
            }
        }
    }
    else
    {
        if (self.selectedBlockNormal)
        {
            
            NSMutableArray *titles = [NSMutableArray array];
            NSMutableArray *indexs = [NSMutableArray array];
            
            switch (self.dataStructure) {
                case DataStructureLinear: {
                    
                    for (int i=0; i<self.pickerData.count; i++)
                    {
                        NSArray *array = self.pickerData[i];
                        
                        NSInteger selectedIndex = [self.pickerView selectedRowInComponent:i];
                        [indexs addObject:@(selectedIndex)];
                        [titles addObject:array[selectedIndex]];
                    }
                    break;
                }
                case DataStructureMultiple: {
                    titles = [[self getOutputArray] mutableCopy];
                    indexs = self.selectedIndexs;
                    break;
                }
            }
            
            if (self.selectedBlockNormal(NO, titles, indexs)) {
                [self hide:YES];
            }
        }
    }
    
}

- (void)onCancel
{
    [self hide:YES];
    
    if (self.pickerState == PickerViewStateLoadFail) {
        return;
    }
    
    if (self.type == TLPickerTypeDate)
    {
        if (self.selectedBlockDate)
        {
            self.selectedBlockDate(YES, nil);
        }
    }
    else
    {
        if (self.selectedBlockNormal)
        {
            self.selectedBlockNormal(YES, nil, nil);
        }
    }
}

- (void)onTapBackground
{
    [self hide:YES];
}


#pragma mark - Getter
- (UIView *)backgroundView
{
    if (_backgroundView == nil)
    {
        _backgroundView = [[UIView alloc] initWithFrame:self.frame];
        _backgroundView.backgroundColor = [UIColor blackColor];
        _backgroundView.alpha = 0.6;
        //        _backgroundView.backgroundColor = [UIColor clearColor];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(onTapBackground)];
        [_backgroundView addGestureRecognizer:tap];
        
    }
    
    return _backgroundView;
}


- (UIView *)pickerContentView
{
    if (_pickerContentView == nil)
    {
        _pickerContentView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                      CGRectGetHeight(self.bounds)-kPickerViewHeight,
                                                                      CGRectGetWidth(self.bounds),
                                                                      kPickerViewHeight)];
        [_pickerContentView setBackgroundColor:[UIColor whiteColor]];
        
        [_pickerContentView addSubview:self.controlBar];
    }
    
    return _pickerContentView;
}

- (UIView *)controlBar
{
    if (_controlBar == nil)
    {
        _controlBar = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                               0,
                                                               CGRectGetWidth(self.bounds),
                                                               kControlBarHeight)];
        [_controlBar setBackgroundColor:UIColorFromRGB(0xf2f2f2)];
        
        [_controlBar addSubview:self.confirmButton];
        [_controlBar addSubview:self.cancelButton];
    }
    
    return _controlBar;
}


- (UIButton *)confirmButton
{
    if (_confirmButton == nil)
    {
        _confirmButton = [[UIButton alloc] initWithFrame:
                          CGRectMake(CGRectGetWidth(self.controlBar.bounds)-kControlButtonWidth - 8,
                                     (kControlBarHeight - kControlButtonHeight)/2,
                                     kControlButtonWidth,
                                     kControlButtonHeight)];
        _confirmButton.titleLabel.font = [UIFont systemFontOfSize:16.0f];
        [_confirmButton setTitle:@"确定"
                        forState:UIControlStateNormal];
        [_confirmButton setTitleColor:UIColorFromRGB(0x22b2e1)
                             forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[UIColor lightGrayColor]
                             forState:UIControlStateHighlighted];
        [_confirmButton addTarget:self
                           action:@selector(onConfirm)
                 forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    return _confirmButton;
}


- (UIButton *)cancelButton
{
    
    if (_cancelButton == nil)
    {
        _cancelButton = [[UIButton alloc] initWithFrame:
                         CGRectMake(8,
                                    (kControlBarHeight - kControlButtonHeight) /2,
                                    kControlButtonWidth,
                                    kControlButtonHeight)];
        
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:16.0f];
        [_cancelButton setTitle:@"取消"
                       forState:UIControlStateNormal];
        [_cancelButton setTitleColor:UIColorFromRGB(0x22b2e1)
                            forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor lightGrayColor]
                            forState:UIControlStateHighlighted];
        [_cancelButton addTarget:self
                          action:@selector(onCancel)
                forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _cancelButton;
}


- (UIDatePicker *)datePicker
{
    if (_datePicker == nil)
    {
        
        _datePicker = [[UIDatePicker alloc] initWithFrame:
                       CGRectMake(0,
                                  kControlBarHeight,
                                  CGRectGetWidth(self.pickerContentView.bounds),
                                  CGRectGetHeight(self.pickerContentView.bounds) - kControlBarHeight)];
        _datePicker.datePickerMode = UIDatePickerModeDate;
        [_datePicker setDate:[NSDate date]];
    }
    
    return _datePicker;
}

- (UIPickerView *)pickerView
{
    if (_pickerView == nil)
    {
        _pickerView = [[UIPickerView alloc] initWithFrame:
                       CGRectMake(0,
                                  kControlBarHeight,
                                  CGRectGetWidth(self.pickerContentView.bounds),
                                  CGRectGetHeight(self.pickerContentView.bounds) - kControlBarHeight)];
        _pickerView.delegate = self;
        _pickerView.dataSource = self;
    }
    
    return _pickerView;
}

- (Extracter *)getExtracterModelByHierarchy:(NSUInteger)hierarchy rootModel:(Extracter *)rootModel {
    
    Extracter *tempModel = rootModel;
    for (int i=0; i<hierarchy; i++) {
        
        NSArray *array = tempModel.subExts;
        NSInteger selectedIndex = [self.selectedIndexs[i] integerValue];
        tempModel = array[selectedIndex];
    }
    
    return tempModel;
}


- (NSArray *)getOutputArray {
    
    NSMutableArray *outputArray = [NSMutableArray array];
    
    Extracter *model = self.outputDataModel;
    for (int i=0; i<self.selectedIndexs.count; i++) {
        
        NSInteger selectedIndex = [self.selectedIndexs[i] integerValue];
        
        model = model.subExts[selectedIndex];
        NSString *name = model.value;
        [outputArray addObject:name];
    }
    
    return outputArray;
}


#pragma mark - Setter
- (void)setInitialDate:(NSDate *)initialDate
{
    
    if (self.datePicker != nil)
    {
        [self.datePicker setDate:initialDate];
    }
}

- (void)setRowHeight:(CGFloat)rowHeight
{
    
    _rowHeight = rowHeight;
    
    [self.pickerView reloadAllComponents];
}

- (void)setDatePickerMode:(UIDatePickerMode)datePickerMode
{
    [self.datePicker setDatePickerMode:datePickerMode];
}

- (void)selectRow:(NSInteger)row inComponent:(NSInteger)component animation:(BOOL)animation {
    switch (self.dataStructure) {
        case DataStructureLinear: {
            [self.pickerView selectRow:row inComponent:component animated:animation];
        }
            break;
        case DataStructureMultiple: {
            if (component>=self.selectedIndexs.count) {
                return;
            }
            
            //更改选择时需要维护selectedIndexs并解决越界问题
            Extracter *model = [self getExtracterModelByHierarchy:component rootModel:self.inputDataModel];
            
            NSInteger index = row;
            if (index > model.subExts.count-1) {
                index = 0;
                DLog(@"TLPicker 选择row:%d, component:%d 时发生越界", row, component);
            }
            
            self.selectedIndexs[component] = @(index);
            
            for (int i=component+1; i<self.selectedIndexs.count; i++) {
                self.selectedIndexs[i] = @0;
                [self.pickerView reloadComponent:i];
            }
            [self.pickerView selectRow:index inComponent:component animated:animation];
        }
            break;
    }
}

- (void)selectIndexs:(NSArray<NSNumber *> *)indexs animation:(BOOL)animation {
    
    for (int i=0; i<indexs.count; i++) {
        [self selectRow:[indexs[i] integerValue] inComponent:i animation:animation];
    }
}

- (void)setSectionCount:(NSInteger)sectionCount {
    if (_sectionCount != sectionCount) {
        self.selectedIndexs = [NSMutableArray arrayWithCapacity: sectionCount];
        for (int i=0; i<sectionCount; i++) {
            [self.selectedIndexs addObject:@(0)];
        }
        
        _sectionCount = sectionCount;
    }
}

- (void)selectValue:(NSString *)value inComponent:(NSInteger)component animation:(BOOL)animation {
    if (self.dataStructure == DataStructureLinear) {
        
        if (component > self.pickerData.count) {
            return;
        }
        
        NSArray *array = self.pickerData[component];
        for (int i=0; i<array.count; i++) {
            
            if ([array[i] isEqualToString:value]) {
                [self selectRow:i inComponent:component animation:animation];
            }
        }
    } else {
        Extracter *ext = [self getExtracterModelByHierarchy:component rootModel:self.inputDataModel];
        for (int i=0; i<ext.subExts.count; i++) {
            Extracter *subExt = ext.subExts[i];
            if ([subExt.value isEqualToString:value]) {
                [self selectRow:i inComponent:component animation:animation];
                return;
            }
        }
        
        ext = [self getExtracterModelByHierarchy:component rootModel:self.outputDataModel];
        for (int i=0; i<ext.subExts.count; i++) {
            Extracter *subExt = ext.subExts[i];
            if ([subExt.value isEqualToString:value]) {
                [self selectRow:i inComponent:component animation:animation];
                return;
            }
        }
    }
}

- (void)selectValues:(NSArray <NSString *> *)values animation:(BOOL)animation {
    for (int i=0; i<values.count; i++) {
        [self selectValue:values[i] inComponent:i animation:animation];
    }
}


#pragma mark - PickerView Delegate
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    
    switch (self.dataStructure) {
        case DataStructureLinear: {
            NSArray *dataArray = _pickerData[component];
            return dataArray.count;
        }
        case DataStructureMultiple: {
            Extracter *model = [self getExtracterModelByHierarchy:component rootModel:self.inputDataModel];
            return model.subExts.count;
        }
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    
    switch (self.dataStructure) {
        case DataStructureLinear: {
            return ((NSArray *)_pickerData).count;
            break;
        }
        case DataStructureMultiple: {
            return self.sectionCount;
            break;
        }
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return self.rowHeight;
}


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    switch (self.dataStructure) {
        case DataStructureLinear: {
            return _pickerData[component][row];
        }
        case DataStructureMultiple: {
            Extracter *model = [self getExtracterModelByHierarchy:component
                                                        rootModel:self.inputDataModel];
            return model.subExts[row].value;
        }
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (self.dataStructure == DataStructureMultiple)
    {
        [self.selectedIndexs setObject:@(row) atIndexedSubscript:component];
        
        for (NSInteger i=component+1; i<self.sectionCount; i++) {
            [self.selectedIndexs setObject:@(0) atIndexedSubscript:i];
            [pickerView reloadComponent:i];
            [pickerView selectRow:0 inComponent:i animated:YES];
        }
    }
}


@end
