//
//  ExpenseBoxView.swift
//  I Got Gas
//
//  Created by Isaac Lyons on 8/7/20.
//  Copyright © 2020 Blizzard Skeleton. All rights reserved.
//

import SwiftUI
import CoreData

struct FuelExpenseBoxView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var serviceFetchRequest: FetchRequest<Service>
    var services: FetchedResults<Service> { serviceFetchRequest.wrappedValue }
    
    init(carID: String) {
        serviceFetchRequest = Fetch.services(howMany: 3,
                                            carID: carID,
                                            filters: [
                                                "vehicle.id = '\(carID)'",
                                                "note = 'Fuel'"
                                            ])
    }
    
    var body: some View {
        GroupBox(label: ImageAndTextLable(image: (colorScheme == .dark ? "gasHandleDarkMode" : "gasHandle"), text: "Fuel")) {
            VStack(alignment: .leading) {
                ForEach(services, id: \.self) { service in
                    HStack {
                        Text("$\(service.cost, specifier: "%.2f")")
                        Spacer()
                        Text("\(service.date!, formatter: DateFormatter.taskDateFormat)")
                    }
                }
            }
        }
    }
}
