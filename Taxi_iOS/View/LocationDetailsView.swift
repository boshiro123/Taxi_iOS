//
//  LocationDetailsView.swift
//  Taxi_2
//
//  Created by shirokiy on 04/10/2023.
//

import SwiftUI
import MapKit
struct LocationDetailsView: View {
    @State private var selectedTypeRide: RideType = .uberX
    @Binding var mapSelection: MKMapItem?
    @Binding var show: Bool
    @State private var lookAroundScene: MKLookAroundScene?
    @Binding var getDirections: Bool
    @Binding var route: MKRoute?
    var distance: Double = 1

    
    var body: some View {
        VStack{
            VStack{
                Capsule()
                    .foregroundColor(Color(.systemGray5))
                    .frame(width: 48, height: 6)
                
                //trip info view
                HStack{
                    //indicator view
                    VStack{
                        Circle()
                            .fill(Color(.systemGray3))
                            .frame(width: 8, height: 8)
                        
                        Rectangle()
                            .fill(Color(.systemGray3))
                            .frame(width: 1, height: 24)
                        
                        Rectangle()
                            .fill(.black )
                            .frame(width: 8, height: 8)
                        
                    }
                    
                    VStack(alignment: .leading, spacing: 24){
                        HStack{
                            Text("Current location")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.gray)
                            Spacer()
                            
                            Text("1:30 PM")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.gray)

                        }
                        .padding(.bottom, 10)
                        
                        HStack{
                            Text("Selected location")
                                .font(.system(size: 16, weight: .semibold))
                            
                            Spacer()
                            
                            Text("1:45 PM")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.gray)

                        }
                    }
                    .padding(.leading, 8)
                }
                .padding()
                
                Divider()
                //ride type selection view
                
                Text("SUGGECTED RIDES")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding()
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                ScrollView(.horizontal){
                    HStack(spacing: 12){
                        ForEach(RideType.allCases){ type in
                            VStack(alignment: .leading) {
                                Image(type.imageName)
                                    .resizable()
                                    .scaledToFit()
                                
                                VStack(alignment: .leading)  {
                                    Text(type.discription)
                                        .font(.system(size: 14, weight: .semibold))
                                    
                                    Text("$\((type.computePrice(for: route?.distance ?? 1)).toCurrency())")
                                        .font(.system(size: 14, weight: .semibold))
                                }.padding()
                            }
                            .frame(width: 112, height: 140)
                            .background(Color(type == selectedTypeRide ?
                                .systemBlue :
                                    .systemGroupedBackground))
                            .scaleEffect(type==selectedTypeRide ? 1.2 : 1.0)
                            .cornerRadius(10)
                            .onTapGesture {
                                withAnimation(.spring()){
                                    selectedTypeRide = type
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
            }
            HStack(spacing: 24){
            Button {
                    if let mapSelection{
                        mapSelection.openInMaps()
                    }
                } label: {
                    Text("Open in Maps")
                        .font(.title2)
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 170, height: 45)
                        .background(.green)
                        .cornerRadius(7)
                }
                Button {
                    getDirections = true
                        show = false
                    } label: {
                        Text("Confirm ride")
                            .font(.title2)
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 170, height: 45)
                            .background(.blue)
                            .cornerRadius(7)
                    }

            }
        }
        .onAppear{
            print("DEBUG: did call on appear.")
            fetchLookAroundPreview()
        }
        .onChange(of: mapSelection) { oldValue, newValue in
            print("DEBUG: did call on appear.")
            fetchLookAroundPreview()
        }
        .padding()
    }
}

    extension LocationDetailsView{
        func fetchLookAroundPreview(){
            if let mapSelection{
                Task{
                    let request = MKLookAroundSceneRequest(mapItem: mapSelection)
                    lookAroundScene = try? await request.scene
                }
            }
        }
    }

#Preview {
    LocationDetailsView(mapSelection: .constant(nil),
                        show: .constant(false),
                        getDirections: .constant(false),
                        route: .constant(MKRoute()))
}
