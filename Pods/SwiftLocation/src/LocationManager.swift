//
//  SwiftLocation.swift
//  SwiftLocations
//
// Copyright (c) 2016 Daniele Margutti
// Web:			http://www.danielemargutti.com
// Mail:		me@danielemargutti.com
// Twitter:		@danielemargutti
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import CoreLocation
import MapKit

public class LocationManager: NSObject, CLLocationManagerDelegate {
	//MARK: Public Variables
	private(set) var lastLocation: CLLocation?

		/// Shared instance of the location manager
	public static let shared = LocationManager()
	
		/// A Boolean value indicating whether the app wants to receive location updates when suspended. By default it's false.
		/// See .allowsBackgroundLocationUpdates of CLLocationManager for a detailed description of this var.
	public var allowsBackgroundEvents: Bool = false {
		didSet {
			if #available(iOS 9.0, *) {
				if let backgroundModes = NSBundle.mainBundle().objectForInfoDictionaryKey("UIBackgroundModes") as? NSArray {
					if backgroundModes.containsObject("location") {
						self.manager.allowsBackgroundLocationUpdates = allowsBackgroundEvents
					} else {
						print("You must provide location in UIBackgroundModes of Info.plist in order to use .allowsBackgroundEvents")
					}
				}
			}
		}
	}
	
		/// A Boolean value indicating whether the location manager object may pause location updates.
		/// When this property is set to YES, the location manager pauses updates (and powers down the appropriate hardware)
		/// at times when the location data is unlikely to change.
		/// You can observe this event by setting the appropriate handler on .onPause() method of the request.
	public var pausesLocationUpdatesWhenPossible: Bool = true {
		didSet {
			self.manager.pausesLocationUpdatesAutomatically = pausesLocationUpdatesWhenPossible
		}
	}
	
		/// When computing heading values, the location manager assumes that the top of the device in portrait mode
		/// represents due north (0 degrees) by default. By default this value is set to .FaceUp.
		/// The original reference point is retained, changing this value has no effect on orientation reference point.
		/// Changing the value in this property affects only those heading values reported after the change is made.
	public var headingOrientation: CLDeviceOrientation = .FaceUp {
		didSet {
			self.updateHeadingService()
		}
	}
	
	//MARK: Private Variables
	private let manager: CLLocationManager
		/// The list of all requests to observe current location changes
	private(set) var locationObservers: [LocationRequest] = []
		/// The list of all requests to observe device's heading changes
	private(set) var headingObservers: [HeadingRequest] = []
		/// THe list of all requests to oberver significant places visits
	private(set) var visitsObservers: [VisitRequest] = []

	//MARK: Init
	private override init() {
		self.manager = CLLocationManager()
		super.init()
		self.manager.delegate = self
	}
	
	//MARK: [Public Methods] Interesting Visits
	
	/**
	Calling this method begins the delivery of visit-related events to your app.
	Enabling visit events for one location manager enables visit events for all other location manager objects in your app.
	If your app is terminated while this service is active, the system relaunches your app when new visit events are ready to be delivered.
	
	- parameter handler: handler called when a new visit is intercepted
	
	- returns: the request object which represent the current observer. You can use it to pause/resume or stop the observer itself.
	*/
	public func observeInterestingPlaces(onDidVisit handler: VisitHandler?) -> VisitRequest {
		let request = VisitRequest(onDidVisit: handler)
		self.addVisitRequest(request)
		return request
	}
	
	/**
	Stop a running visit's observer by passing it's request object
	
	- parameter request: request to stop
	
	- returns: true if request is part of the queue and it was stopped, no otherwise
	*/
	public func stopObservingInterestingPlaces(request: VisitRequest) -> Bool {
		if let idx = self.visitsObservers.indexOf({$0.UUID == request.UUID}) {
			self.visitsObservers[idx].isEnabled = false
			self.visitsObservers.removeAtIndex(idx)
			self.updateVisitingService()
			return true
		}
		return false
	}
	
	//MARK: [Public Methods] Locations
	
	/**
	Start observing current location changes.
	
	- parameter accuracy:  location's accuracy you want to receive
	- parameter frequency: frequency of updates
	- parameter onSuccess: handler to call when a valid location is received
	- parameter onError:   handler to call when an erorr is ocurred. When an error is generated request fails and you stop to receive updates.
	
	- returns: request added to location manager. You can use this reference to pause, resume, stop or change handlers to call
	*/
	public func observeLocations(accuracy: Accuracy, frequency: UpdateFrequency, onSuccess: LocationHandlerSuccess, onError: LocationHandlerError) -> LocationRequest {
		
		let request = LocationRequest(withAccuracy: accuracy, andFrequency: frequency)
		request.onSuccess(onSuccess)
		request.onError(onError)
		request.start()
		return request
	}
	
	/**
	Stop observing a running request for location changes
	
	- parameter request: request to stop
	
	- returns: true if location is running and it was stopped, false otherwise
	*/
	public func stopObservingLocation(request: LocationRequest) -> Bool {
		if let idx = self.locationObservers.indexOf({$0.UUID == request.UUID}) {
			self.locationObservers.removeAtIndex(idx)
			self.updateLocationUpdateService()
			return true
		}
		return false
	}
	
	/**
	When you don't need to get an accurate location and you don't want to use the device's hardware you can use this function
	to get an approximate location of the device by it's IP address. This function does not consume battery power but require
	a valid internet connection.
	
	- parameter sHandler: handler to call when location was determined successfully
	- parameter fHandler: handler to call when location was failed to be determined
	*/
	public func locateByIPAddress(onSuccess sHandler: RLocationSuccessHandler, onError fHandler: RLocationErrorHandler) {
		let URLRequest = NSURLRequest(URL: NSURL(string: "http://ip-api.com/json")!, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5)
		let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
		let session = NSURLSession(configuration: sessionConfig)
		let task = session.dataTaskWithRequest(URLRequest) { (data, response, error) in
			if let data = data as NSData? {
				do {
					if let resultDict = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? NSDictionary {
						let placemark = try self.parseIPLocationData(resultDict)
						sHandler(placemark)
					}
				} catch let error as LocationError {
					fHandler(error)
				} catch let error as NSError {
					fHandler(LocationError.LocationManager(error: error))
				}
			}
		}
		task.resume()
	}
	
	//MARK: [Public Methods] Heading
	
	/**
	Starts the generation of updates that report the user’s current heading.
	
	- parameter withInterval: The minimum angular change (measured in degrees) required to generate new heading events. By default this value is 1, but you can set it to nil in order to get all movements.
	- parameter sHandler:     handler to call when a new heading value is generated
	- parameter eHandler:     handler to call when an error has occurred. observing is aborted automatically.
	
	- returns: a new request observer you can use to manage the activity of the observer itself
	*/
	public func observeHeading(withInterval i: CLLocationDegrees? = 1, onSuccess sHandler: HeadingHandlerSuccess, onError eHandler: HeadingHandlerError) -> HeadingRequest {
		let request = HeadingRequest(onSuccess: sHandler, onError: eHandler)
		request.degreesInterval = i
		request.start()
		return request
	}
	
	/**
	Stop a running observer for heading changes
	
	- parameter request: request to stop
	
	- returns: true if request is part of the queue and it was stopped, false otherwise
	*/
	public func stopObservingHeading(request: HeadingRequest) -> Bool {
		if let idx = self.headingObservers.indexOf({$0.UUID == request.UUID}) {
			self.headingObservers.removeAtIndex(idx)
			self.updateHeadingService()
			return true
		}
		return false
	}
	
	//MARK: [Public Methods] Reverse Address/Location
	
	/**
	This function make a reverse geocoding from an address string to a valid geographic place (returned as CLPlacemark instance).
	You can use both Apple's own service or Google service to get this value.
	
	- parameter service:  service to use, If not passed .Apple is used
	- parameter address:  address string to reverse
	- parameter sHandler: handler called when location reverse operation was completed successfully. It contains a valid CLPlacemark instance.
	- parameter fHandler: handler called when the operation fails due to an error.
	*/
	public func reverseAddress(service service :ReverseService = .Apple, address: String, onSuccess sHandler: RLocationSuccessHandler, onError fHandler: RLocationErrorHandler) {
		switch service {
		case .Apple:
			self.reverseAddressUsingApple(address, onSuccess: sHandler, onError: fHandler)
		case .Google:
			self.reverseAddressUsingGoogle(address, onSuccess: sHandler, onError: fHandler)
		}
	}
	
	/**
	This function make a geocoding request returning a valid geographic place (returned as CLPlacemark instance) from a passed pair of
	coordinates.
	
	- parameter service:     service to use. If not passed .Google is used
	- parameter coordinates: coordinates to search
	- parameter sHandler:    handler called when location geocoding succeded and a valid CLPlacemark is returned
	- parameter fHandler:    handler called when location geocoding fails due to an error
	*/
	public func reverseLocation(service service :ReverseService = .Apple, coordinates: CLLocationCoordinate2D, onSuccess sHandler: RLocationSuccessHandler, onError fHandler: RLocationErrorHandler) {
		let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
		self.reverseLocation(service: service, location: location, onSuccess: sHandler, onError: fHandler)
	}
	
	/**
	This function make a geocoding request returning a valid geographic place (returned as CLPlacemark instance) from a passed location object.
	
	- parameter service:  service to use. If not passed .Google is used
	- parameter location: location to search
	- parameter sHandler:    handler called when location geocoding succeded and a valid CLPlacemark is returned
	- parameter fHandler:    handler called when location geocoding fails due to an error
	*/
	public func reverseLocation(service service :ReverseService = .Apple, location: CLLocation, onSuccess sHandler: RLocationSuccessHandler, onError fHandler: RLocationErrorHandler) {
		switch service {
		case .Apple:
			self.reverseLocationUsingApple(location, onSuccess: sHandler, onError: fHandler)
		case .Google:
			self.reverseLocationUsingGoogle(location, onSuccess: sHandler, onError: fHandler)
		}
	}

	
	//MARK: [Private Methods] Heading/Location
	
	internal func addVisitRequest(handler: VisitRequest) -> VisitRequest {
		if self.visitsObservers.indexOf({$0.UUID == handler.UUID}) == nil {
			self.visitsObservers.append(handler)
			handler.isEnabled = true
		}
		self.updateVisitingService()
		return handler
	}
	
	internal func addHeadingRequest(handler: HeadingRequest) -> HeadingRequest {
		if self.headingObservers.indexOf({$0.UUID == handler.UUID}) == nil {
			headingObservers.append(handler)
		}
		self.updateHeadingService()
		return handler
	}
	
	internal func addLocationRequest(handler: LocationRequest) -> LocationRequest {
		if self.locationObservers.indexOf({$0.UUID == handler.UUID}) == nil {
			locationObservers.append(handler)
		}
		self.updateLocationUpdateService()
		return handler
	}
	
	internal func updateHeadingService() {
		let enabledObservers = headingObservers.filter({ $0.isEnabled == true })
		if enabledObservers.count == 0 {
			self.manager.stopUpdatingHeading()
			return
		}
		
		let minAngle = enabledObservers.minElement({return ($0.degreesInterval == nil || $0.degreesInterval < $1.degreesInterval) })!.degreesInterval
		self.manager.headingFilter = (minAngle == nil ? kCLDistanceFilterNone : minAngle!)
		self.manager.headingOrientation = self.headingOrientation
		self.manager.startUpdatingHeading()
	}
	
	internal func updateVisitingService() {
		let enabledObservers = visitsObservers.filter({ $0.isEnabled == true })
		if enabledObservers.count == 0 {
			self.manager.stopMonitoringVisits()
		} else {
			self.manager.startMonitoringVisits()
		}
	}
	
	internal func updateLocationUpdateService() {
		let enabledObservers = locationObservers.filter({ $0.isEnabled == true })
		if enabledObservers.count == 0 {
			self.manager.stopUpdatingLocation()
			self.manager.stopMonitoringSignificantLocationChanges()
			return
		}
		
		do {
			let requestShouldBeMade = try self.requestLocationServiceAuthorizationIfNeeded()
			if requestShouldBeMade == true {
				return
			}
		} catch let err {
			self.cleanUpAllLocationRequests( (err as! LocationError) )
		}
		
		var globalAccuracy: Accuracy?
		var globalFrequency: UpdateFrequency?
		var activityType: CLActivityType = .Other
		
		for (_,observer) in enabledObservers.enumerate() {
			if (globalAccuracy == nil || observer.accuracy.rawValue > globalAccuracy!.rawValue) {
				globalAccuracy = observer.accuracy
			}
			if (globalFrequency == nil || observer.frequency < globalFrequency) {
				globalFrequency = observer.frequency
			}
			activityType = (observer.activityType.rawValue > activityType.rawValue ? observer.activityType : activityType)
		}
		
		self.manager.activityType = activityType
		
		if (globalFrequency == .Significant) {
			self.manager.stopUpdatingLocation()
			self.manager.startMonitoringSignificantLocationChanges()
		} else {
			self.manager.stopMonitoringSignificantLocationChanges()
			self.manager.startUpdatingLocation()
		}
	}
	
	private func requestLocationServiceAuthorizationIfNeeded() throws -> Bool {
		if CLLocationManager.locationAuthStatus == .Authorized(always: true) || CLLocationManager.locationAuthStatus == .Authorized(always: false) {
			return false
		}
		
		switch CLLocationManager.bundleLocationAuthType {
		case .None:
			throw LocationError.MissingAuthorizationInPlist
		case .Always:
			self.manager.requestAlwaysAuthorization()
			self.allowsBackgroundEvents = true
			self.manager.pausesLocationUpdatesAutomatically = self.pausesLocationUpdatesWhenPossible
		case .OnlyInUse:
			self.allowsBackgroundEvents = false
			self.manager.pausesLocationUpdatesAutomatically = self.pausesLocationUpdatesWhenPossible
			self.manager.requestWhenInUseAuthorization()
		}
		
		self.pauseAllLocationRequest()
		return true
	}
	
	private func pauseAllLocationRequest() {
		self.locationObservers.forEach { handler in
			handler.pause()
		}
	}
	
	private func cleanUpAllLocationRequests(error: LocationError) {
		self.locationObservers.forEach { handler in
			handler.didReceiveEventFromLocationManager(error: error, location: nil)
		}
	}
	
	private func startAllLocationRequests() {
		self.locationObservers.forEach { handler in
			handler.start()
		}
	}
	
	//MARK: [Private Methods] Location Manager Delegate
	
	@objc public func locationManager(manager: CLLocationManager, didVisit visit: CLVisit) {
		self.visitsObservers.forEach { handler in handler.onDidVisitPlace?(visit) }
	}
	
	@objc public func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
		switch status {
		case .Denied, .Restricted:
			self.cleanUpAllLocationRequests(LocationError.AuthorizationDidChange(newStatus: status))
		case .AuthorizedAlways, .AuthorizedWhenInUse:
			self.startAllLocationRequests()
		default:
			break
		}
	}
	
	@objc public func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
		self.locationObservers.forEach { handler in
			handler.didReceiveEventFromLocationManager(error: LocationError.LocationManager(error: error), location: nil)
		}
	}
	
	@objc public func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		self.lastLocation = locations.maxElement({ (l1, l2) -> Bool in
			return l1.timestamp.timeIntervalSince1970 < l2.timestamp.timeIntervalSince1970}
		)
		self.locationObservers.forEach { handler in
			handler.didReceiveEventFromLocationManager(error: nil, location: self.lastLocation)
		}
	}
	
	public func locationManagerDidPauseLocationUpdates(manager: CLLocationManager) {
		self.locationObservers.forEach { handler in
			handler.onPausesHandler?(handler.lastLocation)
		}
	}
	
	//MARK: [Private Methods] Heading
	
	public func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
		self.headingObservers.forEach { headingRequest in headingRequest.didReceiveEventFromManager(nil, heading: newHeading) }
	}
	
	public func locationManagerShouldDisplayHeadingCalibration(manager: CLLocationManager) -> Bool {
		for (_,request) in self.headingObservers.enumerate() {
			if let calibrationHandler = request.onCalibrationRequired {
				if calibrationHandler() == true { return true }
			}
			return false
		}
		return false
	}
	
	//MARK: [Private Methods] Reverse Address/Location
	
	private func reverseAddressUsingApple(address: String, onSuccess sHandler: RLocationSuccessHandler, onError fHandler: RLocationErrorHandler) {
		let geocoder = CLGeocoder()
		geocoder.geocodeAddressString(address, completionHandler: { (placemarks, error) in
			if error != nil {
				fHandler(LocationError.LocationManager(error: error))
			} else {
				if let placemark = placemarks?[0] {
					sHandler(placemark)
				} else {
					fHandler(LocationError.NoDataReturned)
				}
			}
		})
	}
	
	private func reverseAddressUsingGoogle(address: String, onSuccess sHandler: RLocationSuccessHandler, onError fHandler: RLocationErrorHandler) {
		let APIURLString = "https://maps.googleapis.com/maps/api/geocode/json?address=\(address)"
			.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
		let APIURL = NSURL(string: APIURLString)
		let APIURLRequest = NSURLRequest(URL: APIURL!)
		let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
		let session = NSURLSession(configuration: sessionConfig)
		let task = session.dataTaskWithRequest(APIURLRequest) { (data, response, error) in
			if error != nil {
				fHandler(LocationError.LocationManager(error: error))
			} else {
				if data != nil {
					let jsonResult: NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as! NSDictionary
					let (error,noResults) = self.validateGoogleJSONResponse(jsonResult)
					if noResults == true { // request is ok but not results are returned
						fHandler(LocationError.NoDataReturned)
					} else if (error != nil) { // something went wrong with request
						fHandler(LocationError.LocationManager(error: error))
					} else { // we have some good results to show
						let placemark = self.parseGoogleLocationData(jsonResult)
						sHandler(placemark)
					}
				}
			}
		}
		task.resume()
	}
	
	private func reverseLocationUsingApple(location: CLLocation,  onSuccess sHandler: RLocationSuccessHandler, onError fHandler: RLocationErrorHandler) {
		let geocoder = CLGeocoder()
		geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
			if (placemarks?.count > 0) {
				let placemark: CLPlacemark! = placemarks![0]
				if (placemark.locality != nil && placemark.administrativeArea != nil) {
					sHandler(placemark)
				}
			} else {
				fHandler(LocationError.LocationManager(error: error))
			}
		}
	}
	
	private func reverseLocationUsingGoogle(location: CLLocation,  onSuccess sHandler: RLocationSuccessHandler, onError fHandler: RLocationErrorHandler) {
		let APIURLString = "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(location.coordinate.latitude),\(location.coordinate.longitude)"
			.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
		let APIURL = NSURL(string: APIURLString)
		let APIURLRequest = NSURLRequest(URL: APIURL!)
		let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
		let session = NSURLSession(configuration: sessionConfig)
		let task = session.dataTaskWithRequest(APIURLRequest) { (data, response, error) in
			if error != nil {
				fHandler(LocationError.LocationManager(error: error))
			} else {
				if data != nil {
					let jsonResult: NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as! NSDictionary
					let (error,noResults) = self.validateGoogleJSONResponse(jsonResult)
					if noResults == true { // request is ok but not results are returned
						fHandler(LocationError.NoDataReturned)
					} else if (error != nil) { // something went wrong with request
						fHandler(LocationError.LocationManager(error: error))
					} else { // we have some good results to show
						let placemark = self.parseGoogleLocationData(jsonResult)
						sHandler(placemark)
					}
				}
			}
		}
		task.resume()
	}
	
	//MARK: [Private Methods] Parsing
	
	private func parseIPLocationData(resultDict: NSDictionary) throws -> CLPlacemark {
		let status = resultDict["status"] as? String
		if status != "success" {
			throw LocationError.NoDataReturned
		}
		
		var addressDict = [String:AnyObject]()
		addressDict[CLPlacemarkDictionaryKey.kCountry] = resultDict["country"] as! NSString
		addressDict[CLPlacemarkDictionaryKey.kCountryCode] = resultDict["countryCode"] as! NSString
		addressDict[CLPlacemarkDictionaryKey.kPostCodeExtension] = resultDict["zip"] as! NSString
		
		var coordinates = CLLocationCoordinate2DMake(0, 0)
		if let lat = resultDict["lat"] as? NSNumber, lon = resultDict["lon"] as? NSNumber {
			coordinates = CLLocationCoordinate2DMake(lat.doubleValue, lon.doubleValue)
		}
		
		let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: addressDict)
		return (placemark as CLPlacemark)
	}
	
	private func parseGoogleLocationData(resultDict: NSDictionary) -> CLPlacemark {
		let locationDict = (resultDict.valueForKey("results") as! NSArray).firstObject as! NSDictionary
		
		var addressDict = [String:AnyObject]()
		
		// Parse coordinates
		let geometry = locationDict.objectForKey("geometry") as! NSDictionary
		let location = geometry.objectForKey("location") as! NSDictionary
		let coordinate = CLLocationCoordinate2D(latitude: location.objectForKey("lat") as! Double, longitude: location.objectForKey("lng") as! Double)
		
		let addressComponents = locationDict.objectForKey("address_components") as! NSArray
		let formattedAddressArray = (locationDict.objectForKey("formatted_address") as! NSString).componentsSeparatedByString(", ") as Array
		
		addressDict[CLPlacemarkDictionaryKey.kSubAdministrativeArea] = JSONComponent("administrative_area_level_2", inArray: addressComponents, ofType: "long_name")
		addressDict[CLPlacemarkDictionaryKey.kSubLocality] = JSONComponent("subLocality", inArray: addressComponents, ofType: "long_name")
		addressDict[CLPlacemarkDictionaryKey.kState] = JSONComponent("administrative_area_level_1", inArray: addressComponents, ofType: "short_name")
		addressDict[CLPlacemarkDictionaryKey.kStreet] = formattedAddressArray.first! as NSString
		addressDict[CLPlacemarkDictionaryKey.kThoroughfare] = JSONComponent("route", inArray: addressComponents, ofType: "long_name")
		addressDict[CLPlacemarkDictionaryKey.kFormattedAddressLines] = formattedAddressArray
		addressDict[CLPlacemarkDictionaryKey.kSubThoroughfare] = JSONComponent("street_number", inArray: addressComponents, ofType: "long_name")
		addressDict[CLPlacemarkDictionaryKey.kPostCodeExtension] = ""
		addressDict[CLPlacemarkDictionaryKey.kCity] = JSONComponent("locality", inArray: addressComponents, ofType: "long_name")
		addressDict[CLPlacemarkDictionaryKey.kZIP] = JSONComponent("postal_code", inArray: addressComponents, ofType: "long_name")
		addressDict[CLPlacemarkDictionaryKey.kCountry] = JSONComponent("country", inArray: addressComponents, ofType: "long_name")
		addressDict[CLPlacemarkDictionaryKey.kCountryCode] = JSONComponent("country", inArray: addressComponents, ofType: "short_name")
		
		let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
		return (placemark as CLPlacemark)
	}
	
	private func JSONComponent(component:NSString,inArray:NSArray,ofType:NSString) -> NSString {
		let index:NSInteger = inArray.indexOfObjectPassingTest { (obj, idx, stop) -> Bool in
			let objDict:NSDictionary = obj as! NSDictionary
			let types:NSArray = objDict.objectForKey("types") as! NSArray
			let type = types.firstObject as! NSString
			return type.isEqualToString(component as String)
		}
		
		if index == NSNotFound { return "" }
		if index >= inArray.count { return "" }
		let type = ((inArray.objectAtIndex(index) as! NSDictionary).valueForKey(ofType as String)!) as! NSString
		if type.length > 0 { return type }
		return ""
	}
	
	private func validateGoogleJSONResponse(jsonResult: NSDictionary!) -> (error: NSError?, noResults: Bool!) {
		var status = jsonResult.valueForKey("status") as! NSString
		status = status.lowercaseString
		if status.isEqualToString("ok") == true { // everything is fine, the sun is shining and we have results!
			return (nil,false)
		} else if status.isEqualToString("zero_results") == true { // No results error
			return (nil,true)
		} else if status.isEqualToString("over_query_limit") == true { // Quota limit was excedeed
			let message	= "Query quota limit was exceeded"
			return (NSError(domain: NSCocoaErrorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey : message]),false)
		} else if status.isEqualToString("request_denied") == true { // Request was denied
			let message	= "Request denied"
			return (NSError(domain: NSCocoaErrorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey : message]),false)
		} else if status.isEqualToString("invalid_request") == true { // Invalid parameters
			let message	= "Invalid input sent"
			return (NSError(domain: NSCocoaErrorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey : message]),false)
		}
		return (nil,false) // okay!
	}
	
}