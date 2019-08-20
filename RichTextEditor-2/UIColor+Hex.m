//
//  UIColor+Hex.m
//  RichTextEditor-2
//
//  Created by chenxu on 2019/8/18.
//  Copyright © 2019 chenxu. All rights reserved.
//

#import "UIColor+Hex.h"

@implementation UIColor (Hex)

/**
 * 十六进制颜色数值转UIColor
 */
+ (UIColor *)colorWithRGBHex:(UInt32)hex {
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;

    return [UIColor colorWithRed:r/255.0f
                           green:g/255.0f
                            blue:b/255.0f
                           alpha:1.0f];
}

/**
 * 十六进制颜色字符串转UIColor
 */
+ (UIColor *)colorWithHexString:(NSString *)string {
    string = [string stringByReplacingOccurrencesOfString:@"#" withString:@""];
    NSScanner *scanner = [[NSScanner alloc] initWithString:string];
    UInt32 hex;
    if (![scanner scanHexInt:&hex]) { return nil; }
    return [self colorWithRGBHex:hex];
}
@end
