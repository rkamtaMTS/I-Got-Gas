//
//  AddExpenseView.swift
//  I Got Gas
//
//  Created by Isaac Lyons on 7/27/20.
//  Copyright © 2020 Blizzard Skeleton. All rights reserved.
//

import SwiftUI

struct AddFutureExpenseView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: Car.entity(), sortDescriptors: []) var cars: FetchedResults<Car>
    
    var fetchRequest: FetchRequest<Car>
    var car: FetchedResults<Car> { fetchRequest.wrappedValue }
    
    @State private var date = Date()
    @State private var odometer = ""
    @State private var note = ""
    @State private var name = ""
    @State private var repeating = true
    
    init(filter: String) {
        
        fetchRequest = FetchRequest<Car>(entity: Car.entity(),
                                         sortDescriptors: [],
                                         predicate: NSPredicate(
                                            format: "id = %@", filter))
    }
    
    var body: some View {
        ForEach(car, id: \.self) { car in
            VStack {
                NavigationView {
                    VStack {
                        
                        HStack {
                            Button(action: {
                                self.repeating.toggle()
                            }) {
                                self.repeating ? Text("Repeating") : Text("One Time")
                            }
                            .font(.system(size: 30))
                            .padding()
                            
                        }
                        
                        Form {
                            DatePicker("Date",
                                       selection: self.$date,
                                       displayedComponents: .date)
                                .padding(.top)
                                .labelsHidden()
                            
                                
                                TextField("Service Description", text: self.$name)
                                    .keyboardType(.decimalPad)
                                    .font(.system(size: 30))
                                
                                TextField("Service Notes", text: self.$note)
                                    .font(.system(size: 30))

                            
                        }
                        
                        Spacer()
                        
                        Button("Save") {
//                            self.save()
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }.navigationBarTitle("")
                    .navigationBarHidden(true)
                }
            }
        }
    }
    
//    func save() -> Void {
//
//        for car in car {
//            let service = Service(context: self.managedObjectContext)
//            service.vendor = Vendor(context: self.managedObjectContext)
//            service.vehicle = car
//
//            service.vendor?.name = self.vendorName
//            service.date = self.expenseDate
//
//            service.cost = Double(self.totalPrice) ?? 0.00
//            service.odometer = Int64(self.odometer) ?? 0
//            service.vehicle!.odometer = Int64(self.odometer) ?? 0
//
//            try? self.managedObjectContext.save()
//
//            if isGas {
//                service.note = "Fuel"
//                service.fuel = Fuel(context: self.managedObjectContext)
//                service.vehicle?.lastFillup = self.expenseDate
//                service.fuel?.numberOfGallons = Double(self.gallonsOfGas) ?? 0.00
//                service.fuel?.dpg = ((Double(self.totalPrice) ?? 0.00) / (Double(self.gallonsOfGas) ?? 0.00))
//
//                var totalCost = 0.00
//                for service in car.services! {
//                    totalCost += ((service as AnyObject).cost)
//                }
//                car.costPerMile = totalCost / (Double(car.odometer) - Double(car.startingOdometer))
//
//                totalCost = 0.00
//                for service in car.services! {
//                    totalCost += ((service as AnyObject).fuel as AnyObject).dpg
//                }
//                car.costPerGallon = totalCost / Double(car.services!.count)
//
//
//            } else {
//                service.note = self.note
//            }
//
//            try? self.managedObjectContext.save()
//
//        }
//
//    }
    
}

//struct AddFutureExpenseView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddExpenseView(filter: "Hello, darkness").environmentObject(\.presentationMode)
//    }
//}
