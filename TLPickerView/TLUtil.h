//
//  TLUtil.h
//  TLPickerViewDemo
//
//  Created by Lan on 17/3/16.
//  Copyright © 2017年 TL. All rights reserved.
//

#ifndef TLUtil_h
#define TLUtil_h


/**
 *  RGB颜色
 */
#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


//#define DEBUG_MODE
#ifdef DEBUG
#define DLog( s, ... ) NSLog( @"%@", [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define DLog( s, ... )
#endif


#endif /* TLUtil_h */
