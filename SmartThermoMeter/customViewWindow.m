//
//  customViewWindow.m
//  SmartThermoMeter
//
//  Created by YuansMacMini on 17/8/11.
//  Copyright © 2017年 Yuan. All rights reserved.
//

#import "customViewWindow.h"

@interface customViewWindow ()

@end

@implementation customViewWindow

+ (instancetype)viewController {
    return [[[self class] alloc] initWithNibName:NSStringFromClass([self class]) bundle:nil];
}
- (IBAction)showApp:(id)sender {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}
- (CGSize)preferredContentSize {
    return self.view.frame.size;
}@end
