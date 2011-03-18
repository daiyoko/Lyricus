
//
// This file is part of Lyricus.
// Copyright (c) 2008, Thomas Backman <serenity@exscape.org>
// All rights reserved.
//

#import "iTunesHelper.h"

@implementation iTunesHelper

#pragma mark -
#pragma mark init stuff

-(id) init {
    self = [super init];
	if (self) {
		iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
	}
	
	return self;
}

-(BOOL) initiTunes {
	@try {
		if (iTunes == nil)
			iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
		
		if (![iTunes isRunning]) {
			return NO;
		}
	}
	@catch (NSException *e) { return NO; }
	
	return YES;
}

#pragma mark -
#pragma mark Playlist stuff

-(NSArray *)getAllPlaylists {
		NSMutableArray *playlistArray = [[NSMutableArray alloc] init];
		
		if (![self initiTunes])
			return nil;
		
		@try {
			SBElementArray *pls = [[[iTunes sources] objectAtIndex:0] playlists];
			
			for (iTunesPlaylist *pl in pls) {
				if (!pl)
					continue;
				int kind = [pl specialKind];
				if (kind == iTunesESpKNone || kind == 'kVdN') // Damn Apple, changing things between iTunes versions!
					[playlistArray addObject:pl];
			}
		}
		@catch (NSException *e) { return nil; }
		
		return playlistArray;
}

-(NSArray *)getSelectedTracks {
	if (![self initiTunes])
		return nil;
	
	@try {
		return [[iTunes selection] get];
	}
	@catch (NSException *e) { return nil; }
	
	return nil;
}


-(iTunesPlaylist *)getLibraryPlaylist {
	if (![self initiTunes])
		return nil;
	
	@try {
		return [[[[iTunes sources] objectAtIndex:0] playlists] objectAtIndex:0];
	}
	@catch (NSException *e) { return nil; }
	
	return nil;
}

#pragma mark -
#pragma mark Track stuff

-(NSArray *)getTracksForPlaylist:(NSString *)thePlaylist {
	//
	// Takes a playlist name as an argument, and returns a regular array with iTunesTrack * pointers.
	//
	NSMutableArray *trackList = [[NSMutableArray alloc] init];

	if (![self initiTunes])
		return nil;
	
	@try {
		SBElementArray *pls = [[[iTunes sources] objectAtIndex:0] playlists];
		
		for (iTunesPlaylist *pl in pls) {
			if ([[pl name] isEqualToString:thePlaylist]) {
				for (iTunesTrack *t in [pl tracks]) {
					[trackList addObject:t];
				}
			}
		}
	}
	@catch (NSException *e) { return nil; }
	
	return trackList;
}

-(NSArray *)getAllTracksAndLyrics {
	NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    
	if (![self initiTunes])
		return nil;
	
	@try {
		SBElementArray *pls = [[[iTunes sources] objectAtIndex:0] playlists];
		
        int tmp = 0;
		for (iTunesPlaylist *pl in pls) {
            if ([[pl name] isEqualToString:@"Music"]) {
//                NSLog(@"Starting track fetch... %@ tracks", [[pl tracks] count]);
                for (iTunesTrack *t in [pl tracks]) {
                    [dataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:[t artist], @"artist", [t name], @"name", [t lyrics], @"lyrics", nil]];
                    if (tmp++ % 50) 
                        NSLog(@".");
                    if (tmp % 500)
                        NSLog(@"\n");
                }
            }
        }
    }
	@catch (NSException *e) { return nil; }
	
	return dataArray;
}

-(iTunesTrack *)getCurrentTrack {
	if (![self initiTunes])
		return nil;
	
	@try {
		iTunesTrack *t = [iTunes currentTrack];
		if (t != nil && [t exists])
			return t;
		else
			return nil;
	}
	@catch (NSException *e) { return nil; }
	
	return nil;
}


-(NSString *)getLyricsForTrack:(iTunesTrack *)theTrack {
	if (![self initiTunes]) {
		return nil;
	}
	
	@try {
		NSString *lyrics = [theTrack lyrics];
		if (lyrics && [lyrics length] > 8)
			return lyrics;
		else
			return nil;
	}
	@catch (NSException *e) { return nil; }
	return nil;
}

-(BOOL)setLyrics:(NSString *)theLyrics ForTrack:(iTunesTrack *)theTrack {
	if (theLyrics == nil) return NO;
	if (![self initiTunes]) {
		return NO;
	}
	
	@try {
		[theTrack setLyrics:theLyrics];
	}
	@catch (NSException *e) { return NO; }
	
	return YES;
}

-(NSArray *)getAllTracksForTitle:(NSString *)theTitle byArtist:(NSString *)theArtist {
	if (![self initiTunes])
		return nil;

	NSMutableArray *outArray = [NSMutableArray array];
	
	@try {
		SBElementArray *arr = (SBElementArray *)[[self getLibraryPlaylist] searchFor:theTitle only:iTunesESrASongs];
		// NOTE TO SELF: Don't use [TBUtil string: isEqual...] here, as we DO want diacritics and stuff to matter - but not capitalization
		for (iTunesTrack *track in arr) {
			/* [t1 compare:t2 options:(NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch)] == NSOrderedSame */
			if ([[track artist] compare:theArtist options:NSCaseInsensitiveSearch] == NSOrderedSame) // Make sure that we don't overwrite some other artist's song
				if ([[track name] compare:theTitle options:NSCaseInsensitiveSearch] == NSOrderedSame) // ... or some other track that matches (a search for Artist - Song might match Artist - Song (live) first!)
			/*			if ([[track artist] isEqualToString:theArtist]) // Make sure that we don't overwrite some other artist's song
			 if ([[track name] isEqualToString:theTitle]) // ... or some other track that matches (a search for Artist - Song might match Artist - Song (live) first!) */

				{
					[outArray addObject:[track get]];
				}
		}
	} @catch (NSException *e) { return nil; }
	
	if ([outArray count] == 0)
		return nil;
	else
		return outArray;
}

-(iTunesTrack *)getTrackForTitle:(NSString *)theTitle byArtist:(NSString *)theArtist {
	if (![self initiTunes])
		return nil;
	
	@try {
		SBElementArray *arr = (SBElementArray *)[[self getLibraryPlaylist] searchFor:theTitle only:iTunesESrASongs];
		for (iTunesTrack *track in arr) {
			// Use this to ignore case!
			if ([TBUtil string:[track artist] isEqualToString:theArtist]) // Make sure that we don't overwrite some other artist's song
				if ([TBUtil string:[track name] isEqualToString:theTitle]) // Make sure that we don't overwrite some other song e.g. [this song's name] (live)
				{
					// NSLog(@"%@ - %@ (%@)", [[track get] artist], [[track get] name], [track get]);
					return [track get];
				}
		}
	} @catch (NSException *e) { 
        return nil;
    }
	
	return nil;
}

#pragma mark -
#pragma mark Other stuff

-(BOOL)isiTunesRunning {
	if (![self initiTunes]) 
		return NO;
	@try {
		return [iTunes isRunning];
	}
	@catch (NSException *e) { return NO; }
	
	return NO;
}

-(iTunesApplication *)iTunesReference {
	if (iTunes && [iTunes isRunning])
		return iTunes;
	else
		return nil;
}

@end