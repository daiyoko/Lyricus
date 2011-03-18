
//
// This file is part of Lyricus.
// Copyright (c) 2008, Thomas Backman <serenity@exscape.org>
// All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "NSString+ExscapeEdits.h"
#import "NSTextView+ExscapeFontFix.h"
#import "SitePriorities.h"
#import "LyricController.h"
#import "Bulk.h"


@interface LyricreaderController : NSObject <NSWindowDelegate, NSTextViewDelegate, NSToolbarDelegate> {
	
	// Main window
	IBOutlet NSWindow *mainWindow;
	IBOutlet NSTextView *lyricView;
	IBOutlet NSProgressIndicator *spinner;
	IBOutlet NSButton *followiTunesCheckbox;
	IBOutlet id spinnerView;
	IBOutlet NSMenuItem *editModeMenuItem;
	
	// Search window
	IBOutlet NSWindow *searchWindow;
	IBOutlet NSTextField *artistField;
	IBOutlet NSTextField *titleField;
	IBOutlet NSButton *goButton;
	IBOutlet NSTextField *warningLabel;
	
	// Preferences window
	IBOutlet NSWindow *preferencesWindow;
	IBOutlet NSButton *alwaysOnTop;
	IBOutlet NSTableView *table;
	
	// About window
	IBOutlet NSWindow *aboutWindow;
	IBOutlet NSImageView *iconView;
	IBOutlet NSTextField *aboutVersion;

//	IBOutlet NSWindow *bulkWindow;
	
	//
	// Instance variables
	//
//	TBDarklyrics *darkLyrics;
	TBSongmeanings *songmeanings;
	LyricController *lyricController;
	iTunesHelper *helper;
	NSString *textURL;
	NSString *lastTrack;
	
	NSString *displayedArtist;
	NSString *displayedTitle;
	bool lyricsDisplayed;
	bool loadingLyrics;
	bool manualSearch;
	
	Bulk *bulkDownloader;
}

// Preferences window
-(IBAction) openPreferencesWindow:(id) sender;
-(IBAction) alwaysOnTopClicked:(id) sender;
-(IBAction) showPreferencesHelp:(id) sender;
-(IBAction) closePreferencesButton:(id) sender;

// Search window
-(IBAction) openSearchWindow:(id) sender;
-(IBAction) goButton:(id) sender;				// Search-for-lyric button
-(IBAction) getFromiTunesButton:(id) sender;
-(IBAction) closeSearchWindow:(id) sender;			// Close search window
-(IBAction) followiTunesCheckboxClicked:(id) sender;		// Auto-update checkbox clicked

// Misc
-(void)disableEditMode;
-(IBAction)toggleEditMode:(id) sender;
-(IBAction)saveLyrics:(id) sender;
-(IBAction)saveDisplayedLyricsToCurrentlyPlayingTrack:(id) sender;
-(IBAction) showAboutWindow:(id) sender;
-(void) setupToolbar;
-(IBAction)openBulkDownloader:(id)sender;
-(IBAction)openFontPanel:(id)sender;
-(IBAction)openSongMeaningsPage:(id)sender;
-(void)openSongmeaningsThread:(NSArray *)data;
@end