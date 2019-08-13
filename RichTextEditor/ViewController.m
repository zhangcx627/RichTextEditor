//
//  ViewController.m
//  RichTextEditor
//
//  Created by chenxu on 2019/8/13.
//  Copyright © 2019 chenxu. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Standard";

    //Set Custom CSS
    NSString *customCSS = @"";
    [self setCSS:customCSS];

    self.alwaysShowToolbar = YES;
    self.receiveEditorDidChangeEvents = NO;

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Export" style:UIBarButtonItemStylePlain target:self action:@selector(exportHTML)];

    // HTML Content to set in the editor
    NSString *html = @"<div class='test'></div><!-- This is an HTML comment -->"
    "<p></p>";

    // Set the base URL if you would like to use relative links, such as to images.
    self.baseURL = [NSURL URLWithString:@"http://www.zedsaid.com"];
    self.shouldShowKeyboard = NO;
    // Set the HTML contents of the editor
    //    [self setPlaceholder:@"This is a placeholder that will show when there is no content(html)"];

    [self setHTML:html];

}

- (void)exportHTML {

    NSLog(@"%@", [self getHTML]);

}

- (void)editorDidChangeWithText:(NSString *)text andHTML:(NSString *)html {

    NSLog(@"Text Has Changed: %@", text);

    NSLog(@"HTML Has Changed: %@", html);

}

- (void)hashtagRecognizedWithWord:(NSString *)word {

    NSLog(@"Hashtag has been recognized: %@", word);

}

- (void)mentionRecognizedWithWord:(NSString *)word {

    NSLog(@"Mention has been recognized: %@", word);

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
