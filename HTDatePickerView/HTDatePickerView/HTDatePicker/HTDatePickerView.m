//
//  HTDatePickerView.m
//  HTDatePickerView
//
//  Created by HT on 2017/12/6.
//  Copyright © 2017年 HT. All rights reserved.
//

#import "HTDatePickerView.h"

#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height

#define SELFWIDTH self.frame.size.width
#define SELFHEIGHT self.frame.size.height

#define MAXYEAR 2051
#define MINYEAR 1970
#define D_MINUTE 60
#define D_HOUR 3600
#define D_DAY 86400
#define D_WEEK 604800
#define D_YEAR 31556926

@interface HTDatePickerView()<UIPickerViewDelegate, UIPickerViewDataSource>
{
    //日期存储数组
    NSMutableArray *_yearArray;
    NSMutableArray *_monthArray;
    NSMutableArray *_dayArray;
    NSMutableArray *_hourArray;
    NSMutableArray *_minuteArray;
    NSMutableArray *_secondArray;
    
    //记录日期位置
    NSInteger yearIndex;
    NSInteger monthIndex;
    NSInteger dayIndex;
    NSInteger hourIndex;
    NSInteger minuteIndex;
    NSInteger secondIndex;
    
    //记录选择日期
    NSDate *_startDate;
    NSString *_returnDateStr;
}
@property(nonatomic, strong)UIPickerView *datePickerView;
@property(nonatomic, strong)UIButton *cancelButton;
@property(nonatomic, strong)UIButton *ensureButton;
@property(nonatomic, strong)UIView *alphaView;

@property (nonatomic, copy)NSString *dateFormatter;//设置日期格式
@property (nonatomic, retain)NSDate *scrollToDate;//滚到指定日期

@end


@implementation HTDatePickerView

#pragma mark init方法
//- (instancetype)initWithFrame:(CGRect)frame{
//    self = [super initWithFrame:frame];
//    if (self) {
//        [self creatView];
//    }
//    return self;
//}

- (instancetype)initHtDatePickerViewWithFrame:(CGRect)frame style:(HTDatePickerStyle)style{
    self = [super initWithFrame:frame];
    if (self) {
        self.pickerStyle = style;
        self.isCanSelectCurrentTimeBefore = NO;
        [self configData];
        [self creatView];
        
    }
    return self;
}

#pragma mark 类方法
+ (instancetype)htDatePickerViewWithFrame:(CGRect)frame style:(HTDatePickerStyle)style{
    HTDatePickerView *datePickerView = [[self alloc] initHtDatePickerViewWithFrame:frame style:style];
    return datePickerView;
}

#pragma mark set方法

- (void)setPickerStyle:(HTDatePickerStyle)pickerStyle{
    _pickerStyle = pickerStyle;
}

- (void)setCancelBtnColor:(UIColor *)cancelBtnColor{
    _cancelBtnColor = cancelBtnColor;
    [self.cancelButton setTitleColor:_cancelBtnColor forState:0];
}

- (void)setEnsureBtnColor:(UIColor *)ensureBtnColor{
    _ensureBtnColor = ensureBtnColor;
    [self.ensureButton setTitleColor:_ensureBtnColor forState:0];
}

- (void)setButtonTitleFont:(UIFont *)buttonTitleFont{
    _buttonTitleFont = buttonTitleFont;
    self.ensureButton.titleLabel.font = _buttonTitleFont;
    self.cancelButton.titleLabel.font = _buttonTitleFont;
}

- (void)setIsShowButtonBorder:(BOOL)isShowButtonBorder{
    _isShowButtonBorder = isShowButtonBorder;
    if (_isShowButtonBorder == NO) {
        self.cancelButton.layer.borderWidth = 0;
        self.cancelButton.layer.borderColor = [UIColor clearColor].CGColor;
        self.cancelButton.layer.cornerRadius = 0;
        
        self.ensureButton.layer.borderWidth = 0;
        self.ensureButton.layer.borderColor = [UIColor clearColor].CGColor;
        self.ensureButton.layer.cornerRadius = 0;
    }
}

- (void)setButtonBorderColor:(UIColor *)buttonBorderColor{
    _buttonBorderColor = buttonBorderColor;
    self.cancelButton.layer.borderColor = _buttonBorderColor.CGColor;
    self.ensureButton.layer.borderColor = _buttonBorderColor.CGColor;
}

- (void)setIsCanSelectCurrentTimeBefore:(BOOL)isCanSelectCurrentTimeBefore{
    
    _isCanSelectCurrentTimeBefore = isCanSelectCurrentTimeBefore;
}

/**
 *
 * *   构建视图   *
 *
 */
- (void)creatView{
//    self.userInteractionEnabled = YES;
    self.alphaView.frame = CGRectMake(0, -(SCREENHEIGHT - SELFHEIGHT), SCREENWIDTH, SCREENHEIGHT - SELFHEIGHT);
    self.cancelButton.frame = CGRectMake(20, 5, SELFWIDTH / 5, 30);
    self.ensureButton.frame = CGRectMake(SELFWIDTH * 4 / 5 - 20, 5, SELFWIDTH / 5, 30);
    self.datePickerView.frame = CGRectMake(0, 44 , SELFWIDTH, SELFHEIGHT - 44);
    [self addSubview:self.cancelButton];
    [self addSubview:self.ensureButton];
    [self addSubview:self.datePickerView];
}
/**
 *
 * *   加载数据   *
 *
 */
-(void)configData {
    if (!_scrollToDate) {
        _scrollToDate = [NSDate date];
    }
    
    //设置年月日时分数据
    _yearArray = [self setArray:_yearArray];
    _monthArray = [self setArray:_monthArray];
    _dayArray = [self setArray:_dayArray];
    _hourArray = [self setArray:_hourArray];
    _minuteArray = [self setArray:_minuteArray];
    _secondArray = [self setArray:_secondArray];
    
    for (int i=0; i<24; i++) {
        NSString *num = [NSString stringWithFormat:@"%02d",i];
        if (0<i && i<=12)
            [_monthArray addObject:num];
        if (i<24)
            [_hourArray addObject:num];
        
    }
    
    for (int i = 0; i < 60; i ++) {
        NSString *num = [NSString stringWithFormat:@"%02d",i];
        [_minuteArray addObject:num];
        [_secondArray addObject:num];
    }
    
    for (NSInteger i=MINYEAR; i<MAXYEAR; i++) {
        NSString *num = [NSString stringWithFormat:@"%ld",(long)i];
        [_yearArray addObject:num];
    }
    
}

- (NSMutableArray *)setArray:(id)mutableArray
{
    if (mutableArray)
        [mutableArray removeAllObjects];
    else
        mutableArray = [NSMutableArray array];
    return mutableArray;
}

#pragma mark 懒加载控件
- (UIPickerView *)datePickerView{
    if (_datePickerView == nil) {
        _datePickerView = [[UIPickerView alloc] init];
        _datePickerView.layer.borderWidth = 1.5;
        _datePickerView.layer.borderColor = [UIColor colorWithRed:232.0 / 255.0 green:232.0 / 255.0 blue:232.0 / 255.0 alpha:1.0].CGColor;
        _datePickerView.delegate = self;
        _datePickerView.dataSource = self;
    }
    return _datePickerView;
}

- (UIButton *)cancelButton{
    if (_cancelButton == nil) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setTitle:@"取消" forState:0];
        [_cancelButton setTitleColor:[UIColor blackColor] forState:0];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
        _cancelButton.layer.borderWidth = 1;
        _cancelButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _cancelButton.layer.cornerRadius = 5;
        [_cancelButton addTarget:self action:@selector(clickCancelBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UIButton *)ensureButton{
    if (_ensureButton == nil) {
        _ensureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_ensureButton setTitle:@"确定" forState:0];
        [_ensureButton setTitleColor:[UIColor blackColor] forState:0];
        _ensureButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
        _ensureButton.layer.borderWidth = 1;
        _ensureButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _ensureButton.layer.cornerRadius = 5;
        [_ensureButton addTarget:self action:@selector(clickEnsureBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _ensureButton;
}

- (UIView *)alphaView{
    if (_alphaView == nil) {
        _alphaView = [[UIView alloc] init];
        _alphaView.alpha = 0;
        _alphaView.backgroundColor = [UIColor blackColor];
    }
    return _alphaView;
}








#pragma mark UIPickerViewDelegate UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    switch (_pickerStyle) {
        case HTDatePickerStyle_Y:{
            return 1;
        }
            break;
        case HTDatePickerStyle_YM:{
            return 2;
        }
            break;
        case HTDatePickerStyle_YMD:{
            return 3;
        }
            break;
        case HTDatePickerStyle_YMDh:{
            return 4;
        }
            break;
        case HTDatePickerStyle_YMDhm:{
            return 5;
        }
        default:{
            return 6;
        }
            break;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    switch (component) {
        case 0:
            return _yearArray.count;
            break;
        case 1:
            return _monthArray.count;
            break;
        case 2:
            return _dayArray.count;
            break;
        case 3:
            return _hourArray.count;
            break;
        case 4:
            return _minuteArray.count;
            break;
        default:
            return _secondArray.count;
            break;
    }
}

//- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
////    return @"2017";
//}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 44.0;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    switch (_pickerStyle) {
        case HTDatePickerStyle_Y:{
            return SELFWIDTH / 2;
        }
            break;
        case HTDatePickerStyle_YM:{
            return SELFWIDTH / 3;
        }
            break;
        case HTDatePickerStyle_YMD:{
            return SELFWIDTH / 4;
        }
            break;
        case HTDatePickerStyle_YMDh:{
            return SELFWIDTH / 5;
        }
            break;
        case HTDatePickerStyle_YMDhm:{
            return SELFWIDTH / 6;
        }
        default:{
            return SELFWIDTH / 7;
        }
            break;
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel *customLabel = (UILabel *)view;
    if (!customLabel) {
        customLabel = [[UILabel alloc] init];
        customLabel.textAlignment = NSTextAlignmentCenter;
        [customLabel setFont:[UIFont systemFontOfSize:15]];
    }
    NSString *title;
    if (component==0) {
        title = [NSString stringWithFormat:@"%@年", _yearArray[row]];
    }
    if (component==1) {
        title = [NSString stringWithFormat:@"%@月", _monthArray[row]];
    }
    if (component==2) {
        title = [NSString stringWithFormat:@"%@日", _dayArray[row]];
    }
    if (component==3) {
        title = [NSString stringWithFormat:@"%@时", _hourArray[row]];
    }
    if (component==4) {
        title = [NSString stringWithFormat:@"%@分", _minuteArray[row]];
    }
    if (component==5) {
        title = [NSString stringWithFormat:@"%@秒", _secondArray[row]];
    }
    customLabel.text = title;
    customLabel.textColor = [UIColor blackColor];
    
    return customLabel;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSDate *date = [NSDate date];
    if (_isCanSelectCurrentTimeBefore) {   //如果能选择当天之前的时间
        switch (component) {
            case 0:
                yearIndex = row;
                break;
            case 1:
                monthIndex = row;
                break;
            case 2:
                dayIndex = row;
                break;
            case 3:
                hourIndex = row;
                break;
            case 4:
                minuteIndex = row;
                break;
            default:
                secondIndex = row;
                break;
        }
    }else{    //如果不能选择当天之前的时间
        if (component == 0) {
            if (![self isLaterThanCurrentTimeWithYear:_yearArray[row] mouth:_monthArray[monthIndex] day:_dayArray[dayIndex] hour:_hourArray[hourIndex] minute:_minuteArray[minuteIndex] second:_secondArray[secondIndex]]) {
                [self getNowDate:nil animated:YES];
                _startDate = date;
                return;
            }
            yearIndex = row;
        }
        if (component == 1) {
            
            if (![self isLaterThanCurrentTimeWithYear:_yearArray[yearIndex] mouth:_monthArray[row] day:_dayArray[dayIndex] hour:_hourArray[hourIndex] minute:_minuteArray[minuteIndex] second:_secondArray[secondIndex]]) {
                [self getNowDate:nil animated:YES];
                _startDate = date;
                return;
            }
            monthIndex = row;
        }
        if (component == 2) {
            if (![self isLaterThanCurrentTimeWithYear:_yearArray[yearIndex] mouth:_monthArray[monthIndex] day:_dayArray[row] hour:_hourArray[hourIndex] minute:_minuteArray[minuteIndex] second:_secondArray[secondIndex]]) {
                [self getNowDate:nil animated:YES];
                _startDate = date;
                return;
            }
            dayIndex = row;
        }
        if (component == 3) {
            if (![self isLaterThanCurrentTimeWithYear:_yearArray[yearIndex] mouth:_monthArray[monthIndex] day:_dayArray[dayIndex] hour:_hourArray[row] minute:_minuteArray[minuteIndex] second:_secondArray[secondIndex]]) {
                [self getNowDate:nil animated:YES];
                _startDate = date;
                return;
            }
            hourIndex = row;
        }
        if (component == 4) {
            if (![self isLaterThanCurrentTimeWithYear:_yearArray[yearIndex] mouth:_monthArray[monthIndex] day:_dayArray[dayIndex] hour:_hourArray[hourIndex] minute:_minuteArray[row] second:_secondArray[secondIndex]]) {
                [self getNowDate:nil animated:YES];
                _startDate = date;
                return;
            }
            minuteIndex = row;
        }
        if (component == 5) {
            if (![self isLaterThanCurrentTimeWithYear:_yearArray[yearIndex] mouth:_monthArray[monthIndex] day:_dayArray[dayIndex] hour:_hourArray[hourIndex] minute:_minuteArray[minuteIndex] second:_secondArray[row]]) {
                [self getNowDate:nil animated:YES];
                _startDate = date;
                return;
            }
            secondIndex = row;
        }
    }
    
    if (component == 0 || component == 1){
        [self DaysfromYear:[_yearArray[yearIndex] integerValue] andMonth:[_monthArray[monthIndex] integerValue]];
        if (_dayArray.count-1<dayIndex) {
            dayIndex = _dayArray.count-1;
        }
    }
    
    [pickerView reloadAllComponents];
    
    switch (_pickerStyle) {
        case HTDatePickerStyle_Y:{
            _returnDateStr = [NSString stringWithFormat:@"%@",_yearArray[yearIndex]];
            self.scrollToDate = [NSDate date:_returnDateStr WithFormat:@"yyyy"];
        }
            break;
        case HTDatePickerStyle_YM:{
            _returnDateStr = [NSString stringWithFormat:@"%@-%@",_yearArray[yearIndex],_monthArray[monthIndex]];
            self.scrollToDate = [NSDate date:_returnDateStr WithFormat:@"yyyy-MM"];
        }
            break;
        case HTDatePickerStyle_YMD:{
            _returnDateStr = [NSString stringWithFormat:@"%@-%@-%@",_yearArray[yearIndex],_monthArray[monthIndex],_dayArray[dayIndex]];
            self.scrollToDate = [NSDate date:_returnDateStr WithFormat:@"yyyy-MM-dd"];
        }
            break;
        case HTDatePickerStyle_YMDh:{
            _returnDateStr = [NSString stringWithFormat:@"%@-%@-%@ %@",_yearArray[yearIndex],_monthArray[monthIndex],_dayArray[dayIndex],_hourArray[hourIndex]];
            self.scrollToDate = [NSDate date:_returnDateStr WithFormat:@"yyyy-MM-dd HH"];
        }
            break;
        case HTDatePickerStyle_YMDhm:{
            _returnDateStr = [NSString stringWithFormat:@"%@-%@-%@ %@:%@",_yearArray[yearIndex],_monthArray[monthIndex],_dayArray[dayIndex],_hourArray[hourIndex],_minuteArray[minuteIndex]];
            self.scrollToDate = [NSDate date:_returnDateStr WithFormat:@"yyyy-MM-dd HH:mm"];
        }
            break;
        default:{
            _returnDateStr = [NSString stringWithFormat:@"%@-%@-%@ %@:%@:%@",_yearArray[yearIndex],_monthArray[monthIndex],_dayArray[dayIndex],_hourArray[hourIndex],_minuteArray[minuteIndex],_secondArray[secondIndex]];
            self.scrollToDate = [NSDate date:_returnDateStr WithFormat:@"yyyy-MM-dd HH:mm:ss"];
        }
            break;
    }
    
    _startDate = self.scrollToDate;
}

#pragma mark 私有方法
/**
 *
 * *   取消按钮点击方法   *
 *
 */
- (void)clickCancelBtn{
    self.cancelBlock();
    [self hideDatePicker];
}
/**
 *
 * *   确定按钮点击方法   *
 *
 */
- (void)clickEnsureBtn{
//    NSLog(@"确定");
    self.ensureBlock(_returnDateStr);
    [self hideDatePicker];
}
/**
 *
 * *   显示时间选择器   *
 *
 */
- (void)showDatePicker{
    
    [self getNowDate:nil animated:YES];
    [UIView animateWithDuration:0.35 animations:^{
        self.frame = CGRectMake(0, SCREENHEIGHT - SELFHEIGHT, SCREENWIDTH, SELFHEIGHT);
    } completion:^(BOOL finished) {
        if (finished) {
            [self addSubview:self.alphaView];
            _alphaView.alpha = 0.4;
        }
    }];
}
/**
 *
 * *   隐藏时间选择器   *
 *
 */
- (void)hideDatePicker{
    [UIView animateWithDuration:0.35 animations:^{
        self.alphaView.alpha = 0;
        self.frame = CGRectMake(0, SCREENHEIGHT, SCREENWIDTH, SELFHEIGHT);
    } completion:^(BOOL finished) {
        if (finished) {
            [_alphaView removeFromSuperview];
        }
    }];
}

/**
 *
 * *   设置每月的天数数组   *
 *
 */
- (void)setdayArray:(NSInteger)num
{
    [_dayArray removeAllObjects];
    for (int i=1; i<=num; i++) {
        [_dayArray addObject:[NSString stringWithFormat:@"%02d",i]];
    }
    
}

/**
 计算每个月的天数

 @param year 年
 @param month 月
 @return 天数
 */
- (NSInteger)DaysfromYear:(NSInteger)year andMonth:(NSInteger)month
{
    NSInteger num_year  = year;
    NSInteger num_month = month;
    
    //判断是否是闰年 整除以4、100、400 则为闰年
    BOOL isrunNian = num_year%4==0 ? (num_year%100==0? (num_year%400==0?YES:NO):YES):NO;
    switch (num_month) {
        case 1:case 3:case 5:case 7:case 8:case 10:case 12:{
            [self setdayArray:31];
            return 31;
        }
        case 4:case 6:case 9:case 11:{
            [self setdayArray:30];
            return 30;
        }
        case 2:{
            if (isrunNian) {
                [self setdayArray:29];
                return 29;
            }else{
                [self setdayArray:28];
                return 28;
            }
        }
        default:
            break;
    }
    return 0;
}

/**
 *
 * *   滚动到指定的时间位置   *
 *
 */
- (void)getNowDate:(NSDate *)date animated:(BOOL)animated
{
    //date 日期为空 设置为当前日期
    if (!date) {
        date = [NSDate date];
    }
    
    [self DaysfromYear:date.year andMonth:date.month];
    
    yearIndex = date.year-MINYEAR;
    monthIndex = date.month-1;
    dayIndex = date.day-1;
    hourIndex = date.hour;
    minuteIndex = date.minute;
    secondIndex = date.seconds;
    
    NSArray *indexArray;
    
    switch (_pickerStyle) {
        case HTDatePickerStyle_Y:
            _returnDateStr = [NSString stringWithFormat:@"%@",_yearArray[yearIndex]];
            indexArray = @[@(yearIndex)];
            break;
        case HTDatePickerStyle_YM:
            _returnDateStr = [NSString stringWithFormat:@"%@-%@",_yearArray[yearIndex],_monthArray[monthIndex]];
            indexArray = @[@(yearIndex),@(monthIndex)];
            break;
        case HTDatePickerStyle_YMD:
            _returnDateStr = [NSString stringWithFormat:@"%@-%@-%@",_yearArray[yearIndex],_monthArray[monthIndex],_dayArray[dayIndex]];
            indexArray = @[@(yearIndex),@(monthIndex),@(dayIndex)];
            break;
        case HTDatePickerStyle_YMDh:
            _returnDateStr = [NSString stringWithFormat:@"%@-%@-%@ %@",_yearArray[yearIndex],_monthArray[monthIndex],_dayArray[dayIndex],_hourArray[hourIndex]];
            indexArray = @[@(yearIndex),@(monthIndex),@(dayIndex),@(hourIndex)];
            break;
        case HTDatePickerStyle_YMDhm:
            _returnDateStr = [NSString stringWithFormat:@"%@-%@-%@ %@:%@",_yearArray[yearIndex],_monthArray[monthIndex],_dayArray[dayIndex],_hourArray[hourIndex],_minuteArray[minuteIndex]];
            indexArray = @[@(yearIndex),@(monthIndex),@(dayIndex),@(hourIndex),@(minuteIndex)];
            break;
        default:
            _returnDateStr = [NSString stringWithFormat:@"%@-%@-%@ %@:%@:%@",_yearArray[yearIndex],_monthArray[monthIndex],_dayArray[dayIndex],_hourArray[hourIndex],_minuteArray[minuteIndex],_secondArray[secondIndex]];
            indexArray = @[@(yearIndex),@(monthIndex),@(dayIndex),@(hourIndex),@(minuteIndex),@(secondIndex)];
            break;
    }
    [self.datePickerView reloadAllComponents];
    
    for (int i=0; i<indexArray.count; i++) {
        
        [self.datePickerView selectRow:[indexArray[i] integerValue] inComponent:i animated:animated];
        //        if (i == 4) {
        //            [self.datePicker selectRow:date.minute inComponent:4 animated:YES];
        //        }
        
    }
    _startDate = self.scrollToDate;
}



/**
 根据年月日时分字符串判断是否晚于当前时间

 @param year 年
 @param month 月
 @param day 日
 @param hour 时
 @param minute 分
 @param second 秒
 @return 是否晚于当前时间
 */
- (BOOL)isLaterThanCurrentTimeWithYear:(NSString *)year mouth:(NSString *)month day:(NSString *)day hour:(NSString *)hour minute:(NSString *)minute second:(NSString *)second{
    NSDate *date = [NSDate date];
    if (year.integerValue > date.year) {
        return YES;
    }else if (year.integerValue == date.year){
        if (month.integerValue > date.month) {
            return YES;
        }else if (month.integerValue == date.month){
            if (day.integerValue > date.day) {
                return YES;
            }else if (day.integerValue == date.day){
                if (hour.integerValue > date.hour) {
                    return YES;
                }else if (hour.integerValue == date.hour){
                    if (minute.integerValue > date.minute) {
                        return YES;
                    }else if (minute.integerValue == date.minute){
                        if (second.integerValue >= date.seconds) {
                            return YES;
                        }else{
                            return NO;
                        }
                    }else{
                        return NO;
                    }
                }else{
                    return NO;
                }
            }else{
                return NO;
            }
        }else{
            return NO;
        }
    }else{
        return NO;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

static const unsigned componentFlags = (NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekOfMonth |  NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday | NSCalendarUnitWeekdayOrdinal);

#pragma mark NSDate的拓展

@implementation NSDate (Extension)
// Courtesy of Lukasz Margielewski
// Updated via Holger Haenisch
+ (NSCalendar *) currentCalendar
{
    static NSCalendar *sharedCalendar = nil;
    if (!sharedCalendar)
        sharedCalendar = [NSCalendar autoupdatingCurrentCalendar];
    return sharedCalendar;
}

#pragma mark - Relative Dates

+ (NSDate *) dateWithDaysFromNow: (NSInteger) days
{
    // Thanks, Jim Morrison
    return [[NSDate date] dateByAddingDays:days];
}

+ (NSDate *) dateWithDaysBeforeNow: (NSInteger) days
{
    // Thanks, Jim Morrison
    return [[NSDate date] dateBySubtractingDays:days];
}

+ (NSDate *) dateTomorrow
{
    return [NSDate dateWithDaysFromNow:1];
}

+ (NSDate *) dateYesterday
{
    return [NSDate dateWithDaysBeforeNow:1];
}

+ (NSDate *) dateWithHoursFromNow: (NSInteger) dHours
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_HOUR * dHours;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

+ (NSDate *) dateWithHoursBeforeNow: (NSInteger) dHours
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_HOUR * dHours;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

+ (NSDate *) dateWithMinutesFromNow: (NSInteger) dMinutes
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_MINUTE * dMinutes;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

+ (NSDate *) dateWithMinutesBeforeNow: (NSInteger) dMinutes
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_MINUTE * dMinutes;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

#pragma mark - String Properties
- (NSString *) stringWithFormat: (NSString *) format
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    //    formatter.locale = [NSLocale currentLocale]; // Necessary?
    formatter.dateFormat = format;
    return [formatter stringFromDate:self];
}

- (NSString *) stringWithDateStyle: (NSDateFormatterStyle) dateStyle timeStyle: (NSDateFormatterStyle) timeStyle
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateStyle = dateStyle;
    formatter.timeStyle = timeStyle;
    //    formatter.locale = [NSLocale currentLocale]; // Necessary?
    return [formatter stringFromDate:self];
}

- (NSString *) shortTimeString
{
    return [self stringWithDateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
}

- (NSString *) shortDateString
{
    return [self stringWithDateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
}

- (NSString *) mediumString
{
    return [self stringWithDateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle ];
}

- (NSString *) mediumTimeString
{
    return [self stringWithDateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterMediumStyle ];
}

- (NSString *) mediumDateString
{
    return [self stringWithDateStyle:NSDateFormatterMediumStyle  timeStyle:NSDateFormatterNoStyle];
}

- (NSString *) longString
{
    return [self stringWithDateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterLongStyle ];
}

- (NSString *) longTimeString
{
    return [self stringWithDateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterLongStyle ];
}

- (NSString *) longDateString
{
    return [self stringWithDateStyle:NSDateFormatterLongStyle  timeStyle:NSDateFormatterNoStyle];
}

#pragma mark - Comparing Dates

- (BOOL) isEqualToDateIgnoringTime: (NSDate *) aDate
{
    NSDateComponents *components1 = [[NSDate currentCalendar] components:componentFlags fromDate:self];
    NSDateComponents *components2 = [[NSDate currentCalendar] components:componentFlags fromDate:aDate];
    return ((components1.year == components2.year) &&
            (components1.month == components2.month) &&
            (components1.day == components2.day));
}

- (BOOL) isToday
{
    return [self isEqualToDateIgnoringTime:[NSDate date]];
}

- (BOOL) isTomorrow
{
    return [self isEqualToDateIgnoringTime:[NSDate dateTomorrow]];
}

- (BOOL) isYesterday
{
    return [self isEqualToDateIgnoringTime:[NSDate dateYesterday]];
}

// This hard codes the assumption that a week is 7 days
- (BOOL) isSameWeekAsDate: (NSDate *) aDate
{
    NSDateComponents *components1 = [[NSDate currentCalendar] components:componentFlags fromDate:self];
    NSDateComponents *components2 = [[NSDate currentCalendar] components:componentFlags fromDate:aDate];

    // Must be same week. 12/31 and 1/1 will both be week "1" if they are in the same week
    if (components1.weekOfMonth != components2.weekOfMonth) return NO;

    // Must have a time interval under 1 week. Thanks @aclark
    return (fabs([self timeIntervalSinceDate:aDate]) < D_WEEK);
}

- (BOOL) isThisWeek
{
    return [self isSameWeekAsDate:[NSDate date]];
}

- (BOOL) isNextWeek
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_WEEK;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return [self isSameWeekAsDate:newDate];
}

- (BOOL) isLastWeek
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_WEEK;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return [self isSameWeekAsDate:newDate];
}

// Thanks, mspasov
- (BOOL) isSameMonthAsDate: (NSDate *) aDate
{
    NSDateComponents *components1 = [[NSDate currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth fromDate:self];
    NSDateComponents *components2 = [[NSDate currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth fromDate:aDate];
    return ((components1.month == components2.month) &&
            (components1.year == components2.year));
}

- (BOOL) isThisMonth
{
    return [self isSameMonthAsDate:[NSDate date]];
}

// Thanks Marcin Krzyzanowski, also for adding/subtracting years and months
- (BOOL) isLastMonth
{
    return [self isSameMonthAsDate:[[NSDate date] dateBySubtractingMonths:1]];
}

- (BOOL) isNextMonth
{
    return [self isSameMonthAsDate:[[NSDate date] dateByAddingMonths:1]];
}

- (BOOL) isSameYearAsDate: (NSDate *) aDate
{
    NSDateComponents *components1 = [[NSDate currentCalendar] components:NSCalendarUnitYear fromDate:self];
    NSDateComponents *components2 = [[NSDate currentCalendar] components:NSCalendarUnitYear fromDate:aDate];
    return (components1.year == components2.year);
}

- (BOOL) isThisYear
{
    // Thanks, baspellis
    return [self isSameYearAsDate:[NSDate date]];
}

- (BOOL) isNextYear
{
    NSDateComponents *components1 = [[NSDate currentCalendar] components:NSCalendarUnitYear fromDate:self];
    NSDateComponents *components2 = [[NSDate currentCalendar] components:NSCalendarUnitYear fromDate:[NSDate date]];

    return (components1.year == (components2.year + 1));
}

- (BOOL) isLastYear
{
    NSDateComponents *components1 = [[NSDate currentCalendar] components:NSCalendarUnitYear fromDate:self];
    NSDateComponents *components2 = [[NSDate currentCalendar] components:NSCalendarUnitYear fromDate:[NSDate date]];

    return (components1.year == (components2.year - 1));
}

- (BOOL) isEarlierThanDate: (NSDate *) aDate
{
    return ([self compare:aDate] == NSOrderedAscending);
}

- (BOOL) isLaterThanDate: (NSDate *) aDate
{
    return ([self compare:aDate] == NSOrderedDescending);
}

// Thanks, markrickert
- (BOOL) isInFuture
{
    return ([self isLaterThanDate:[NSDate date]]);
}

// Thanks, markrickert
- (BOOL) isInPast
{
    return ([self isEarlierThanDate:[NSDate date]]);
}


#pragma mark - Roles
- (BOOL) isTypicallyWeekend
{
    NSDateComponents *components = [[NSDate currentCalendar] components:NSCalendarUnitWeekday fromDate:self];
    if ((components.weekday == 1) ||
        (components.weekday == 7))
        return YES;
    return NO;
}

- (BOOL) isTypicallyWorkday
{
    return ![self isTypicallyWeekend];
}

#pragma mark - Adjusting Dates

// Thaks, rsjohnson
- (NSDate *) dateByAddingYears: (NSInteger) dYears
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setYear:dYears];
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:self options:0];
    return newDate;
}

- (NSDate *) dateBySubtractingYears: (NSInteger) dYears
{
    return [self dateByAddingYears:-dYears];
}

- (NSDate *) dateByAddingMonths: (NSInteger) dMonths
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setMonth:dMonths];
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:self options:0];
    return newDate;
}

- (NSDate *) dateBySubtractingMonths: (NSInteger) dMonths
{
    return [self dateByAddingMonths:-dMonths];
}

// Courtesy of dedan who mentions issues with Daylight Savings
- (NSDate *) dateByAddingDays: (NSInteger) dDays
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:dDays];
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:self options:0];
    return newDate;
}

- (NSDate *) dateBySubtractingDays: (NSInteger) dDays
{
    return [self dateByAddingDays: (dDays * -1)];
}

- (NSDate *) dateByAddingHours: (NSInteger) dHours
{
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_HOUR * dHours;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate *) dateBySubtractingHours: (NSInteger) dHours
{
    return [self dateByAddingHours: (dHours * -1)];
}

- (NSDate *) dateByAddingMinutes: (NSInteger) dMinutes
{
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_MINUTE * dMinutes;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate *) dateBySubtractingMinutes: (NSInteger) dMinutes
{
    return [self dateByAddingMinutes: (dMinutes * -1)];
}

- (NSDateComponents *) componentsWithOffsetFromDate: (NSDate *) aDate
{
    NSDateComponents *dTime = [[NSDate currentCalendar] components:componentFlags fromDate:aDate toDate:self options:0];
    return dTime;
}

#pragma mark - Extremes

- (NSDate *) dateAtStartOfDay
{
    NSDateComponents *components = [[NSDate currentCalendar] components:componentFlags fromDate:self];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    return [[NSDate currentCalendar] dateFromComponents:components];
}

// Thanks gsempe & mteece
- (NSDate *) dateAtEndOfDay
{
    NSDateComponents *components = [[NSDate currentCalendar] components:componentFlags fromDate:self];
    components.hour = 23; // Thanks Aleksey Kononov
    components.minute = 59;
    components.second = 59;
    return [[NSDate currentCalendar] dateFromComponents:components];
}

#pragma mark - Retrieving Intervals

- (NSInteger) minutesAfterDate: (NSDate *) aDate
{
    NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
    return (NSInteger) (ti / D_MINUTE);
}

- (NSInteger) minutesBeforeDate: (NSDate *) aDate
{
    NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
    return (NSInteger) (ti / D_MINUTE);
}

- (NSInteger) hoursAfterDate: (NSDate *) aDate
{
    NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
    return (NSInteger) (ti / D_HOUR);
}

- (NSInteger) hoursBeforeDate: (NSDate *) aDate
{
    NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
    return (NSInteger) (ti / D_HOUR);
}

- (NSInteger) daysAfterDate: (NSDate *) aDate
{
    NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
    return (NSInteger) (ti / D_DAY);
}

- (NSInteger) daysBeforeDate: (NSDate *) aDate
{
    NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
    return (NSInteger) (ti / D_DAY);
}

//// Thanks, dmitrydims
//// I have not yet thoroughly tested this
- (NSInteger)distanceInDaysToDate:(NSDate *)anotherDate
{
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay fromDate:self toDate:anotherDate options:0];
    return components.day;
}

#pragma mark - Decomposing Dates

- (NSInteger) nearestHour
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_MINUTE * 30;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    NSDateComponents *components = [[NSDate currentCalendar] components:NSCalendarUnitHour fromDate:newDate];
    return components.hour;
}

- (NSInteger) hour
{
    NSDateComponents *components = [[NSDate currentCalendar] components:componentFlags fromDate:self];
    return components.hour;
}

- (NSInteger) minute
{
    NSDateComponents *components = [[NSDate currentCalendar] components:componentFlags fromDate:self];
    return components.minute;
}

- (NSInteger) seconds
{
    NSDateComponents *components = [[NSDate currentCalendar] components:componentFlags fromDate:self];
    return components.second;
}

- (NSInteger) day
{
    NSDateComponents *components = [[NSDate currentCalendar] components:componentFlags fromDate:self];
    return components.day;
}

- (NSInteger) month
{
    NSDateComponents *components = [[NSDate currentCalendar] components:componentFlags fromDate:self];
    return components.month;
}

- (NSInteger) week
{
    NSDateComponents *components = [[NSDate currentCalendar] components:componentFlags fromDate:self];
    return components.weekOfMonth;
}

- (NSInteger) weekday
{
    NSDateComponents *components = [[NSDate currentCalendar] components:componentFlags fromDate:self];
    return components.weekday;
}

- (NSInteger) nthWeekday // e.g. 2nd Tuesday of the month is 2
{
    NSDateComponents *components = [[NSDate currentCalendar] components:componentFlags fromDate:self];
    return components.weekdayOrdinal;
}

- (NSInteger) year
{
    NSDateComponents *components = [[NSDate currentCalendar] components:componentFlags fromDate:self];
    return components.year;
}

+ (NSDate *)date:(NSString *)datestr WithFormat:(NSString *)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateFormat:format];
    NSDate *date = [dateFormatter dateFromString:datestr];
#if ! __has_feature(objc_arc)
    [dateFormatter release];
#endif
    return date;
}

- (NSDate *)dateWithYMD
{
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd";
    NSString *selfStr = [fmt stringFromDate:self];
    return [fmt dateFromString:selfStr];
}

-(NSDate *)dateWithFormatter:(NSString *)formatter {
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = formatter;
    NSString *selfStr = [fmt stringFromDate:self];
    return [fmt dateFromString:selfStr];
}

@end










