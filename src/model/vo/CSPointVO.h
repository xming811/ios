/*

Copyright (C) 2010  CycleStreets Ltd

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

*/

//  CSPoint.h
//  CycleStreets
//
//  Created by Alan Paxton on 17/05/2010.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@interface CSPointVO : NSObject <NSCoding>{
	CGPoint p;

}

@property CGPoint p;
@property (nonatomic,assign) BOOL isWalking;

- (BOOL) insideRect:(CGRect)rect;

@property (nonatomic, readonly)	CLLocationCoordinate2D	coordinate;


@end
