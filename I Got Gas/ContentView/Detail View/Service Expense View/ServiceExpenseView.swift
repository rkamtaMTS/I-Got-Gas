//
//  TestView.swift
//  I Got Gas
//
//  Created by Isaac Lyons on 8/2/20.
//  Copyright © 2020 Blizzard Skeleton. All rights reserved.
//

import SwiftUI
import CoreData

struct ServiceExpenseView: View {
    @Environment(\.managedObjectContext) var moc
    @State var showAddExpenseView = false

    var carFetchRequest: FetchRequest<Car>
    var serviceFetchRequest: FetchRequest<Service>
    var cars: FetchedResults<Car> { carFetchRequest.wrappedValue }
    var services: FetchedResults<Service> { serviceFetchRequest.wrappedValue }
        
    init(carID: String) {
        carFetchRequest = Fetch.car(carID: carID)
        
        serviceFetchRequest = Fetch.services(howMany: 0,
                                             carID: carID,
                                             filters: [
                                                "vehicle.id = '\(carID)'",
                                                "note != 'Fuel'"
                                             ])
    }
    
    
    var body: some View {
        ForEach(cars, id: \.self) { car in
            
            VStack {
                List {
                    ForEach(services, id: \.self) { service in
                        VStack {
                            HStack {
                                Text("$\(service.cost, specifier: "%.2f")")
                                Spacer()
                                Text("\(service.date!, formatter: DateFormatter.taskDateFormat)")
                            }
                            HStack {
                                Text("\(service.odometer)")
                                Spacer()
                                Text("\(service.note ?? "")")
                                Spacer()
                                Text("\(service.vendor?.name ?? "")")
                            }
                        }
                    }.onDelete(perform: loseMemory)
                }
                Spacer()
                Button("Add Expense") {
                    self.showAddExpenseView = true
                }
                .padding(.bottom)
                .sheet(isPresented: self.$showAddExpenseView) {
                    AddExpenseView(car: Binding<Car>.constant(car),
                                   isGas: State(initialValue: false))
                        .environment(\.managedObjectContext, self.moc)
                }
            }
        }
    }
    func loseMemory(at offsets: IndexSet) {
        for index in offsets {
            let service = services[index]
            moc.delete(service)
            try? self.moc.save()
            AddExpenseView(car: Binding<Car>.constant(cars[0])).updateCarStats(cars[0])
        }
    }
}
