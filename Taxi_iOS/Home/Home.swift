//
//  Home.swift
//  Taxi_3
//
//  Created by shirokiy on 05/10/2023.
//

import SwiftUI
import MapKit

struct Home: View {
    //Map Properties
    @State private var cameraPosition: MapCameraPosition = .region(.userRegion)
    @Namespace private var locationSpace
    @State private var mapSelection: MKMapItem?
    @State private var viewingRegion: MKCoordinateRegion?
    //Search Properties
    @State private var searchText: String = ""
    @State private var showSearch: Bool = true
    @State private var searchResult = [MKMapItem]()
    
    //Map Selection Detail properties
    @State private var showDetails: Bool = false
    @State private var lookAroundScene: MKLookAroundScene?
    //Route properties
    @State private var routeDisplaying: Bool = false
    @State private var route: MKRoute?
    @State private var getDirections = false
    @State private var routeDestination: MKMapItem?
    //Location Properties
    @State private var taxi: [MKMapItem] = []


    var body: some View {
        NavigationStack{
            Map(position: $cameraPosition, selection: $mapSelection, scope: locationSpace){
                
                ForEach(searchResult, id: \.self){ item in
                    //Hiding other Markers
                    if routeDisplaying{
                        if mapSelection == routeDestination{
                            let placemark = item.placemark
                            Marker(placemark.name ?? "", coordinate: placemark.coordinate)
                                .tint(.blue)
                        }
                    }else{
                        let placemark = item.placemark
                        Marker(placemark.name ?? "", coordinate: placemark.coordinate)
                            .tint(.blue)
                    }
                }
                ForEach(taxi, id: \.self){ item in
                    //Hiding other Markers
                    if routeDisplaying{
                        if mapSelection == routeDestination{
                            let placemark = item.placemark
                            Marker("", coordinate: placemark.coordinate)
                                .tint(.yellow)
                        }
                    }else{
                        let placemark = item.placemark
                        Marker("", coordinate: placemark.coordinate)
                            .tint(.yellow)
                    }
                }
                //Display route using polyline
                if let route{
                    MapPolyline(route.polyline)
                        .stroke(.blue, lineWidth: 7)
                }
                //To show User Current location
                UserAnnotation()
            }
            .onMapCameraChange {ctx in
                viewingRegion = ctx.region
            }
            .overlay(alignment: .bottomTrailing) {
                VStack(spacing: 15, content: {
                    MapCompass(scope: locationSpace)
                    MapPitchToggle(scope: locationSpace)
                    MapUserLocationButton(scope: locationSpace)
                    
                })
                .onChange(of: mapSelection) { oldValue, newValue in
                    fetchRoute()
                    showDetails = newValue != nil
                }
                .buttonBorderShape(.circle)
                .padding()
                .navigationTitle("Map")
                .navigationBarTitleDisplayMode(.inline)
                //Search bar
                .searchable(text: $searchText, isPresented: $showSearch)
                //Showing toolbar
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
                //When Route Displaying Hiding Top and Botton Bar
                .toolbar(routeDisplaying ? .hidden : .visible, for: .navigationBar)
                .sheet(isPresented: $showDetails, onDismiss:{
                    withAnimation(.snappy){
                        //Zooming route
                        if let boudingRect = route?.polyline.boundingMapRect, routeDisplaying{
                            cameraPosition = .rect(boudingRect)
                            print("It was cancel")
                        }
                    }
                }) {
                    LocationDetailsView(mapSelection: $mapSelection,
                                        show: $showDetails,
                                        getDirections: $getDirections,
                                        route: $route)
                    .presentationDetents([.height(400)])
                    .presentationBackgroundInteraction(.enabled(upThrough: .height(400)))
                    .presentationCornerRadius(12)
                }
            }
            .safeAreaInset(edge: .bottom, content: {
                if routeDisplaying{
                    Button("End Route"){
                        endRoute()
                        taxi.removeAll()
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(.red.gradient, in: .rect(cornerRadius: 12))
                    .padding()
                    .background(.ultraThinMaterial)
                }
            })
            .onChange(of: getDirections, { oldValue, newValue in
                if newValue{
                    routeDisplaying = true
                    fillTaxiArray()
                    searchResult.removeAll(keepingCapacity: true)
                    searchResult.append(mapSelection ?? MKMapItem())
                }
            })
            .onSubmit(of: .search) {
                Task{
                    guard !searchText.isEmpty else {return}
                    await SearchPlaces()
                }
            }
            .mapScope(locationSpace)
            .onChange(of: showSearch, initial: false){
                if !showSearch{
                    searchResult.removeAll(keepingCapacity: false)
                    showDetails = false
                    withAnimation(.snappy){
                        cameraPosition = .region(.userRegion)
                    }
                }
                
                
            }
        }
    }

    @ViewBuilder
    func mapDetails() -> some View {
        VStack(spacing: 15, content: {
            Text("Placeholder")
        })
    }
}

extension Home{
    //Search Places
    func SearchPlaces() async{
        print(searchText)
        let request =  MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = viewingRegion ?? .userRegion
        
        let results = try? await MKLocalSearch(request: request).start()
        self.searchResult = results?.mapItems ?? []
    }
    //Fetching Route
    func fetchRoute(){
        if let mapSelection{
            let request = MKDirections.Request()
            request.source = .init(placemark: .init(coordinate: .userLocation))
            request.destination = mapSelection
            
            Task{
                let result = try? await MKDirections(request: request).calculate()
                route = result?.routes.first
                routeDestination = mapSelection
                print(mapSelection.placemark.coordinate)
            }
        }
    }
    //show Taxi
    func fillTaxiArray() {
            taxi.append(MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 53.91966197011155, longitude: 27.565947057764802))))
            taxi.append(MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 53.908251276706714, longitude: 27.582885013289438))))
            taxi.append(MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 53.89878361627493, longitude: 27.563433892495098))))
            taxi.append(MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 53.90842865650844, longitude: 27.54833796992898))))
            taxi.append(MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 53.889156334769766, longitude: 27.54833796992893))))
        
        taxi.append(MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 53.892826512543216, longitude: 27.5477135181427))))
        taxi.append(MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 53.88964491122409, longitude: 27.5858162695883))))
        taxi.append(MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 53.90487600783467, longitude: 27.540598204359412))))
        taxi.append(MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 53.920978589977295, longitude: 27.592936576111853))))
    }
    
    
    func endRoute(){
        routeDisplaying = false
        getDirections = false
        showDetails = false
        mapSelection = routeDestination
        routeDestination = nil
        route = nil
        cameraPosition = .region(.userRegion)
                
    }
}


extension CLLocationCoordinate2D{
    static var userLocation: CLLocationCoordinate2D{
                        return .init(latitude: 53.91840, longitude: 27.59435)

        }
}
//extension CLLocationCoordinate2D {
//    static var userLocation: CLLocationCoordinate2D?
//
//    // Обновление текущих координат
//    static func updateUserLocation(_ location: CLLocation) {
//        userLocation = location.coordinate
//        print("Current location:\(location.coordinate) ")
//    }
//}

extension MKCoordinateRegion{
    static var userRegion: MKCoordinateRegion{
        return .init(center: .userLocation,
                     latitudinalMeters: 1000,
                     longitudinalMeters: 1000)
    }
}

#Preview {
    Home()
}
