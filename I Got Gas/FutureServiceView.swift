//
//  TestView.swift
//  I Got Gas
//
//  Created by Isaac Lyons on 8/2/20.
//  Copyright © 2020 Blizzard Skeleton. All rights reserved.
//

import SwiftUI
import CoreData

struct FutureServiceView: View {
    @Environment(\.managedObjectContext) var moc
    var carFetchRequest: FetchRequest<Car>
    var car: Car { carFetchRequest.wrappedValue[0] }
    
    var futureServicesFetchRequest: FetchRequest<FutureService>
    var futureServices: FetchedResults<FutureService> { futureServicesFetchRequest.wrappedValue }
    
    @State var showAddFutureExpenseView = false
    
    init(carID: String) {
        carFetchRequest = Fetch.car(carID: carID)
        
        futureServicesFetchRequest = Fetch.futureServices(howMany: 0, carID: carID)
    }
    
    
    var body: some View {
        VStack {
            List {
                ForEach(futureServices, id: \.self) { futureService in
                    VStack {
                        HStack {
                            Text("\(futureService.name ?? "")")
                            Spacer()
                            Text("\(futureService.targetOdometer - car.odometer)/\(futureService.everyXMiles)")
                        }
                        HStack {
                            Text("\(futureService.note ?? "")")
                            Spacer()
                            Text("\(futureService.date!, formatter: DateFormatter.taskDateFormat)")
                        }
                    }
                }.onDelete(perform: loseMemory)
            }
            Spacer()
            Button("Schedule Service") {
                self.showAddFutureExpenseView = true
            }.sheet(isPresented: self.$showAddFutureExpenseView) {
                AddFutureServiceView(carID: car.id ?? "")
                    .environment(\.managedObjectContext, self.moc)
            }
        }
    }
    
    func loseMemory(at offsets: IndexSet) {
        for index in offsets {
            let service = futureServices[index]
            moc.delete(service)
            try? self.moc.save()
        }
    }
}
