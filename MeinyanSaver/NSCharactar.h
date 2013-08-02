//
//  NSCharactar.h
//  MeinyanSaver
//
//  Created by SuzumeJr on 2013/06/27.
//  Copyright (c) 2013 SuzumeJr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSCharactar : NSObject
-(BOOL)initData:(NSRect)rectScreen L2RPattern:(NSArray*)aL2RPt R2LPattern:(NSArray*)aR2LPt;
-(BOOL)setWaitPattern:(NSInteger)iWait;
-(BOOL)Action;
@end
