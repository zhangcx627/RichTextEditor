//
//  WKWebView+WKWebViewInjection.h
//  RichTextEditor
//
//  Created by chenxu on 2019/8/13.
//  Copyright © 2019 chenxu. All rights reserved.
//

#import <WebKit/WebKit.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKWebView (WKWebViewInjection)
- (void)keyboardRequiresUserInteraction:(BOOL) show;
- (void)allowDisplayingKeyboardWithoutUserAction;
- (id)syncEvalJavascriptString:(NSString *)jsCode;
@end

NS_ASSUME_NONNULL_END
