
//
// This file is part of Lyricus.
// Copyright (c) 2008, Thomas Backman <serenity@exscape.org>
// All rights reserved.
//

#import "LyricController.h"
#import "RegexKitLite.h"

@implementation LyricController

-(LyricController *)init {
    self = [super init];
	if (self) {
		[self updateSiteList];
	}
	
	return self;
}

#pragma mark -
#pragma mark Public

@synthesize sitesByPriority;

-(NSMutableArray *)fetchDataForTrack:(NSString *)theTrack byArtist:(NSString *)theArtist {
	
	if (theTrack && [theTrack containsString:@"(live" ignoringCaseAndDiacritics:YES]) {
        theTrack = [theTrack stringByReplacingOccurrencesOfRegex:@"(?i)(.*?)\\s*\\(live.*" withString:@"$1"];
	}
	
	if (sitesByPriority == nil || [sitesByPriority count] == 0) {
		[TBUtil showAlert:@"List of site priorities not set up! Please go to the preferences window, drag them in the order you like and then try again."
			  withCaption:@"Site list not found"];
		return nil;
	}
	
	// Runs through the list of sites, in order, until
	// 1) there are no more sites (return nil), or
	// 2) the lyric is found and returned
	for (id site in sitesByPriority) {
		NSMutableArray *dataArray = [site fetchLyricsForTrack:theTrack byArtist:theArtist];
		
		if (dataArray != nil && [dataArray objectAtIndex:LYRIC] != nil) {
			return dataArray;
		}
	}
	return nil;
}

-(void) updateSiteList {
	//
	// Update the list of sites to use, i.e. the array that is used for lookups later
	//
	
	// The instance variable used later
	sitesByPriority = [[NSMutableArray alloc] init];
	
	// This one is only used here; it's grabbed straight from the settings in the preferences window
	NSArray *prio = [[NSUserDefaults standardUserDefaults] objectForKey:@"Site priority list"];
	if (!prio) {
		// Give it another shot before complaining to the user
		[[SitePriorities alloc] init];
		prio = [[NSUserDefaults standardUserDefaults] objectForKey:@"Site priority list"];
	}
	
	if (!prio) {
		[TBUtil showAlert:@"Site priority list not found! Please go into the preferences window, drag them in the order you'd like, then try again."
			  withCaption:@"Error"];
		return;
	}
	
	// This for loop sets it all up, highest priority first of course.
	// A bit ugly, but it's good enough for now.
	for (NSDictionary *site in prio) {
		int enabled = [[site objectForKey:@"enabled"] intValue];
		if (!enabled) {
			// Ignore sites that aren't checked as enabled in the preferences window
			continue;
		}
		
		NSString *siteName = [[site objectForKey:@"site"] lowercaseString];
		
		if ([siteName isEqualToString:@"darklyrics"])
			[sitesByPriority addObject: [[TBDarklyrics alloc] init]];
		else if ([siteName isEqualToString:@"songmeanings"])
			[sitesByPriority addObject: [[TBSongmeanings alloc] init]];
//		else if ([siteName isEqualToString:@"lyricwiki"])
//			[sitesByPriority addObject: [[TBLyricwiki alloc] init]];
	}
}

@end
