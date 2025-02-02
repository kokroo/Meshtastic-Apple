import Foundation
import CoreLocation

class LocationHelper: NSObject, ObservableObject, CLLocationManagerDelegate {
	
	static let shared = LocationHelper()
	var locationManager = CLLocationManager()
	
	@Published var authorizationStatus: CLAuthorizationStatus?
	
	override init() {
		
		super.init()
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
		locationManager.pausesLocationUpdatesAutomatically = true
		locationManager.allowsBackgroundLocationUpdates = true
		locationManager.activityType = .otherNavigation
	}

	// Apple Park
	static let DefaultLocation = CLLocationCoordinate2D(latitude: 37.3346, longitude: -122.0090)
	static let DefaultAltitude = CLLocationDistance(integerLiteral: 0)
	static let DefaultSpeed = CLLocationSpeed(integerLiteral: 0)
	static let DefaultHeading = CLLocationDirection(integerLiteral: 0)
	
	static var currentLocation: CLLocationCoordinate2D {
		
		guard let location = shared.locationManager.location else {
			return DefaultLocation
		}
		return location.coordinate
	}
	
	static var currentAltitude: CLLocationDistance {
		
		guard let altitude = shared.locationManager.location?.altitude else {
			return DefaultAltitude
		}
		return altitude
	}
	
	static var currentSpeed: CLLocationSpeed {
		
		guard let speed = shared.locationManager.location?.speed else {
			return DefaultSpeed
		}
		return speed
	}
	
	static var currentHeading: CLLocationDirection {
		
		guard let heading = shared.locationManager.location?.course else {
			return DefaultHeading
		}
		return heading
	}
	
	static var currentTimestamp: Date {
		
		guard let timestamp = shared.locationManager.location?.timestamp else {
			return Date.now
		}
		return timestamp
	}
	
	static var satsInView: Int {
		// If we have a position we have a sat
		var sats = 1
		if shared.locationManager.location?.verticalAccuracy ?? 0 > 0 {
			sats = 4
			if 0...5 ~= shared.locationManager.location?.horizontalAccuracy ?? 0 {
				sats = 12
			} else if 6...15 ~= shared.locationManager.location?.horizontalAccuracy ?? 0 {
				sats = 10
			} else if 16...30 ~= shared.locationManager.location?.horizontalAccuracy ?? 0 {
				sats = 9
			} else if 31...45 ~= shared.locationManager.location?.horizontalAccuracy ?? 0 {
				sats = 7
			} else if 46...60 ~= shared.locationManager.location?.horizontalAccuracy ?? 0 {
				sats = 5
			}
		} else if shared.locationManager.location?.verticalAccuracy ?? 0 < 0 && 60...300 ~= shared.locationManager.location?.horizontalAccuracy ?? 0 {
			sats = 3
		} else if shared.locationManager.location?.verticalAccuracy ?? 0 < 0 && shared.locationManager.location?.horizontalAccuracy ?? 0 > 300 {
			sats = 2
		}
		return sats
	}

	func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		switch manager.authorizationStatus {
		case .authorizedWhenInUse:
			authorizationStatus = .authorizedWhenInUse
			locationManager.requestLocation()
			break
		case .restricted:
			authorizationStatus = .restricted
			break
		case .denied:
			authorizationStatus = .denied
			break
		case .notDetermined:
			authorizationStatus = .notDetermined
			locationManager.requestWhenInUseAuthorization()
			break
		default:
			break
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("Location manager error: \(error.localizedDescription)")
	}
}
