

#import "HomeViewController.h"
#import "SBURLSessionService.h"

@interface HomeViewController () < UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating > {
    
    NSArray *responseArray, *filterResponseArray;
    UITableView *tblView;
    UISearchController *searchController;
    BOOL isFilterText;
    
}

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Home";
    [self setUpUserInterface];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [SBURLSessionService getGeonamesWithNorth:@"44.1"
                                        south:@"-9.9"
                                         east:@"-22.4"
                                         west:@"55.2"
                                         lang:@"de"
                                     userName:@"demo"
                                 onCompletion:^(id data) {
                                     
                                     NSDictionary *responseData = data;

                                     if ([responseData valueForKey:@"geonames"]) {
                                         responseArray = [[responseData valueForKey:@"geonames"] valueForKey:@"toponymName"];
                                         
                                     } else {
                                         responseArray = @[@"USA", @"Bahamas", @"Brazil", @"Canada", @"Republic of China", @"Cuba", @"Egypt", @"Fiji", @"France", @"Germany", @"Iceland", @"India", @"Indonesia", @"Jamaica", @"Kenya", @"Madagascar", @"Mexico", @"Nepal", @"Oman", @"Pakistan", @"Poland", @"Singapore", @"Somalia", @"Switzerland", @"Turkey", @"UAE", @"Vatican City"];
                                     }
                                     
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         
                                         [tblView reloadData];
                                     });
                                     
                                 } onFailure:^(NSError *error) {
                                     
                                     NSLog(@"ERROR %@",error.localizedDescription);
                                 }];
    
}

#pragma mark SetUp User Interface
-(void)setUpUserInterface {
    
    tblView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tblView.delegate = self;
    tblView.dataSource = self;
    tblView.showsVerticalScrollIndicator = NO;
    tblView.backgroundColor = [UIColor clearColor];
    tblView.tableHeaderView.userInteractionEnabled = YES;
    tblView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:tblView];
    
    
    searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    searchController.searchResultsUpdater = self;
    searchController.dimsBackgroundDuringPresentation = NO;
    searchController.searchBar.delegate = self;
    self.definesPresentationContext = YES;
    [searchController.searchBar sizeToFit];
    tblView.tableHeaderView = searchController.searchBar;
    [tblView reloadData];

    
}

#pragma mark TableView Delegate And DataSource Function
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (isFilterText) {
        return [filterResponseArray count];
    } else {
        return [responseArray count];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    static NSString *CellIdentifier = @"CELL-IDENTIFIER";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        
    }
    
    if (isFilterText) {
        cell.textLabel.text =  filterResponseArray[indexPath.section];
        
    } else {
        
        cell.textLabel.text =  responseArray[indexPath.section];
    }
    

    return cell;
    
}

#pragma mark SearchBar Delegate Function
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText isEqualToString:@""]) {
        isFilterText = NO;
    } else {
        isFilterText = YES;
        [self filterTableViewForEnterText:searchText];
    }
    
    [tblView reloadData];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    isFilterText = NO;
    [tblView reloadData];
}

-(void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    
    [self updateSearchResultsForSearchController:searchController];
}
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
}

-(void)filterTableViewForEnterText:(NSString*)searchText {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@",searchText];
   filterResponseArray = [responseArray filteredArrayUsingPredicate:predicate];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
