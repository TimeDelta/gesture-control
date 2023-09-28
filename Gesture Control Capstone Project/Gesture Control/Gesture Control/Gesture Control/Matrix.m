//
//  Matrix.m
//  Gesture Control
//
//  Modified by Bryan Herman on 9/26/12.
//  Copyright (c) 2012 Bryan Herman. All rights reserved.
//

#ifndef MATRIX
#define MATRIX

#import "Matrix.h"

@implementation Matrix

@synthesize matrix;

// Initialize this matrix with a specific number of rows and columns.
- (id) init: (int) rows : (int) columns {
	self = [super init];
	
	matrix = [[NSMutableArray alloc] initWithCapacity: rows];
	
	for (int row = 0; row < rows; row++)
		[matrix[row] addObject: [[NSMutableArray alloc] initWithCapacity: columns]];
	
	return self;
}


// Initialize this matrix with the contents of a source matrix.
- (id) initWithSource: (NSMutableArray*) source {
	matrix = source;
	
	return self;
}


// Unarchiver
- (id) initWithCoder: (NSCoder*)decoder {
	
}


// Archiver
- (void) encodeWithCoder: (NSCoder*)encoder {
	
}


// Add a value to an index.
- (void) add: (int) row : (int) column : (double) value {
	double newValue = [self get: row: column] + value;
	[self set: row : column
		   to: newValue];
}


// Get the value at [row][column].
- (double) get: (int) row : (int) column {
	return [matrix[row][column] doubleValue];
}


// Set a value in this matrix.
- (void) set: (int) row : (int) column
		  to: (double) value {
	matrix[row][column] = [NSNumber numberWithDouble: value];
}


// Get a specific column from this matrix.
- (Matrix*) column: (int) column {
	Matrix* result = [[Matrix alloc] init: [self numberOfRows] : 1];
	for (int row = 0; row < [self numberOfRows]; row++)
		[result set: row : column
				 to: [self get: row : column]];
	
	return result;
}


// Get the number of columns in this matrix.
- (int) numberOfColumns {
	return [matrix[0] count];
}


// Get the number of rows in this matrix.
- (int) numberOfRows {
	return [matrix count];
}


// Randomize this matrix
- (void) ramdomize: (double) min : (double) max {
	for (int r = 0; r < [self numberOfRows]; r++)
		for (int c = 0; c < [self numberOfColumns]; c++)
			matrix[r][c] = [NSNumber numberWithDouble: fmod(arc4random(), (max - min)) + min];
}


// Get this number of indices in this matrix.
- (int) size {
	return [matrix[0] count] * [matrix count];
}


// Sum all of the elements in this matrix.
- (double) sum {
	double result = 0;
	
	for (int row = 0; row < [self numberOfRows]; row++)
		for (int column = 0; column < [self numberOfColumns]; column++)
			result += [matrix[row][column] doubleValue];
	
	return result;
}


// Convert this matrix into a packed array.
- (NSMutableArray*) toPackedArray {
	NSMutableArray* result = [[NSMutableArray alloc] initWithCapacity: [self numberOfRows] * [self numberOfColumns]];
	
	int index = 0;
	for (int row = 0; row < [self numberOfRows]; row++)
		for (int column = 0; column < [self numberOfColumns]; column++)
			result[index++] = matrix[row][column];
	
	return result;
}


// Add the specified matrix to this one.
- (Matrix*) add: (Matrix*) addition {
	NSMutableArray* result = [[NSMutableArray alloc] initWithCapacity: [self numberOfRows]];
	for (int row = 0; row < [result count]; row++)
		[result addObject: [[NSMutableArray alloc] initWithCapacity: [self numberOfColumns]]];
	
	for (int resultRow = 0; resultRow < [self numberOfRows]; resultRow++)
		for (int resultColumn = 0; resultColumn < [self numberOfColumns]; resultColumn++)
			result[resultRow][resultColumn] = [NSNumber numberWithDouble: [addition get: resultRow: resultColumn]
			+ [matrix[resultRow][resultColumn] doubleValue]];
	
	return [[Matrix alloc] initWithSource: result];
}


// Divide this matrix by a value.
- (Matrix*) divide : (double) divisor {
	NSMutableArray* result = [[NSMutableArray alloc] initWithCapacity: [self numberOfRows]];
	for (int row = 0; row < [result count]; row++)
		[self.matrix[row] addObject: [[NSMutableArray alloc] initWithCapacity: [self numberOfColumns]]];
	
	for (int row = 0; row < [self numberOfRows]; row++)
		for (int column = 0; column < [self numberOfColumns]; column++)
			result[row][column] = [NSNumber numberWithDouble: [self get: row : column] / divisor];
	
	return [[Matrix alloc] initWithSource: result];
}


// Get the dot product of this matrix with another one.
- (double) dotProduct: (Matrix*) m {
	NSMutableArray* array1 = [self toPackedArray];
	NSMutableArray* array2 = [m toPackedArray];
	
	double result = 0;
	
	for (int index = 0; index < [array1 count]; index++)
		result += [array1[index] doubleValue] * [array2[index] doubleValue];
	
	return result;
}


// Multiply this matrix by a constant.
- (Matrix*) multiplyByConstant: (double) constant {
	NSMutableArray* result = [[NSMutableArray alloc] initWithCapacity: [self numberOfRows]];
	for (int row = 0; row < [result count]; row++)
		[result[row] addObject: [[NSMutableArray alloc] initWithCapacity: constant]];
	
	for (int row = 0; row < [self numberOfRows]; row++)
		for (int column = 0; column < [self numberOfColumns]; column++)
			result[row][column] = [NSNumber numberWithDouble: [self get: row : column] * constant];
	
	return [[Matrix alloc] initWithSource: result];
}


// Multiply this matrix by another one.
- (Matrix*) multiply: (Matrix*) m {
	NSMutableArray* result = [[NSMutableArray alloc] initWithCapacity: [self numberOfRows]];
	for (int index = 0; index < [result count]; index++)
		[result[index] addObject: [[NSMutableArray alloc] initWithCapacity: [m numberOfColumns]]];
	
	for (int resultRow = 0; resultRow < [self numberOfRows]; resultRow++)
		for (int resultCol = 0; resultCol < [m numberOfColumns]; resultCol++){
			double value = 0;
			
			for (int index = 0; index < [self numberOfColumns]; index++)
				value += [self get: resultRow : index] * [m get: index : resultCol];
			result[resultRow][resultCol] = [NSNumber numberWithDouble: value];
		}
	
	return [[Matrix alloc] initWithSource: result];
}


// Subtract the specified matrix from this one.
- (Matrix*) subtract: (Matrix*) b {
	NSMutableArray* result = [[NSMutableArray alloc] initWithCapacity: [self numberOfRows]];
	for (int row = 0; row < sizeof(result); row++)
		[result[row] addObject: [[NSMutableArray alloc] initWithCapacity: [self numberOfColumns]]];
	
	for (int row = 0; row < [self numberOfRows]; row++)
		for (int column = 0; column < [self numberOfColumns]; column++)
			result[row][column] = [NSNumber numberWithDouble: [self get: row : column] - [b get: row : column]];
	
	return [[Matrix alloc] initWithSource: result];
}


// Transpose this matrix.
- (Matrix*) transpose {
	NSMutableArray* inverseMatrix = [[NSMutableArray alloc] initWithCapacity: [self numberOfColumns]];
	for (int row = 0; row < sizeof(inverseMatrix); row++)
		[inverseMatrix addObject: [[NSMutableArray alloc] initWithCapacity: [self numberOfRows]]];
	
	for (int row = 0; row < [self numberOfRows]; row++)
		for (int column = 0; column < [self numberOfColumns]; column++)
			inverseMatrix[column][row] = matrix[row][column];
	
	return [[Matrix alloc] initWithSource: inverseMatrix];
}


// Calculate the length of this vector.
- (double) vectorLength {
	NSMutableArray* vector = [self toPackedArray];
	
	double length = 0;
	for (int index = 0; index < [vector count]; index++)
		length += pow([vector[index] doubleValue], 2);
	
	return sqrt(length);
}


// Remove a row from this matrix.
- (void) deleteRow: (int) rowIndex {
	[matrix removeObjectAtIndex: rowIndex];
}


// Remove a column from this matrix.
- (void) deleteColumn: (int) columnIndex {
	for (int row = 0; row < [self numberOfRows]; row++){
		NSMutableArray* array = [matrix objectAtIndex: row];
		[array removeObjectAtIndex: columnIndex];
		[matrix setObject: array atIndexedSubscript: row];
	}
}

@end

#endif
