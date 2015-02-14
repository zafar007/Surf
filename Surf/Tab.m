//
//  Tab.m
//  Surf
//
//  Created by Sapan Bhuta on 5/30/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#import "Tab.h"

@implementation Tab

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 4.0;
        self.layer.masksToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
        self.scrollView.backgroundColor = [UIColor clearColor];
    }
    return self;
}

#pragma mark - WKWebView Delegate Methods

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [(RootViewController *)self.vc startLoadingUI];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [(RootViewController *)self.vc endLoadingUI];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [(RootViewController *)self.vc endLoadingUI];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [(RootViewController *)self.vc endLoadingUI];
}

@end
