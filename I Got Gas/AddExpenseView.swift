//
//  AddExpenseView.swift
//  I Got Gas
//
//  Created by Isaac Lyons on 7/27/20.
//  Copyright © 2020 Blizzard Skeleton. All rights reserved.
//

import SwiftUI

struct AddExpenseView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var moc
//    @FetchRequest(entity: Car.entity(), sortDescriptors: []) var cars: FetchedResults<Car>
    
    var carFetchRequest: FetchRequest<Car>
    var cars: FetchedResults<Car> { carFetchRequest.wrappedValue }
    var futureServicesFetchRequest: FetchRequest<FutureService>
    var futureServices: FetchedResults<FutureService> { futureServicesFetchRequest.wrappedValue }
    
    @State var selectedFutureService: Int = -1
    
    @State private var expenseDate = Date()
    
    @State private var isGas = true
    @State private var totalPrice: Double?
    @State private var gallonsOfGas = ""
    @State private var vendorName = ""
    @State private var note = ""
    @State private var odometer: Int64?
    
    init(carID: String) {
        carFetchRequest = Fetch.car(carID: carID)
        
        futureServicesFetchRequest = Fetch.futureServices(howMany: 0, carID: carID)
    }
    
    var body: some View {
        ForEach(cars, id: \.self) { car in
            
            VStack {
                
                HStack {
                    Button(action: {
                        self.isGas.toggle()
                    }) {
                        self.isGas ? Text("Gas") : Text("Service")
                    }
                    .font(.system(size: 30))
                    .padding()
                    
                }
                
                NavigationView {
                    VStack {
                        Form {
                            Section(header: Text("Date")) {
                                DatePicker("Date",
                                           selection: self.$expenseDate,
                                           displayedComponents: .date)
                                    .padding(.top)
                                    .labelsHidden()
                            }
                            if !self.isGas {
                                Picker(selection: self.$selectedFutureService,
                                       label: Text("Scheduled Service")) {
                                    
                                    Text("").tag(-1)
                                    
                                    ForEach(0 ..< futureServices.count) {
                                        Text("\(futureServices[$0].name!)")
                                            .foregroundColor(futureServices[$0].important
                                                                ? Color.red
                                                                : (colorScheme == .dark
                                                                    ? Color.white
                                                                    : Color.black))
                                    }
                                    
                                }
                            }
                            
                            Section(header: Text("Details")) {
                                
                                
                                CurrencyTextField("Price", value: self.$totalPrice)
                                    .font(.largeTitle)
                                    .multilineTextAlignment(TextAlignment.leading)
                                
                                
                                if self.isGas {
                                    TextField("Gallons", text: self.$gallonsOfGas)
                                        .keyboardType(.decimalPad)
                                        .font(.largeTitle)
                                        .dismissKeyboardOnSwipe()
                                        .dismissKeyboardOnTap()
                                }
                                
                                TextField("Odometer", value: self.$odometer,
                                          formatter: NumberFormatter.withCommaSeparator)
                                    .keyboardType(.decimalPad)
                                    .font(.largeTitle)
                                    .dismissKeyboardOnSwipe()
                                    .dismissKeyboardOnTap()
                                
                            }
                            
                            Section(header: Text("Vendor")) {
                                TextField("Vendor name", text: self.$vendorName)
                                
                                if !self.isGas {
                                    TextField("Service Notes", text: self.$note)
                                        .dismissKeyboardOnSwipe()
                                        .dismissKeyboardOnTap()
                                }
                            }
                        }
                        
                        Spacer()
                        
                        Button("Save") {
                            self.save()
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }.navigationBarTitle("")
                    .navigationBarHidden(true)
                }
            }
        }
    }
    
    fileprivate func save() -> Void {
        for car in cars {
            let service = Service(context: self.moc)
            service.vendor = Vendor(context: self.moc)
            service.vehicle = car
            
            updateFutureServices(car)
            setFutureInStone(car)
            updateCarOdometer(car)
            setServiceStats(service)
            
            try? self.moc.save()
            
            setFuelDetails(car, service)
            updateCarStats(car)
            
            try? self.moc.save()
        }
    }
    
    fileprivate func updateFutureServices(_ car: FetchedResults<Car>.Element) {
        
        for futureService in futureServices {
            if futureService.everyXMiles != 0 {
                if futureService.targetOdometer <= self.odometer! {
                    futureService.important = true
                }
            }
            if futureService.date! < Date() {
                futureService.important = true
            }
        }
    }
    
    fileprivate func setFutureInStone(_ car: FetchedResults<Car>.Element) {
        if selectedFutureService > -1 {
            let service = futureServices[selectedFutureService]
            service.important = false
            service.targetOdometer = (self.odometer! + service.everyXMiles)
            service.date = Calendar.current.date(byAdding: .month, value: Int(service.months), to: expenseDate)!
        }
    }
    
    fileprivate func updateCarOdometer(_ car: FetchedResults<Car>.Element) {
        if self.odometer! > car.odometer {
            car.odometer = self.odometer!
        }
    }
    
    fileprivate func setFuelDetails(_ car: FetchedResults<Car>.Element, _ service: Service) {
        if isGas {
            car.lastFillup = self.expenseDate
            service.note = "Fuel"
            service.fuel = Fuel(context: self.moc)
            service.fuel?.numberOfGallons = Double(self.gallonsOfGas) ?? 0.00
            service.fuel?.dpg = ((self.totalPrice!) / (Double(self.gallonsOfGas) ?? 0.00))
        } else {
            service.note = self.note
        }
    }
    
    public func updateCarStats(_ car: FetchedResults<Car>.Element) {
        
        var totalCost = 0.00
        var fuelCost = 0.00
        
        for service in car.services! {
            totalCost += ((service as AnyObject).cost)
            
            if ((service as AnyObject).fuel as AnyObject).dpg != nil {
                fuelCost += ((service as AnyObject).fuel as AnyObject).dpg
            }
        }
        car.costPerGallon = fuelCost / Double(car.services!.count)
        car.costPerMile = totalCost / (Double(car.odometer) - Double(car.startingOdometer))
        try? self.moc.save()
    }
    
    fileprivate func setServiceStats(_ service: Service) {
        service.vendor?.name = self.vendorName
        service.date = self.expenseDate
        
        service.cost = self.totalPrice!
        service.odometer = self.odometer!
    }
    
}
