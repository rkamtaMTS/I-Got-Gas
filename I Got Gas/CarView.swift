//
//  SwiftUIView.swift
//  I Got Gas
//
//  Created by Isaac Lyons on 7/26/20.
//  Copyright © 2020 Blizzard Skeleton. All rights reserved.
//

import SwiftUI

//struct CarView: View {
//    @Environment(\.managedObjectContext) var managedObjectContext
//    @FetchRequest(entity: Car.entity(), sortDescriptors: []) var cars: FetchedResults<Car>
//
////    let id: String
//
//    var body: some View {
//        CarSubView(filter: id)
//    }
//}

struct CarView: View {
    var carFetchRequest: FetchRequest<Car>
    var cars: FetchedResults<Car> { carFetchRequest.wrappedValue }
    
    init(carID: String) {
        carFetchRequest = Fetch.car(carID: carID)
    }
    
    var body: some View {
        ForEach(cars, id: \.self) { car in
            
            HStack {
                Image(systemName: "star.fill")
                    .font(.system(size: 60))
                    .padding(.leading)
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text(car.name ?? "")
                    Text("\(car.year ?? "") \(car.make ?? "") \(car.model ?? "")")
                    Text("Some number stats")
                }
                
                Spacer()
            }
            .padding(.vertical, 20)
            .background(Color(.systemBlue))
            .opacity(0.8)
            .cornerRadius(20)
            .padding(.horizontal, 20)
            
        }
    }
}
