//
//  A3View.swift
//  assignment2
//
//  Created by Default User on 11/19/24.
//

import SwiftUI
import MapKit

struct A3View: View {
    /// Variables
    @ObservedObject var fetch = GetDestinations()
    @State var region : MKCoordinateRegion?
    @State private var home: CLLocationCoordinate2D?
    @State var annotationArray = [
        AnnotationData(
            name: "Placeholder Location",
            coordinate: CLLocationCoordinate2D(latitude: 43.60775375366211, longitude: -79.66155242919922)
        )
    ]
    @State var isLocationValid = false
    @StateObject var locationManager = LocationManager()
    @State var pickerViewValue = 0
    @State var routeSteps : [RouteSteps] = [RouteSteps(step: "Place Holder")]
    @State var filter: [String] = []
    /// Screen Design
    var body: some View {
        ZStack {
            Image("images")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            VStack {
                Map(
                    coordinateRegion: $locationManager.region,
                    showsUserLocation: true,
                    annotationItems: annotationArray
                ) { item in
                    MapPin(coordinate: item.coordinate)
                }
                    .frame(height: 300).cornerRadius(15).padding(.horizontal)
                    .onAppear {
                        locationManager.checkIfLocationServicesEnabled()
                        locationManager.startUpdatingLocation()
                        if home == nil {
                            home = locationManager.region.center
                        }
                        annotationArray.append(
                            AnnotationData(
                                name: "Your House",
                                coordinate: locationManager.region.center
                            )
                        )
                    }
                Picker(selection: $pickerViewValue, label: Text("Difficulty")) {
                    Text("Stop 1").tag(0)
                    Text("Stop 2").tag(1)
                    Text("Final").tag(2)
                }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .onChange(of: pickerViewValue) { newValue in
                        handlePickerChange(value: newValue)
                    }
                if !filter.isEmpty {
                    List(filter, id: \.self) { filterItem in
                        Text(filterItem)
                            .onTapGesture {
                                handleStopTap(filterItem)
                            }
                    }
                } else {
                    Text("No stops available")
                        .foregroundColor(.gray)
                        .padding()
                }
            }.padding(.top, 50)
        }
        .onAppear {
            if(fetch.destinations.count > 0) {
                print(fetch.destinations[0])
            }
        }
    }
    /// Functions
    func handlePickerChange(value: Int) {
        switch pickerViewValue {
            case 0: // Stop 1
                filter = fetch.destinations.map {$0.Stop1}
            case 1: // Stop 2
                filter = fetch.destinations.map {$0.Stop2}
            case 2: // Final
                filter = fetch.destinations.map {$0.Final}
            default:
                filter = []
        }
    }
    func handleStopTap(_ stop: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(
            stop,
            completionHandler: { (placemarks, error) in
                if(error != nil) {
                    print("Error: Cannot find this place")
                }
                if let placemark = placemarks?.first {
                    let coordinates : CLLocationCoordinate2D = placemark.location!.coordinate
                    locationManager.region = MKCoordinateRegion(center: coordinates, latitudinalMeters: 1000, longitudinalMeters: 1000)
                    annotationArray.append(AnnotationData(name: placemark.name!, coordinate: coordinates))
                }
            }
        )
    }
}

#Preview {
    A3View()
}
