import SwiftUI
import MapKit

struct AnnotationData : Identifiable {
    let id = UUID()
    let name : String
    let coordinate : CLLocationCoordinate2D
}

struct RouteSteps : Identifiable {
    let id = UUID()
    let step : String
}

struct ContentView: View {
    // State Variables
    @State var region : MKCoordinateRegion?
    @State var annotationArray = [
        AnnotationData(
            name: "Placeholder Location",
            coordinate: CLLocationCoordinate2D(latitude: 43.60775375366211, longitude: -79.66155242919922)
        )
    ]
    @State var firstStop : String = ""
    @State var secondStop : String = ""
    @State var finalDestination : String = ""
    @State var startToStop1ToStop2ToDestination : [RouteSteps] = []
    @State var startToStop1 : [RouteSteps] = []
    @State var stop1ToStop2 : [RouteSteps] = []
    @State var instructionButtonText: String = "Fill the form"
    @State var isLocationValid = false
    @StateObject var locationManager = LocationManager()
    @State var stop1Found = false
    @State var stop2Found = false
    @State var stop3Found = false
    // Screen
    var body: some View {
        NavigationView {
            ZStack {
                Image("images")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    VStack(spacing: 15) {
                        TextField("First Stop", text: $firstStop)
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(10)
                            .foregroundColor(.black)

                        TextField("Second Stop", text: $secondStop)
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(10)
                            .foregroundColor(.black)

                        TextField("Final Destination", text: $finalDestination)
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(10)
                            .foregroundColor(.black)

                        Button(action: {
                            handleTextBoxClick()
                        }) {
                            Text("Submit")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                    .padding(20)
                    .background(Color.white.opacity(0.6))
                    .cornerRadius(15)
                    Map(
                        coordinateRegion: $locationManager.region,
                        showsUserLocation: true,
                        annotationItems: annotationArray
                    ) { item in
                        MapPin(coordinate: item.coordinate)
                    }
                    .onAppear {
                        locationManager.checkIfLocationServicesEnabled()
                        locationManager.startUpdatingLocation()
                        annotationArray.append(
                            AnnotationData(
                                name: "Your House",
                                coordinate: locationManager.region.center
                            )
                        )
                    }
                    .frame(height: 300)
                    .cornerRadius(15)
                    .padding(.horizontal)
                    HStack(spacing: 15) {
                        // Instruction Button
                        NavigationLink(
                            destination: InstructionView(
                                startToStop1ToStop2ToDestination: startToStop1ToStop2ToDestination,
                                startToStop1: startToStop1,
                                stop1ToStop2: stop1ToStop2,
                                stop1Text: firstStop,
                                stop2Text: secondStop,
                                destinationText: finalDestination
                            )
                        ) {
                            Text(instructionButtonText)
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .cornerRadius(10)
                        }
                        .disabled(!isLocationValid)
                        .frame(width: 150)
                        // Search History Button
                        NavigationLink(
                            destination: A3View()
                        ) {
                            Text("Search History")
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.orange)
                                .cornerRadius(10)
                        }
                        .frame(width: 150)
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 50)
            }
        }
    }
    // Functions
    func handleTextBoxClick() {
        let firstStopText = firstStop
        let secondStoptext = secondStop
        let finalDestinationtext = finalDestination
        let clGeocoderObj = CLGeocoder()
        // --------Home to First Stop: Start--------
        clGeocoderObj.geocodeAddressString(
            firstStopText,
            completionHandler: {(possiblePlaces, error) in
                if(error != nil) {
                    print("Error finding the location 1")
                    instructionButtonText = "\(firstStopText) is not found"
                    isLocationValid = false
                    return
                }
                if let firstPlace = possiblePlaces?.first {
                    var coordinates : CLLocationCoordinate2D = firstPlace.location!.coordinate
                    region = MKCoordinateRegion(center: coordinates, latitudinalMeters: 1000, longitudinalMeters: 1000)
                    annotationArray.append(AnnotationData(name: firstPlace.name!, coordinate: coordinates))
                    let directionRequest = createDirectionRequest(
                        startCoordinates: locationManager.region.center,
                        destinationCoordinates: coordinates
                    )
                    calculateDirection(request: directionRequest) { steps in
                        startToStop1ToStop2ToDestination = steps.map { $0 }
                    }
                    stop1Found = true
                    // --------First Stop to Second Stop: Start--------
                    clGeocoderObj.geocodeAddressString(
                        secondStoptext,
                        completionHandler: {(possiblePlaces, error) in
                            if(error != nil) {
                                print("Error finding the location 2")
                                instructionButtonText = "\(secondStoptext) is not found"
                                isLocationValid = false
                                return
                            }
                            if let firstPlace = possiblePlaces?.first {
                                var coordinates2 : CLLocationCoordinate2D = firstPlace.location!.coordinate
                                region = MKCoordinateRegion(center: coordinates2, latitudinalMeters: 1000, longitudinalMeters: 1000)
                                annotationArray.append(AnnotationData(name: firstPlace.name!, coordinate: coordinates2))
                                let directionRequest = createDirectionRequest(
                                    startCoordinates: coordinates,
                                    destinationCoordinates: coordinates2
                                )
                                calculateDirection(request: directionRequest) { steps in
                                    startToStop1 = steps.map { $0 }
                                }
                                stop2Found = true
                                // --------Second Stop to Final Destination: Start--------
                                clGeocoderObj.geocodeAddressString(
                                    finalDestinationtext,
                                    completionHandler: {(possiblePlaces, error) in
                                        if(error != nil) {
                                            print("Error finding the destination")
                                            instructionButtonText = "\(finalDestinationtext) is not found"
                                            isLocationValid = false
                                            return
                                        }
                                        if let firstPlace = possiblePlaces?.first {
                                            var coordinates3 : CLLocationCoordinate2D = firstPlace.location!.coordinate
                                            region = MKCoordinateRegion(center: coordinates3, latitudinalMeters: 1000, longitudinalMeters: 1000)
                                            annotationArray.append(AnnotationData(name: firstPlace.name!, coordinate: coordinates3))
                                            let directionRequest = createDirectionRequest(
                                                startCoordinates: coordinates2,
                                                destinationCoordinates: coordinates3
                                            )
                                            calculateDirection(request: directionRequest) { steps in
                                                stop1ToStop2 = steps.map { $0 }
                                            }
                                            stop3Found = true
                                            if(stop1Found && stop2Found && stop3Found) {
                                                addDestination(stop1: firstStop, stop2: secondStop, final: finalDestination) { success, message in
                                                    print(message)
                                                }
                                            }
                                            isLocationValid = true
                                            instructionButtonText = "Instructions"
                                        }
                                    }
                                )
                                // --------Second Stop to Final Destination: End--------
                            }
                        }
                    )
                    // --------First Stop to Second Stop: End--------
                }
            }
        )
        // --------Home to First Stop: End--------
    }
    func createDirectionRequest(startCoordinates : CLLocationCoordinate2D, destinationCoordinates : CLLocationCoordinate2D)
    -> MKDirections.Request {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: startCoordinates))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoordinates))
        request.requestsAlternateRoutes = false
        request.transportType = .automobile
        return request
    }
    func calculateDirection(request: MKDirections.Request, completion: @escaping ([RouteSteps]) -> Void) {
        var instructionArray: [RouteSteps] = []
        let direction = MKDirections(request: request)
        direction.calculate { response, error in
            guard let routes = response?.routes else {
                completion([])
                return
            }
            for route in routes {
                for step in route.steps {
                    instructionArray.append(RouteSteps(step: step.instructions))
                }
            }
            completion(instructionArray)
        }
    }
    func addDestination(stop1: String, stop2: String, final: String, completion: @escaping (Bool, String) -> Void) {
        guard let url = URL(string: "https://vutran.dev.fast.sheridanc.on.ca/iOSClassA3/addDestination.php") else {
            completion(false, "Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Set the content type to application/json
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Prepare the data to be sent as JSON
        let parameters: [String: Any] = [
            "Stop1": stop1,
            "Stop2": stop2,
            "Final": final
        ]
        
        do {
            // Convert parameters to JSON data
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            request.httpBody = jsonData
        } catch {
            completion(false, "Error converting data to JSON: \(error.localizedDescription)")
            return
        }

        // Send the request
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(false, "Error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                completion(false, "No data received")
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let success = json["success"] as? Bool,
                   let message = json["message"] as? String {
                    completion(success, message)
                } else {
                    completion(false, "Invalid response format")
                }
            } catch {
                completion(false, "Error parsing response: \(error.localizedDescription)")
            }
        }.resume()
    }

}

#Preview {
    ContentView()
}
