//
//  ViewController.swift
//  CustomAnnoMaps
//
//  Created by Saurav Aryal on 2/26/16.
//  Copyright © 2016 Saurav Aryal. All rights reserved.
//



import UIKit


import MapKit
import CoreLocation




var searchKey = ""
// there's some problem with my API key, it randomly works and doesn't. 
// feel free to try your own key, it has worked on other keys and I even tried making multiple but none of them worked for me. I beleive I had mentioned this in class well beforehand. 

let GOOGLE_API_KEY = "AIzaSyD42aFYBRCYLNzRWoeK3oeDUrn4U6hmNxY"
var image: String?

class ViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate{


    
    
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    @IBOutlet weak var keyword: UITextField!
    
    //set locvalue as location changes
    var locValue:CLLocation!{
        didSet{
            let coord = self.locValue.coordinate
            print (coord.latitude)
            print(coord.longitude)
        }
    }
    
    
    override func viewDidLoad() {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()    //ask for location access
        locationManager.startUpdatingLocation()
        
        
        self.keyword.becomeFirstResponder()
        super.viewDidLoad()
    }
    
    
 
    //declaring view for annotaion
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myspot")
        annotationView.animatesDrop = true
        annotationView.canShowCallout = true
        annotationView.pinTintColor = UIColor.blueColor()
        
        let button = UIButton(type: .DetailDisclosure)
        annotationView.rightCalloutAccessoryView = button
        return annotationView
    }

    //segue to detail page when clicked on annotation
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! mapLocation
        print ("we are here")
        self.performSegueWithIdentifier("DetailPageSegue", sender: location)
        
    }
    
    
    //when segueing, set the detaillocation of detailViewController
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "DetailPageSegue"){
            let detailView:DetailViewController = segue.destinationViewController as! DetailViewController
            detailView.detaillocation = (sender as? mapLocation)!
        }
    }
    
    
    //when search key is entered in textfield, retrieve data from api call and show annotations on the mapview
    func textFieldShouldReturn(textField: UITextField) -> Bool {

        //resigning as first responder
        keyword.resignFirstResponder()
        
        
        //remove previous annotations
        let annotationsToRemove = mapView.annotations.filter { $0 !== mapView.userLocation }
        mapView.removeAnnotations( annotationsToRemove )

        searchKey = keyword.text!
        //print(searchKey)


        var baseURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(38.9212)\(-77.0205)&radius=500&type=restaurant&name=\(searchKey)&key=\(GOOGLE_API_KEY)"
        
        
       //declaring center and vicinity of the map
        let center = CLLocationCoordinate2DMake(38.9212, -77.0205)
        let region = MKCoordinateRegion(center:center, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
        
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: NSURL(string: baseURL)!)
        let task = session.dataTaskWithRequest(request){
            (data, response, error)-> Void in
            if error != nil {
                print (error!.localizedDescription)
                return
            }
            do{
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                //Go through the jsonobject as results we get
                if let items = json["results"] as? [[String: AnyObject]]{
                    for items in items{

                        if let name = items["name"] as? String, let vicinity = items["vicinity"] as? String{
                            let coords: [Double] = self.getCoords(items["geometry"] as! Dictionary)
                            //if there are photos present in items
                            if let photo = items["photos"]{
                                image = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=" + ((photo.valueForKey("photo_reference"))![0] as! String) + "&key=" + GOOGLE_API_KEY
                            }
                            let annotation = mapLocation(title: name, coordinate: CLLocationCoordinate2D(latitude: coords[0], longitude:coords[1]), placeId: vicinity, subtitle: "delicious", image: image!)
                            self.mapView.addAnnotation(annotation)
                        }
                    }
                    //updating UI on the main thread
                    dispatch_async(dispatch_get_main_queue()){
                        self.mapView.setRegion(region, animated: true)
                    }
                }
            }catch{
                print("error serializing json")
            }
        }
        task.resume()
        return true;
    }
    
    

    //Set Region of the map
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locValue = manager.location!
        let center = CLLocationCoordinate2DMake(locValue.coordinate.latitude, locValue.coordinate.longitude)
        
        let region = MKCoordinateRegion(center:center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        
        self.mapView.setRegion(region, animated: true)
        
        print("locations = \(locValue.coordinate.latitude) \(locValue.coordinate.longitude)")
        locationManager.stopUpdatingLocation()
    }
    
    

    func getCoords(data: [String:AnyObject]) -> [Double]{
        let c = data["location"] as![String: AnyObject]
        return [c["lat"] as! Double, c["lng"] as! Double]
        
    }
    
    
    
    
}








