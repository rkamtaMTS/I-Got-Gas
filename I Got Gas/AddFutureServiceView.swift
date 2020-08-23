//
//  AddExpenseView.swift
//  I Got Gas
//
//  Created by Isaac Lyons on 7/27/20.
//  Copyright © 2020 Blizzard Skeleton. All rights reserved.
//

import SwiftUI
import UserNotifications

struct AddFutureServiceView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var moc
    
    @State private var monthOrWeek: Int = 0
    @State private var today = Date()
    @State private var odometer = ""
    @State private var name = ""
    @State private var repeating = true
    @State private var months = ""
    @State private var miles = ""
    @Binding var car: Car
    
    init(car: Binding<Car>) {
        self._car = car
    }
    
    var body: some View {
        VStack {
            NavigationView {
                VStack {
                    
                    HStack {
                        Button(action: {
                            self.repeating.toggle()
                        }) {
                            Text( self.repeating ? ("Repeating") : ("One Time"))
                        }
                        .font(.system(size: 30))
                        .padding()
                    }
                    
                    Form {
                        TextField("Service Description", text: self.$name)
                            .font(.system(size: 30))
                            .dismissKeyboardOnSwipe()
                            .dismissKeyboardOnTap()
                        
                        Section(header: Text("Every...")) {
                            TextField("", text: self.$months)
                                .font(.system(size: 30))
                                .keyboardType(.numberPad)
                                .dismissKeyboardOnSwipe()
                                .dismissKeyboardOnTap()
                            
                            Picker(selection: self.$monthOrWeek, label: Text("Interval")) {
                                Text("Months").tag(0)
                                Text("Weeks").tag(1)
                            }.pickerStyle(SegmentedPickerStyle())
                        }
                        
                        Section(header: Text("Or...")) {
                            HStack {
                                TextField("", text: self.$miles)
                                    .font(.system(size: 30))
                                    .keyboardType(.numberPad)
                                    .dismissKeyboardOnSwipe()
                                    .dismissKeyboardOnTap()
                                
                                Spacer()
                                Text("miles")
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
    
    func save() -> Void {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("All set!")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
        
        
        let futureService = FutureService(context: self.moc)
        futureService.vehicle = car
        
        futureService.name = self.name
        futureService.everyXMiles = Int64(self.miles) ?? 0
        futureService.months = Int64(self.months) ?? 0
        futureService.targetOdometer = (car.odometer + (Int64(self.miles) ?? 0))
        futureService.date = Calendar.current.date(byAdding: .month, value: Int(self.months) ?? 0, to: today)!
        setFutureServiceNotification(futureService)
        
        try? self.moc.save()
    }
    
    public func setFutureServiceNotification(_ futureService: FetchedResults<FutureService>.Element, now: Bool? = false) {
        let content = UNMutableNotificationContent()
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["\(String(describing: futureService.notificationUUID))"])
        content.title = "\(self.name)"
        content.body = "You're \(futureService.vehicle!.make!) \(futureService.vehicle!.model!) \(self.name) is due."
        content.badge = 1
        content.sound = UNNotificationSound.default
        
        if now! {
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 30, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            futureService.notificationUUID = request.identifier
            UNUserNotificationCenter.current().add(request)
            return
        }
        
        let date = futureService.date
        var triggerDate = Calendar.current.dateComponents([.year, .month, .day,], from: date!)
        triggerDate.hour = 8
        triggerDate.minute = 15
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        futureService.notificationUUID = request.identifier
        
        UNUserNotificationCenter.current().add(request)
        
    }
}
