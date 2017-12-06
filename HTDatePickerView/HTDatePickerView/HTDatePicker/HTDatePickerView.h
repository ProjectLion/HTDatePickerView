//
//  HTDatePickerView.h
//  HTDatePickerView
//
//  Created by HT on 2017/12/6.
//  Copyright © 2017年 HT. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 *   时间选择器的风格
 */
typedef enum :NSUInteger{
    HTDatePickerStyle_Y,            //年
    HTDatePickerStyle_YM,           //年月
    HTDatePickerStyle_YMD,          //年月日
    HTDatePickerStyle_YMDh,         //年月日时
    HTDatePickerStyle_YMDhm,        //年月日时分
    HTDatePickerStyle_YMDhms,       //年月日时分秒
}HTDatePickerStyle;
/**
 *   取消按钮回调
 */
typedef void(^cancelBlock)(void);
/**
 *   确定按钮回调
 */
typedef void(^ensureBlock)(NSString *date);

@interface HTDatePickerView : UIView
/**
 *   时间选择器的风格
 */
@property(nonatomic, assign)HTDatePickerStyle pickerStyle;
/**
 *   取消按钮的颜色 默认黑色
 */
@property(nonatomic, strong)UIColor *cancelBtnColor;
/**
 *   确定按钮的颜色 默认黑色
 */
@property(nonatomic, strong)UIColor *ensureBtnColor;
/**
 *   是否为按钮的添加边框 默认有边框
 */
@property(nonatomic, assign)BOOL isShowButtonBorder;
/**
 *   按钮边框颜色 只有isShowButtonBorder = YES时设置有效
 */
@property(nonatomic, strong)UIColor *buttonBorderColor;
/**
 *   按钮字体颜色  默认为系统14号字体
 */
@property(nonatomic, strong)UIFont *buttonTitleFont;
/**
 *   取消按钮回调
 */
@property(nonatomic, copy)cancelBlock cancelBlock;
/**
 *   确定按钮回调
 */
@property(nonatomic, copy)ensureBlock ensureBlock;
/**
 *   是否可以选择当前时间之前的时间 默认为不可选(生日类需将此项设置为YES)
 */
@property(nonatomic, assign)BOOL isCanSelectCurrentTimeBefore;

/**
 显示时间选择器
 */
- (void)showDatePicker;

/**
 隐藏时间选择器
 */
- (void)hideDatePicker;

/**
 创建时间选择器

 @param frame frame
 @param style 风格
 @return self
 */
- (instancetype)initHtDatePickerViewWithFrame:(CGRect)frame style:(HTDatePickerStyle)style;

/**
 创建时间选择器

 @param frame frame
 @param style 风格
 @return self
 */
+ (instancetype)htDatePickerViewWithFrame:(CGRect)frame style:(HTDatePickerStyle)style;

@end


@interface NSDate (Extension)

+ (NSCalendar *) currentCalendar; // avoid bottlenecks

// Relative dates from the current date
+ (NSDate *) dateTomorrow;
+ (NSDate *) dateYesterday;
+ (NSDate *) dateWithDaysFromNow: (NSInteger) days;
+ (NSDate *) dateWithDaysBeforeNow: (NSInteger) days;
+ (NSDate *) dateWithHoursFromNow: (NSInteger) dHours;
+ (NSDate *) dateWithHoursBeforeNow: (NSInteger) dHours;
+ (NSDate *) dateWithMinutesFromNow: (NSInteger) dMinutes;
+ (NSDate *) dateWithMinutesBeforeNow: (NSInteger) dMinutes;
+ (NSDate *)date:(NSString *)datestr WithFormat:(NSString *)format;

// Short string utilities
- (NSString *) stringWithDateStyle: (NSDateFormatterStyle) dateStyle timeStyle: (NSDateFormatterStyle) timeStyle;
- (NSString *) stringWithFormat: (NSString *) format;
@property (nonatomic, readonly) NSString *shortString;
@property (nonatomic, readonly) NSString *shortDateString;
@property (nonatomic, readonly) NSString *shortTimeString;
@property (nonatomic, readonly) NSString *mediumString;
@property (nonatomic, readonly) NSString *mediumDateString;
@property (nonatomic, readonly) NSString *mediumTimeString;
@property (nonatomic, readonly) NSString *longString;
@property (nonatomic, readonly) NSString *longDateString;
@property (nonatomic, readonly) NSString *longTimeString;

// Comparing dates
- (BOOL) isEqualToDateIgnoringTime: (NSDate *) aDate;

- (BOOL) isToday;
- (BOOL) isTomorrow;
- (BOOL) isYesterday;

- (BOOL) isSameWeekAsDate: (NSDate *) aDate;
- (BOOL) isThisWeek;
- (BOOL) isNextWeek;
- (BOOL) isLastWeek;

- (BOOL) isSameMonthAsDate: (NSDate *) aDate;
- (BOOL) isThisMonth;
- (BOOL) isNextMonth;
- (BOOL) isLastMonth;

- (BOOL) isSameYearAsDate: (NSDate *) aDate;
- (BOOL) isThisYear;
- (BOOL) isNextYear;
- (BOOL) isLastYear;

- (BOOL) isEarlierThanDate: (NSDate *) aDate;
- (BOOL) isLaterThanDate: (NSDate *) aDate;

- (BOOL) isInFuture;
- (BOOL) isInPast;

// Date roles
- (BOOL) isTypicallyWorkday;
- (BOOL) isTypicallyWeekend;

// Adjusting dates
- (NSDate *) dateByAddingYears: (NSInteger) dYears;
- (NSDate *) dateBySubtractingYears: (NSInteger) dYears;
- (NSDate *) dateByAddingMonths: (NSInteger) dMonths;
- (NSDate *) dateBySubtractingMonths: (NSInteger) dMonths;
- (NSDate *) dateByAddingDays: (NSInteger) dDays;
- (NSDate *) dateBySubtractingDays: (NSInteger) dDays;
- (NSDate *) dateByAddingHours: (NSInteger) dHours;
- (NSDate *) dateBySubtractingHours: (NSInteger) dHours;
- (NSDate *) dateByAddingMinutes: (NSInteger) dMinutes;
- (NSDate *) dateBySubtractingMinutes: (NSInteger) dMinutes;

// Date extremes
- (NSDate *) dateAtStartOfDay;
- (NSDate *) dateAtEndOfDay;

// Retrieving intervals
- (NSInteger) minutesAfterDate: (NSDate *) aDate;
- (NSInteger) minutesBeforeDate: (NSDate *) aDate;
- (NSInteger) hoursAfterDate: (NSDate *) aDate;
- (NSInteger) hoursBeforeDate: (NSDate *) aDate;
- (NSInteger) daysAfterDate: (NSDate *) aDate;
- (NSInteger) daysBeforeDate: (NSDate *) aDate;
- (NSInteger)distanceInDaysToDate:(NSDate *)anotherDate;

// Decomposing dates
@property (readonly) NSInteger nearestHour;
@property (readonly) NSInteger hour;
@property (readonly) NSInteger minute;
@property (readonly) NSInteger seconds;
@property (readonly) NSInteger day;
@property (readonly) NSInteger month;
@property (readonly) NSInteger week;
@property (readonly) NSInteger weekday;
@property (readonly) NSInteger nthWeekday; // e.g. 2nd Tuesday of the month == 2
@property (readonly) NSInteger year;

- (NSDate *)dateWithYMD;
- (NSDate *)dateWithFormatter:(NSString *)formatter;

@end
