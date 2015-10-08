/*
 * This fix is provided by the following URL:
 * http://stackoverflow.com/questions/25793074/subtitles-of-uitableviewcell-wont-update
 *
 * Copyright (C) 2014 Carl Lindberg
 */

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@implementation UITableViewCell (IOS8DetailCellFix)

+ (void)load {

    if ([UIDevice currentDevice].systemVersion.intValue >= 8) {

        Method original = class_getInstanceMethod(self, @selector(layoutSubviews));
        Method replace  = class_getInstanceMethod(self, @selector(_detailfix_layoutSubviews));
        method_exchangeImplementations(original, replace);
    }
}

- (void)_detailfix_layoutSubviews {

    /*
     * UITableViewCell seems to return nil if the cell type does not have a detail.
     * If it returns non-nil, force add it as a contentView subview so that it gets
     * view layout processing at the right times.
     */

    UILabel *detailLabel = self.detailTextLabel;

    if ((detailLabel != nil) && (detailLabel.superview == nil)) {
        [self.contentView addSubview:detailLabel];
    }

    [self _detailfix_layoutSubviews];
}

@end
