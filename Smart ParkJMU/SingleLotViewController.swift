//
//  SingleLotViewController.swift
//  Smart ParkJMU
//
//  Created by Riley Sung on 11/10/15.
//  Copyright © 2015 Riley Sung. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class SingleLotViewController: UIViewController, UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate  {
    
    var refreshControl:UIRefreshControl!
    
    // Lot instance variables
    var lot = NSDictionary()
    var lotId: Int = 91235
    var lotPropertyNames: NSMutableArray = []
    var lotPropertyInfo: NSMutableArray = []
    
    var unique_tag_ids = Array<String>()
    var occupied_spots = Int()
    
    
    
    
    
    // Lot Times instance variables
    let userPermitTypes = ["Commuter", "Resident", "Red Zone", "Blue Zone", "Freshman"]
    var selectedPermitType: String = "Commuter"
    var selectedLotTimesForPermit: NSDictionary = [:]
    var parsedLotTimes = Dictionary<String, Dictionary<String, String>>()
    
    // Lot Labels
    @IBOutlet weak var lotNameLabel: UILabel!
    @IBOutlet weak var lotLocationLabel: UILabel!
    @IBOutlet weak var lotGeneralSpotInfoLabel: UILabel!
    @IBOutlet weak var lotTotalSpotInfoLabel: UILabel!
    @IBOutlet weak var permitTypeLotTimesPicker: UIPickerView!
    
    // Lot Times Labels
    @IBOutlet weak var monThurTitleLabel: UILabel!
    @IBOutlet weak var monThurHoursAvailabilityLabel: UILabel!
    @IBOutlet weak var fridayTitleLabel: UILabel!
    @IBOutlet weak var fridayHoursAvailabilityLabel: UILabel!
    @IBOutlet weak var satSunTitleLabel: UILabel!
    @IBOutlet weak var satSunHoursAvailabilityLabel: UILabel!
    @IBOutlet weak var timeLoadingHoursAvailabilityLabel: UILabel!
    @IBOutlet weak var eta: UILabel!
    @IBOutlet weak var backupLot: UILabel!
    
    // varialble for probability 
    var unwrapped_eta = Int()
    var historical_current_available = Int()
    var historical_arrival_available = Int()
    var historical_rate = Int()
    var lot_capacity = Int()
    
    @IBOutlet weak var probability: UILabel!
    @IBAction func update(sender: AnyObject) {
        calculateProbability(self.lot_capacity)
        print("LOT CAP", self.lot_capacity)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        loadMap()

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    
    // Function run when view is loading
    func setup() {
        
        // Sets the view controller as the datasource and delegate for the lot times picker
        self.permitTypeLotTimesPicker.delegate = self
        self.permitTypeLotTimesPicker.dataSource = self
        
        // Hides Error Labels
        hideTimeLabels()
        
        // Sets lot variable to returned lot from GET request getLotData from lot id
        lot = SingleLotViewController.getLotData(lotId)[0] as! NSDictionary
        
        // Sets lot name and location to lot name and location returned from GET request getLotData from lot id
        lotNameLabel.text = lot["Lot_Name"] as? String
        lotLocationLabel.text = lot["Location"] as? String
        backupLot.text = lot["Backup"] as? String
        
        // Get lot Latitude and Longitude
        //let LotLatitude = lot["Latitude"] as? Double
        //let LotLongitude = lot["Longitude"] as? Double
        
       
        
        // Sets lot names and spot availabilities array to be displayed
        updateLotNames()
        updateLotSpotsInfo()
        
        // Sets lot's hours of availability array
        selectedLotTimesForPermit = getLotTimeForPermitType(selectedPermitType, lotId: lotId)[0] as! NSDictionary
        
        // Parses lot's hours of availability array
        parseLotTimes(selectedLotTimesForPermit)
        
        // Goes through lot hours of availability array and displays times
        updateLotTimes()
        

    }
    
    
    // Finding Location ************************
    
        
    @IBOutlet weak var map: MKMapView!
    
    let locationManager = CLLocationManager()
    var manager:CLLocationManager!
    var myLocations: [CLLocation] = []
    
    func loadMap() {
        //   Code for getting the current location
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
        
        //Setup our Map View
        map.delegate = self
        map.mapType = MKMapType.Satellite
        map.showsUserLocation = true
    }
    
    func locationManager(manager:CLLocationManager, didUpdateLocations locations:[CLLocation]) {
        
        myLocations.append(locations[0] )
        
        let currentLocation = map.userLocation.coordinate
        
        let mapSpan = MKCoordinateSpanMake(0.01, 0.01)
        
        let mapRegion = MKCoordinateRegionMake(currentLocation, mapSpan)
        
        self.map.setRegion(mapRegion, animated: true)
        
        let userLocation = CLLocationCoordinate2D(latitude: currentLocation.latitude as Double, longitude: currentLocation.longitude as Double)
        
        
        // Sets lot variable to returned lot from GET request getLotData from lot id
        lot = SingleLotViewController.getLotData(lotId)[0] as! NSDictionary
        
        // Sets lot location from lot id
        let LotLatitude = lot["Latitude"]!.floatValue
        let LotLongitude = lot["Longitude"]!.floatValue
        let location = CLLocationCoordinate2D(latitude: Double(LotLatitude), longitude: Double(LotLongitude))
        
        // Calculate Transit ETA Request
        let request = MKDirectionsRequest()
        
        /* Source MKMapItem */
        let sourceItem = MKMapItem(placemark: MKPlacemark(coordinate: userLocation , addressDictionary: nil))
        request.source = sourceItem
        
        /* Destination MKMapItem */
        let destinationItem = MKMapItem(placemark: MKPlacemark(coordinate: location, addressDictionary: nil))
        request.destination = destinationItem
        request.requestsAlternateRoutes = false
        
        // Looking for Transit directions, set the type to Transit
        request.transportType = .Automobile
        
        // Center the map region around the restaurant coordinates
        map.setCenterCoordinate(location, animated: true)
        
        
        var eta = 0
        
        // You use the MKDirectionsRequest object constructed above to initialise an MKDirections object
        let directions = MKDirections(request: request)
        directions.calculateETAWithCompletionHandler { (etaResponse, error) -> Void in
            if let error = error {
                print("Error while requesting ETA : \(error.localizedDescription)")
            }else{
                eta = Int((etaResponse?.expectedTravelTime)!/60)
                self.eta.text = "ETA: \(eta) mins"
                self.unwrapped_eta = eta
                
                
            }
            
        }
        
        
    }
    

    func calculateProbability(lotCapacity: Int) {
        // data variables retrieved and saved as global variables 
        
        // Current Available Spots: self.occupied_spots
        // ETA from current location to selected Lot: self.unwrapped_eta
        // Historical Available Sptos @ arrival: self.historical_arrival_available
        // Historical Available Spots @ current time: self.historical_current_available
        
        
        // call todays date function
        let todaysDate = getTodaysDate()
        
        // Get arrival time based on calculated ETA
        let arrivalTime = getArrivalTime(self.unwrapped_eta)
//        let newarrivalTime = getArrivalTime(700)
        
        // call getHistoricalData function format (lotID, todaysDate, current time). This will set self.historical_available
        getHistoricalData(1, day: todaysDate, time: arrivalTime)

        
        // get probability
        if self.historical_arrival_available == 0 {
            // set probability label to probability
            self.probability.text = "No available spots"
        }else{
            let available = Double(self.historical_arrival_available)
            let getProbability: Double = 100 - (((Double(lotCapacity) - available) / Double(lotCapacity)) * 100)
            // set probability label to probability
            self.probability.text = "\(round(getProbability)) %"
        }
        
        
        // historical_rate is the available spots 30 minutes in the future
        
        print("HISTORICAL Arrival:", self.historical_arrival_available)
        
        
        
        
        
    }
    
    
    
    // function to get historical data for a specific lot at a specific time. will set historical_available to the available spots
    func getHistoricalData(lotId: Int, day: Int, time: String) {
        // connect to the historical data API
        let requestURL: NSURL = NSURL(string: "http://127.0.0.1:5000/")!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL)
        let session = NSURLSession.sharedSession()
        let new_task = session.dataTaskWithRequest(urlRequest) {
            (data, response, error) -> Void in
            
            let httpResponse = response as! NSHTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
                //print("File downloaded successfully.")
                do{
                    
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                    
                    if let historicalData = json as? [[String: AnyObject]] {
                        
                        for data in historicalData {
                            // get sign ID from JSON
                            if let SignID = data["SignID"] as? Int {
                                // ***filter by specific lot
                                if lotId == SignID {
                                    // get data on day and time
                                    if let RetrievalTime = data["RetrievalTime"] {
                                        
                                        // prepare RetrievalTime to be split into day and time
                                        let breakTime = RetrievalTime as! String + " "
                                        // split breakTime into Array of day and time
                                        let breakTimeArr = breakTime.componentsSeparatedByString(" ")
                                        
                                        // make variable for date
                                        let RetrievalDate = breakTimeArr[0]
                                        //make variable for time
                                        let RetrievalMinute = breakTimeArr[1]
                                        
                                        // convert formant HH:MM:SS.000000 to HH:MM:SS for RetrievalMinute
                                        let formatTimeSplitter = RetrievalMinute.componentsSeparatedByString(".")
                                        
                                        // get the correct formatted time
                                        let formatTimeLong = formatTimeSplitter[0]
                                        
                                        // hack way of getting just the HH:MM
                                        let truncated01 = formatTimeLong.substringToIndex(formatTimeLong.endIndex.predecessor())
                                        let truncated02 = truncated01.substringToIndex(truncated01.endIndex.predecessor())
                                        let formatTime = truncated02.substringToIndex(truncated02.endIndex.predecessor())
                                        
                                        // convert date into a number from 1-7
                                        if let numRetrievalDate = self.getDayOfWeek(RetrievalDate) {
                                            
                                            // ***filter further by specific day
                                            if day == numRetrievalDate {
                                                // filter to specified times
                                                
                                                // The arrival Time Historical
                                                if time == formatTime {
                                                    // get the available spots
                                                    if let Display = data["Display"] as? Int {
                                                        // return the amount of available spots 
                                                        self.historical_arrival_available = Display
                                                        
                                                    }
                                                }
                                                
                                                // the current Time Historical
                                                if formatTime == self.getCurrentTime() {
                                                    // get the available spots
                                                    if let Display = data["Display"] as? Int {
                                                        // return the amount of available spots
                                                        self.historical_current_available = Display
                                                        
                                                    }
                                                }
                                                
                                                // the current Time + 30 min Historical 
                                                // we can view +30 min as an ETA and use that function
                                                let arrivalRate = self.getArrivalTime(30)
                                                
                                                if formatTime == arrivalRate {
                                                    // get the available spots
                                                    if let Display = data["Display"] as? Int {
                                                        // return the amount of available spots
                                                        self.historical_rate = Display
                                                    }
                                                }
                                                
                                                
                                            }
                                        } else {
                                            print("bad input on date")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }catch {
                    print("Error with Json: \(error)")
                }
            }
        }
        new_task.resume()
        // connected!
    }

    // get todays date
    func getTodaysDate() -> Int{
        let fullDate = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todaysDateFormatted = dateFormatter.stringFromDate(fullDate)
        
        let todaysDate = getDayOfWeek(todaysDateFormatted)
        
        return todaysDate!
    }
    
    // get current time 
    func getCurrentTime() -> String {
        let fullDate = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let currentTime = dateFormatter.stringFromDate(fullDate)
        
        return currentTime

    }
    
    // given an ETA this function will return a time that is equal to current time + eta
    func getArrivalTime(eta:Int) -> String{
        let fullDate = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let arrivalDate = calendar.dateByAddingUnit(.Minute, value: eta, toDate: fullDate, options: [])
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let arrivalTime = dateFormatter.stringFromDate(arrivalDate!)
        
        return arrivalTime
    }

    
    // get day of the week as int from 1-7 from a inputted string
    func getDayOfWeek(today:String)->Int? {
        
        let formatter  = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let todayDate = formatter.dateFromString(today) {
            let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
            let myComponents = myCalendar.components(.Weekday, fromDate: todayDate)
            let weekDay = myComponents.weekday
            return weekDay
        } else {
            return nil
        }
    }
    
    
    
    func displayLocationInfo(placemark: CLPlacemark){
        self.locationManager.stopUpdatingLocation()
        
        print(placemark.locality)
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error" + error.localizedDescription)
    }
    
    // *****************************************

    
    
    
    @IBAction func didPressRefresh(sender: AnyObject) {
        
        lot = SingleLotViewController.getLotData(lotId)[0] as! NSDictionary
        
        updateLotSpotsInfo()
        
    }
    
    func hideTimeLabels() {
        monThurTitleLabel.hidden = true
        monThurHoursAvailabilityLabel.hidden = true
        fridayTitleLabel.hidden = true
        fridayHoursAvailabilityLabel.hidden = true
        satSunTitleLabel.hidden = true
        satSunHoursAvailabilityLabel.hidden = true
        timeLoadingHoursAvailabilityLabel.hidden = false
    }
    
    func showTimeLabels() {
        monThurTitleLabel.hidden = false
        monThurHoursAvailabilityLabel.hidden = false
        fridayTitleLabel.hidden = false
        fridayHoursAvailabilityLabel.hidden = false
        satSunTitleLabel.hidden = false
        satSunHoursAvailabilityLabel.hidden = false
        timeLoadingHoursAvailabilityLabel.hidden = true
    }
    
    // Creates lot names object to be displayed
    func updateLotNames () {
        // Reset lotPropertyNames Array
        lotPropertyNames = []
        
        lotPropertyNames.addObject("Handicap")
        lotPropertyNames.addObject("Metered")
        lotPropertyNames.addObject("Motorcycle")
        lotPropertyNames.addObject("Faculty")
        lotPropertyNames.addObject("Visitor")
        lotPropertyNames.addObject("Housekeeping")
        lotPropertyNames.addObject("Service")
        lotPropertyNames.addObject("Hall Director")
        lotPropertyNames.addObject("Miscellaneous")
    }
    
    // Sets lot spots info object to be displayed
    func updateLotSpotsInfo () {
        // Reset lotPropertyInfo Array
        lotPropertyInfo = []
        lotPropertyInfo.addObject("\(lot["Handicap_Available"]!.integerValue) | \(lot["Handicap_Capacity"]!.integerValue)")
        lotPropertyInfo.addObject("\(lot["Metered_Available"]!.integerValue) | \(lot["Metered_Capacity"]!.integerValue)")
        lotPropertyInfo.addObject("\(lot["Motorcycle_Available"]!.integerValue) | \(lot["Motorcycle_Capacity"]!.integerValue)")
        lotPropertyInfo.addObject("\(lot["Faculty_Available"]!.integerValue) | \(lot["Faculty_Capacity"]!.integerValue)")
        lotPropertyInfo.addObject("\(lot["Visitor_Available"]!.integerValue) | \(lot["Visitor_Capacity"]!.integerValue)")
        lotPropertyInfo.addObject("\(lot["Housekeeping_Available"]!.integerValue) | \(lot["Housekeeping_Capacity"]!.integerValue)")
        lotPropertyInfo.addObject("\(lot["Service_Available"]!.integerValue) | \(lot["Service_Capacity"]!.integerValue)")
        lotPropertyInfo.addObject("\(lot["Hall_Director_Available"]!.integerValue) | \(lot["Hall_Director_Capacity"]!.integerValue)")
        lotPropertyInfo.addObject("\(lot["Misc_Available"]!.integerValue) | \(lot["Misc_Capacity"]!.integerValue)")
        
        
        
        // get spaces data from the reader
        let requestURL: NSURL = NSURL(string: "http://smartparkingapi.herokuapp.com/api/v1/spaces")!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(urlRequest) {
            (data, response, error) -> Void in
            
            let httpResponse = response as! NSHTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
                print("Everyone is fine, file downloaded successfully.")
                do{
                    // found_tag_id is an array of all tag ids found in each field_values string.
                    var found_tag_id = Array<String>()
                    
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                    
                    if let spaces = json["spaces"] as? [[String: AnyObject]] {
                        
                        for space in spaces {
                            
                            if let id_num = space["id"] as? Int {
                                
                                if let field_values = space["field_values"] as? String {
                                    print(id_num, field_values)
                                    
                                    let field_values_mod0 = field_values.stringByReplacingOccurrencesOfString(" ", withString: ",", options: NSStringCompareOptions.LiteralSearch, range: nil)
                                    let field_values_mod1 = field_values_mod0.stringByReplacingOccurrencesOfString("\r\n", withString: ",", options: NSStringCompareOptions.LiteralSearch, range: nil)
                                    
                                    print("remove spaces:", field_values_mod1)
                                    
                                    
                                    let field_values_Arr = field_values_mod1.componentsSeparatedByString(",")
                                    
                                    
                                    var j = 0
                                    for element in field_values_Arr{
                                        if(j%6 == 0 && element != ""){
                                            found_tag_id.append(element)
                                        }
                                        j = j + 1
                                    }
                                    
                                }
                                
                            }
                        }
                        
                    }
                
                    self.unique_tag_ids = Array(Set(found_tag_id))
                    self.occupied_spots = self.unique_tag_ids.count
                    print("Unique tag ids", self.unique_tag_ids)
                    print("number of occupied spots", self.occupied_spots)
                    
                    //** Update the views with the Space data
                    self.lotGeneralSpotInfoLabel.text = "\(self.lot["General_Available"]!.integerValue-self.occupied_spots) | \(self.lot["General_Capacity"]!.integerValue)"
                    self.lotTotalSpotInfoLabel.text = "\(self.lot["Total_Available"]!.integerValue - self.occupied_spots) | \(self.lot["Total_Capacity"]!.integerValue)"

                    // used to calculate probablility for given lot cap.
                    self.lot_capacity = self.lot["Total_Available"]!.integerValue
                    
                    
                }catch {
                    print("Error with Json: \(error)")
                }
                
            }
        }
        task.resume()
        // done with reader
        
        
        showTimeLabels()
    }
    
    // Sets labels to appropriate times from parsed lot times array
    func updateLotTimes() {
        
        monThurHoursAvailabilityLabel.text = compareHoursOfAvailability(parsedLotTimes["Mon-Thur"]!["Open"]!, date2: parsedLotTimes["Mon-Thur"]!["Closed"]!)
        fridayHoursAvailabilityLabel.text = compareHoursOfAvailability(parsedLotTimes["Friday"]!["Open"]!, date2: parsedLotTimes["Friday"]!["Closed"]!)
        satSunHoursAvailabilityLabel.text = compareHoursOfAvailability(parsedLotTimes["Sat-Sun"]!["Open"]!, date2: parsedLotTimes["Sat-Sun"]!["Closed"]!)
    
    }
    
    // Parses each lot hours of availabilities to display correctly
    func compareHoursOfAvailability(date1: String, date2: String) -> String {
        
        let df = NSDateFormatter()
        df.dateFormat = "h:mm a"
        df.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        
        if date1 != "Closed" || date2 != "Closed" {
            
            if df.dateFromString(date1)!
                .compare(df.dateFromString(date2)!) == NSComparisonResult.OrderedDescending {
                    
                    return "After \(date1)"
                    
            } else if df.dateFromString(date1)!
                .compare(df.dateFromString(date2)!) == NSComparisonResult.OrderedAscending {
                    
                    return "\(date1) - \(date2)"
                    
            } else {
                
                return "Open all day"
            }
            
        } else {
            
            return "Closed"
        }
    }
    
    // Parses lot information to be easily used
    func parseLotTimes(lotTimes: NSDictionary) {
        parsedLotTimes = ["Mon-Thur":["Open":"", "Closed":""], "Friday":["Open":"", "Closed":""], "Sat-Sun":["Open":"", "Closed":""]]
        var time: String
        
        let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "HH:mm:ss"
            dateFormatter.timeZone = NSTimeZone(name: "UTC")
        let df = NSDateFormatter()
            df.dateFormat = "h:mm a"
            df.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        
        for (key, value) in lotTimes {
            // Converts values to HH:MM AM/PM format if not time
            
            if value as? String != nil {
                let tempTime = dateFormatter.dateFromString( value as! String )!
                time = df.stringFromDate(tempTime)
            } else {
                time = "Closed"
            }
            
            // Created parsed object
            
            if key.containsString("Mon_Thur_Open") {
            
                parsedLotTimes["Mon-Thur"]!["Open"]?.appendContentsOf(time)

            } else if key.containsString("Mon_Thur_Closed") {
                
                parsedLotTimes["Mon-Thur"]!["Closed"]?.appendContentsOf(time)
            
            } else if key.containsString("Fri_Open") {
                
                parsedLotTimes["Friday"]!["Open"]?.appendContentsOf(time)
                
            } else if key.containsString("Fri_Closed") {
                
                parsedLotTimes["Friday"]!["Closed"]?.appendContentsOf(time)
                
            } else if key.containsString("Sat_Sun_Open") {
                
                parsedLotTimes["Sat-Sun"]!["Open"]?.appendContentsOf(time)
                
            } else if key.containsString("Sat_Sun_Closed") {
                
                parsedLotTimes["Sat-Sun"]!["Closed"]?.appendContentsOf(time)
            }
        }
    
    }
    
    // Region: GET methods
    
    
    // GET method for Lot information based on the selected lot id from previous view controller
    class func getLotData(lotId: Int) -> NSArray {
        
        var lotData = []
    
//        var responseString = ""
    
        let request = NSMutableURLRequest(URL: NSURL(string: "http://spacejmu.bitnamiapp.com/SPACEApiCalls/getLotData.php")!)
        
        request.HTTPMethod = "POST"
        
        let postString = "lotId=\(lotId)"
        
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let semaphore = dispatch_semaphore_create(0)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            guard error == nil && data != nil else {
                // check for fundamental networking error
                
                print("error=\(error)")
                
                return
                
            }
            
            do {
                
                let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                
                lotData = jsonResult as! NSArray
                
//                print("data: ", lotData)
                
            } catch {
                
                print ("JSON serialization failed")
            }
            
//                if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {
//                    // check for http errors
//                    
//                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
//                    
//                    print("response = \(response)")
//                    
//                }
//                
//                responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)! as String
//                
//                print("responseString =", responseString)
            
            
            dispatch_semaphore_signal(semaphore)
            
        }
        
        task.resume()
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
        
        // Check to ensure proper lot data is returned
        if lotId != 91235 {
            return lotData
        } else {
            print("Something went wrong when the lotId was passed in from ViewController")
            return lotData
        }
        
    }
    
    // GET method for getting lot times for specific lot and permit type
    func getLotTimeForPermitType(permitType: String, lotId: Int) -> NSArray {
        
        var lotTimeForPermitType = []
               
        let request = NSMutableURLRequest(URL: NSURL(string: "http://spacejmu.bitnamiapp.com/SPACEApiCalls/getSingleLotTime.php")!)
        
        let postString = "permitType=\(permitType)&lotId=\(lotId)"
        
        request.HTTPMethod = "POST"
        
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let semaphore = dispatch_semaphore_create(0)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            guard error == nil && data != nil else {
                // check for fundamental networking error
                
                print("error=\(error)")
                
                return
                
            }
            
            do {
                
                let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                lotTimeForPermitType = jsonResult as! NSArray
                
            } catch {
                
                print ("JSON serialization failed")

            }
            
                if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {
                    // check for http errors
                    print("response: \(response)")

                }            
            
            dispatch_semaphore_signal(semaphore)
            
        }
        
        task.resume()
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
        return lotTimeForPermitType
    }
    
    // Region: Table
    
    // Table configuration to display the number of rows for each lot returned from getLotData function
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lotPropertyNames.count
    }
    
    // Table configuration to display proper lot name and lot spots availabilities
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "GeneralTableViewCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! GeneralTableViewCell
        
        cell.lotPropertyNameLabel.text = lotPropertyNames[indexPath.row] as? String
        cell.lotPropertySpotInfoLabel.text = lotPropertyInfo[indexPath.row] as? String
        
        
        return cell
    }
    
    // Region: Picker
    
    // Picker configuration returns only 1 column
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Returns number of rows for number of permit types
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return userPermitTypes.count
    }
    
    // Picker configuration: sets font color
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        // Makes pickerView font color to purple
        var attributedString: NSAttributedString
        attributedString = NSAttributedString(string: userPermitTypes[row], attributes: [NSForegroundColorAttributeName : UIColor.purpleColor()])
        
        return attributedString
    }
    
    // Picker configuration: when row (permit type) is selected, returns lot hours of availability depending on selected permit type from GET request
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Selects permit type for lot/permit hours of availability ***Defaults to Commuter if none***
        if userPermitTypes[row] == "Red Zone" {
        
            selectedPermitType = "Red"
        
        } else if userPermitTypes[row] == "Blue Zone" {
            
            selectedPermitType = "Blue"

        } else {
            
            if selectedLotTimesForPermit != userPermitTypes {
                
                selectedPermitType = userPermitTypes[row]
            }
        }
        
        selectedLotTimesForPermit = getLotTimeForPermitType(selectedPermitType, lotId: lotId)[0] as! NSDictionary
        
        parseLotTimes(selectedLotTimesForPermit)
        
        // Hides lot information briefly to mimick loading
        hideTimeLabels()
        let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 1 * Int64(NSEC_PER_SEC))
        dispatch_after(time, dispatch_get_main_queue()) {
            self.updateLotTimes()
            self.showTimeLabels()
        }
        

    }

}
