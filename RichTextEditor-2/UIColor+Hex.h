//
//  UIColor+Hex.h
//  RichTextEditor-2
//
//  Created by chenxu on 2019/8/18.
//  Copyright © 2019 chenxu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (Hex)

+ (UIColor *)colorWithHexString:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
