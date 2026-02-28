import UIKit
import MapKit
import GTFSModel

class TripDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate {
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    
    var stopTime: StopRouteSummary?
    var times: [TripStopSummary] = []
    private var stopAnnotations: [StopTimeAnnotation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = self.stopTime?.tripHeadsign
        
        self.tableView.registerIdentifiableCell(TripStopTableViewCell.self)
        
        self.fetchTripDetail()
        self.mapRoute()
    }
    
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.times.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueIdentifiableCell(TripStopTableViewCell.self, forIndexPath: indexPath)
        
        cell.stopTime = self.times[(indexPath as NSIndexPath).row]
        cell.topLineView.isHidden = (indexPath as NSIndexPath).row == 0
        cell.bottomLineView.isHidden = (indexPath as NSIndexPath).row == (self.times.count - 1)
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.presentStopOptions(self.times[(indexPath as NSIndexPath).row])
    }
    
    
    // MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView: MKPinAnnotationView?
        
        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        } else {
            annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "stopPin") as? MKPinAnnotationView
            
            if (annotationView == nil) {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "stopPin")
                annotationView?.canShowCallout = true
                annotationView?.pinTintColor = mapView.tintColor
                
                let disclosureButton = UIButton(type: .detailDisclosure)
                disclosureButton.setImage(UIImage(named: "right-arrow"), for: UIControl.State())
                annotationView?.rightCalloutAccessoryView = disclosureButton
            } else {
                annotationView?.annotation = annotation
            }
        }
        
        return annotationView
    }
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let stopAnnotation = view.annotation as? StopTimeAnnotation else { return }
        self.presentStopOptions(stopAnnotation.stopTime)
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.lineWidth = 4.0
        renderer.strokeColor = mapView.tintColor
        
        return renderer
    }
    
    
    // MARK: - IBActions
    @IBAction func locateMe(_ sender: AnyObject) {
        self.animateMapRegion(to: self.mapView.userLocation.coordinate)
    }
    
    
    // MARK: - Controller methods
    func presentStopOptions(_ selectedStopTime: TripStopSummary) {
        guard let currentStopTime = self.stopTime else {
            return
        }

        let stopRouteSummary = StopRouteSummary(
            arrivalTime: selectedStopTime.arrivalTime,
            routeIdentifier: currentStopTime.routeIdentifier,
            routeShortName: currentStopTime.routeShortName,
            routeLongName: currentStopTime.routeLongName,
            tripIdentifier: currentStopTime.tripIdentifier,
            tripHeadsign: currentStopTime.tripHeadsign,
            directionIdentifier: currentStopTime.directionIdentifier,
            shapeIdentifier: currentStopTime.shapeIdentifier,
            stopIdentifier: selectedStopTime.stopIdentifier,
            stopName: selectedStopTime.stopName,
            stopLatitude: selectedStopTime.stopLatitude,
            stopLongitude: selectedStopTime.stopLongitude,
            stopRoutes: selectedStopTime.stopRoutes
        )

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Stop Schedule", style: .default, handler: { _ -> Void in
            let stopRouteTimeController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "StopRouteTimesViewController") as! StopRouteTimesViewController
            stopRouteTimeController.stopTime = stopRouteSummary
            
            self.navigationController?.pushViewController(stopRouteTimeController, animated: true)
        }))
        alertController.addAction(UIAlertAction(title: "Stop Lines", style: .default, handler: { _ -> Void in
            let stopRouteController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "StopRouteViewController") as! StopRouteViewController
            stopRouteController.stop = Stop.stop(byId: selectedStopTime.stopIdentifier)
            
            self.navigationController?.pushViewController(stopRouteController, animated: true)
        }))
        alertController.addAction(UIAlertAction(title: "Show on Map", style: .default, handler: { _ -> Void in
            let coordinate = CLLocationCoordinate2D(latitude: selectedStopTime.stopLatitude, longitude: selectedStopTime.stopLongitude)
            self.animateMapRegion(to: coordinate)
            if let annotation = self.stopAnnotations.first(where: { $0.stopTime.stopIdentifier == selectedStopTime.stopIdentifier }) {
                self.mapView.selectAnnotation(annotation, animated: true)
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    func fetchTripDetail() {
        DispatchQueue.global(qos: .background).async(execute: { [weak self] () -> Void in
            guard let strongSelf = self else { return }
            guard strongSelf.stopTime?.tripIdentifier.isEmpty == false else { return }
            
            strongSelf.times = StopTime.tripStopTimes(tripIdentifier: strongSelf.stopTime!.tripIdentifier)
            strongSelf.stopAnnotations = strongSelf.times.map(StopTimeAnnotation.init)
            
            DispatchQueue.main.async(execute: { () -> Void in
                strongSelf.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
                strongSelf.mapView.addAnnotations(strongSelf.stopAnnotations)
                
                if let selectedStopIdentifier = strongSelf.stopTime?.stopIdentifier,
                   let focused = strongSelf.times.first(where: { $0.stopIdentifier == selectedStopIdentifier }) {
                    let coordinate = CLLocationCoordinate2D(latitude: focused.stopLatitude, longitude: focused.stopLongitude)
                    strongSelf.animateMapRegion(to: coordinate)
                    if let annotation = strongSelf.stopAnnotations.first(where: { $0.stopTime.stopIdentifier == focused.stopIdentifier }) {
                        strongSelf.mapView.selectAnnotation(annotation, animated: true)
                    }
                }
            })
        })
    }
    
    
    func mapRoute() {
        DispatchQueue.global(qos: .background).async(execute: { [weak self] () -> Void in
            guard let strongSelf = self else { return }
            guard let shapeIdentifier = strongSelf.stopTime?.shapeIdentifier else { return }
            
            let shapes = Shape.shapes(forShape: shapeIdentifier)
            var points: [CLLocationCoordinate2D] = shapes.map { $0.coordinate }
            guard points.isEmpty == false else { return }
            
            let polyline = MKPolyline(coordinates: &points, count: points.count)
            
            DispatchQueue.main.async {
                strongSelf.mapView.addOverlay(polyline, level: .aboveRoads)
                strongSelf.animateMapRegion(to: points[0])
            }
        })
    }
    
    
    func animateMapRegion(to coordinate:CLLocationCoordinate2D) {
        let span = MKCoordinateSpan.init(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        self.mapView.setRegion(region, animated: true)
    }
    
    
    deinit {
        self.mapView.delegate = nil
    }
}
