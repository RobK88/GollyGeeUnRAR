//
//  ExtractionWindowController.h
//  GeeUnRAR
//
//  Created by Giuliano A. Montecarlo on 3/27/11.
//  Copyright 2011 Giuliano A. Montecarlo. All rights reserved.
//
//  GeeUnRAR - Mac OS X GUI for unrar
//  Copyright (C) 2011  Giuliano A. Montecarlo
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.

#import <Cocoa/Cocoa.h>
#import "UnRARParsingUtils.h"


@interface ExtractionWindowController : NSWindowController {
@private
    
    NSProgressIndicator *progressbar;
    NSTextFieldCell *remainingTime;
    NSTextField *filename;
    NSButton *cancelButton;
    NSWindow *overwriteSheet;
    NSButton *yesButton;
    NSWindow *passwordSheet;
    NSTextField *overwriteFileName;
    NSWindow *errorSheet;
    NSWindow *currentPasswordSheet;
    NSTextField *errorText;
    NSTextField *passwordText;
    NSSecureTextField *passwordField;
    NSButton *passwordOKButton;
    NSButton *errorCloseButton;
    NSTextField *ucpFilename;
    NSTask *unrar;
    NSPipe *taskPipe;
    NSPipe *inputPipe;
    
    NSDate *lastPercentageUpdate;
    NSTimeInterval averageTimeBetweenPercentageUpdates;
}
@property (assign) IBOutlet NSProgressIndicator *progressbar;
@property (assign) IBOutlet NSTextFieldCell *remainingTime;
@property (assign) IBOutlet NSTextField *filename;
@property (assign) IBOutlet NSButton *cancelButton;
@property (assign) IBOutlet NSWindow *overwriteSheet;
@property (assign) IBOutlet NSButton *yesButton;
@property (assign) IBOutlet NSWindow *passwordSheet;
@property (assign) IBOutlet NSTextField *overwriteFileName;
@property (assign) IBOutlet NSWindow *errorSheet;
@property (assign) IBOutlet NSWindow *currentPasswordSheet;
@property (assign) IBOutlet NSTextField *errorText;
@property (assign) IBOutlet NSTextField *passwordText;
@property (assign) IBOutlet NSSecureTextField *passwordField;
@property (assign) IBOutlet NSButton *passwordOKButton;
@property (assign) IBOutlet NSButton *errorCloseButton;
@property (assign) IBOutlet NSTextField *ucpFilename;


- (IBAction)cancelClicked:(id)sender;
- (IBAction)closeClicked:(id)sender;
- (IBAction)passwordOKClicked:(id)sender;

- (IBAction)overwriteYes:(id)sender;
- (IBAction)overwriteNo:(id)sender;
- (IBAction)overwriteAll:(id)sender;
- (IBAction)overwriteRename:(id)sender;
- (IBAction)overwriteCancel:(id)sender;
- (IBAction)overwriteNever:(id)sender;

- (void)unrarFile:(NSURL *)file;

- (id)initWithWindowNibName:(NSString *)windowNibName withFile:(NSString *)file;
@end
