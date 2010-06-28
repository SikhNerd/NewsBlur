//
//  FeedDetailViewController.m
//  NewsBlur
//
//  Created by Samuel Clay on 6/20/10.
//  Copyright 2010 NewsBlur. All rights reserved.
//

#import "FeedDetailViewController.h"
#import "NewsBlurAppDelegate.h"
#import "JSON.h"


@implementation FeedDetailViewController

@synthesize storyTitlesTable, feedViewToolbar, feedScoreSlider;
@synthesize stories;
@synthesize appDelegate;
@synthesize jsonString;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"Loaded Feed view: %@", appDelegate.activeFeed);
    
    [self fetchFeedDetail];
    
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    //[appDelegate showNavigationBar:animated];
    
	[super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
    //NSLog(@"Unloading detail view: %@", self);
    self.appDelegate = nil;
    self.jsonString = nil;
}

- (void)dealloc {
    [appDelegate release];
    [stories release];
    [jsonString release];
    [super dealloc];
}

#pragma mark -
#pragma mark Initialization

- (void)fetchFeedDetail {
    if ([appDelegate.activeFeed objectForKey:@"id"] != nil) {
        NSString *theFeedDetailURL = [[NSString alloc] initWithFormat:@"http://www.newsblur.com/reader/load_single_feed/?feed_id=%@", 
                                      [appDelegate.activeFeed objectForKey:@"id"]];
        //NSLog(@"Url: %@", theFeedDetailURL);
        NSURL *urlFeedDetail = [NSURL URLWithString:theFeedDetailURL];
        [theFeedDetailURL release];
        jsonString = nil;
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL: urlFeedDetail];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [connection release];
        [request release];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data 
{   
	if(jsonString == nil) {
        jsonString = [[NSMutableString alloc] 
                      initWithData:data 
                      encoding:NSUTF8StringEncoding];
        
	} else {
		NSMutableString *temp_string = [[NSMutableString alloc] 
                                        initWithString:jsonString];
		
		[jsonString release];
		jsonString = [[NSMutableString alloc] 
                      initWithData:data 
                      encoding:NSUTF8StringEncoding];
		[temp_string appendString:jsonString];
        
		[jsonString release];
		jsonString = [[NSMutableString alloc] initWithString: temp_string];
		[temp_string release];
        
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSDictionary *results = [[NSDictionary alloc] 
                             initWithDictionary:[jsonString JSONValue]];
	
    NSArray *storiesArray = [[NSArray alloc] 
                             initWithArray:[results objectForKey:@"stories"]];
    [appDelegate setActiveFeedStories:storiesArray];
    //NSLog(@"Stories: %d -- %@", [appDelegate.activeFeedStories count], [self storyTitlesTable]);
	[[self storyTitlesTable] reloadData];
    
    [storiesArray release];
    [results release];
	[jsonString release];
}


#pragma mark -
#pragma mark Table View - Feed List

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //NSLog(@"Stories: %d", [appDelegate.activeFeedStories count]);
    return [appDelegate.activeFeedStories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *SimpleTableIdentifier = @"SimpleTableIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SimpleTableIdentifier];
	if (cell == nil) {
		
		cell = [[[UITableViewCell alloc] 
				 initWithStyle:UITableViewCellStyleDefault
				 reuseIdentifier:SimpleTableIdentifier] autorelease];
	}
    
    cell.textLabel.text = [[appDelegate.activeFeedStories objectAtIndex:indexPath.row] 
                           objectForKey:@"story_title"];
//	
//	int section_index = 0;
//	for (id f in self.dictFoldersArray) {
//		// NSLog(@"Cell: %i: %@", section_index, f);
//		if (section_index == indexPath.section) {
//			NSArray *feeds = [self.dictFolders objectForKey:f];
//			// NSLog(@"Cell: %i: %@: %@", section_index, f, [feeds objectAtIndex:indexPath.row]);
//			cell.textLabel.text = [[feeds objectAtIndex:indexPath.row] 
//								   objectForKey:@"feed_title"];
//			return cell;
//		}
//		section_index++;
//	}
//	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [appDelegate setActiveStory:[[appDelegate activeFeedStories] objectAtIndex:indexPath.row]];
    NSLog(@"Active Story: %@", [appDelegate activeStory]);
	[appDelegate loadStoryDetailView];
	
}

@end