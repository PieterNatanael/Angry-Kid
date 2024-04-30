//
//  ContentView.swift
//  Angry Kid
//
//  Created by Pieter Yoshua Natanael on 27/04/24.
//

import SwiftUI
import UIKit

// Data Model for Anger Entry
struct AngerEntry: Identifiable, Codable {
    var id: UUID
    let date: Date
    var text: String
    var angerLevel: String // Can be "Low", "Medium", or "High"
    
    init(id: UUID = UUID(), date: Date, text: String, angerLevel: String) {
        self.id = id
        self.date = date
        self.text = text
        self.angerLevel = angerLevel
    }
}

// Main App View
struct AngryKidApp: App {
    @StateObject var dataStore = DataStore()
   
    
    
    var body: some Scene {
        WindowGroup {
            ContentView(dataStore: dataStore)
        }
    }
}

// Data Store for managing persistence
class DataStore: ObservableObject {
    @Published var entries: [AngerEntry] = []
    
    init() {
        loadEntries()
    }
    
    func saveEntries() {
        do {
            let encodedData = try JSONEncoder().encode(entries)
            UserDefaults.standard.set(encodedData, forKey: "angerEntries")
            print("Entries saved successfully.")
        } catch {
            print("Error saving entries: \(error)")
        }
    }
    
    func loadEntries() {
        if let encodedData = UserDefaults.standard.data(forKey: "angerEntries") {
            do {
                let savedEntries = try JSONDecoder().decode([AngerEntry].self, from: encodedData)
                entries = savedEntries
                print("Entries loaded successfully.")
            } catch {
                print("Error loading entries: \(error)")
            }
        }
    }
    
    func exportAllEntries() {
        var exportString = "Export From Angry Kid\n\n"
        exportString += entries.map { entry -> String in
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            let formattedDate = dateFormatter.string(from: entry.date)
            return "\(formattedDate) - \(entry.text) - Anger Level: \(entry.angerLevel)"
        }.joined(separator: "\n")
        
        let activityViewController = UIActivityViewController(activityItems: [exportString], applicationActivities: nil)
        
        UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
    }
}

// Main Content View
struct ContentView: View {
    @ObservedObject var dataStore: DataStore
    @State private var newText: String = ""
    @State private var selectedAngerLevel: String = "Low"
    @State private var showExplain = false
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(colors: [Color(#colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)),.clear], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            
            VStack {
                
                HStack {
                    Spacer()
                    Button(action: {
                             showExplain = true
                         }) {
                             Image(systemName: "questionmark.circle.fill")
                                 .font(.system(size: 30))
                                 .foregroundColor(Color(.white))
                                 .padding()
                                 .shadow(color: Color.black.opacity(0.6), radius: 5, x: 0, y: 2)
                     }
                }
                
                
                Text("Angry Kid")
                    .font(.title.bold())
                    .padding()
                
                TextField("Write down your anger here...", text: $newText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Picker(selection: $selectedAngerLevel, label: Text("Anger Level")) {
                    Text("Low").tag("Low")
                    Text("Medium").tag("Medium")
                    Text("High").tag("High")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                Button(action: {
                    saveEntry()
                    dataStore.saveEntries()
                }) {
                    Text("Save Anger")
                        .font(.title2)
                        .padding()
                }
                .frame(width: 233)
                .background(Color(#colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)))
                .cornerRadius(25)
                .foregroundColor(.black)
                .padding()
                .shadow(color: Color.black.opacity(0.5), radius: 5, x: 0, y: 2)
                
              
                    Button(action: {
                        dataStore.exportAllEntries()
                    }) {
                        Text("Export All")
                            .font(.title2)
                            .padding()
                    }
                    .frame(width: 233)
                    .background(Color.white)
                    .cornerRadius(25)
                    .foregroundColor(.black)
                    .padding()
                .shadow(color: Color.black.opacity(0.5), radius: 5, x: 0, y: 2)
                    
                   
                    
                
                
                List {
                    ForEach(dataStore.entries) { entry in
                        VStack(alignment: .leading) {
                            Text("\(entry.date, formatter: dateFormatter)")
                                .font(.headline)
                            Text(entry.text)
                                .font(.body)
                                .foregroundColor(Color.gray)
                            Text("Anger Level: \(entry.angerLevel)")
                                .font(.caption)
                                .foregroundColor(Color.red)
                        }
                    }
                    .onDelete { indexSet in
                        deleteEntry(at: indexSet)
                        dataStore.saveEntries()
                    }
                }
            }
            .sheet(isPresented: $showExplain) {
                ShowExplainView(onConfirm: {
                    showExplain = false
                })
            }
            .padding()
            .onDisappear {
                dataStore.saveEntries()
            }
        }
    }
    
    // Function to save a new anger entry
    func saveEntry() {
        guard !newText.isEmpty else { return }
        let newEntry = AngerEntry(date: Date(), text: newText, angerLevel: selectedAngerLevel)
        dataStore.entries.append(newEntry)
        newText = ""
    }
    
    // Function to delete an anger entry
    func deleteEntry(at offsets: IndexSet) {
        dataStore.entries.remove(atOffsets: offsets)
    }
    
    // Date formatter
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(dataStore: DataStore())
    }
}

// MARK: - Explain View
struct ShowExplainView: View {
    var onConfirm: () -> Void

    var body: some View {
        ScrollView {
            VStack {
               HStack{
                   Text("Ads & App Functionality")
                       .font(.title3.bold())
                   Spacer()
               }
                Divider().background(Color.gray)
              
                //ads
                VStack {
                    HStack {
                        Text("Ads")
                            .font(.largeTitle.bold())
                        Spacer()
                    }
                    ZStack {
                        Image("threedollar")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .cornerRadius(25)
                            .clipped()
                            .onTapGesture {
                                if let url = URL(string: "https://b33.biz/three-dollar/") {
                                    UIApplication.shared.open(url)
                                }
                            }
                    }
                    // App Cards
                    VStack {
                        Divider().background(Color.gray)
                        AppCardView(imageName: "bodycam", appName: "BODYCam", appDescription: "Record videos effortlessly and discreetly.", appURL: "https://apps.apple.com/id/app/b0dycam/id6496689003")
                        Divider().background(Color.gray)
                        // Add more AppCardViews here if needed
                        // App Data
                     
                        
                        AppCardView(imageName: "timetell", appName: "TimeTell", appDescription: "Announce the time every 30 seconds, no more guessing and checking your watch, for time-sensitive tasks.", appURL: "https://apps.apple.com/id/app/loopspeak/id6473384030")
                        Divider().background(Color.gray)
                        
                        AppCardView(imageName: "SingLoop", appName: "Sing LOOP", appDescription: "Record your voice effortlessly, and play it back in a loop.", appURL: "https://apps.apple.com/id/app/sing-l00p/id6480459464")
                        Divider().background(Color.gray)
                        
                        AppCardView(imageName: "loopspeak", appName: "LOOPSpeak", appDescription: "Type or paste your text, play in loop, and enjoy hands-free narration.", appURL: "https://apps.apple.com/id/app/loopspeak/id6473384030")
                        Divider().background(Color.gray)
                        
                        AppCardView(imageName: "insomnia", appName: "Insomnia Sheep", appDescription: "Design to ease your mind and help you relax leading up to sleep.", appURL: "https://apps.apple.com/id/app/insomnia-sheep/id6479727431")
                        Divider().background(Color.gray)
                        
                        AppCardView(imageName: "dryeye", appName: "Dry Eye Read", appDescription: "The go-to solution for a comfortable reading experience, by adjusting font size and color to suit your reading experience.", appURL: "https://apps.apple.com/id/app/dry-eye-read/id6474282023")
                        Divider().background(Color.gray)
                        
                        AppCardView(imageName: "iprogram", appName: "iProgramMe", appDescription: "Custom affirmations, schedule notifications, stay inspired daily.", appURL: "https://apps.apple.com/id/app/iprogramme/id6470770935")
                        Divider().background(Color.gray)
                        
                        AppCardView(imageName: "temptation", appName: "TemptationTrack", appDescription: "One button to track milestones, monitor progress, stay motivated.", appURL: "https://apps.apple.com/id/app/temptationtrack/id6471236988")
                        Divider().background(Color.gray)
                    
                    }
                    Spacer()

                   
                   
                }
//                .padding()
//                .cornerRadius(15.0)
//                .padding()
                
                //ads end
                
                
                HStack{
                    Text("App Functionality")
                        .font(.title.bold())
                    Spacer()
                }
               
               Text("""
               •Users can type in details about their anger.
               •Users can enter their anger levels (low, medium, high) along with a timestamp.
               •The app displays the date and time of anger entries.
               •Users can view their anger history within the app.
               •The app allows easy export of all anger data for informing parents or family.
               •No user data is collected by the app.
               """)
               .font(.title3)
               .multilineTextAlignment(.leading)
               .padding()
               
               Spacer()
                
                HStack {
                    Text("Angry Kid is developed by Three Dollar.")
                        .font(.title3.bold())
                    Spacer()
                }

               Button("Close") {
                   // Perform confirmation action
                   onConfirm()
               }
               .font(.title)
               .padding()
               .cornerRadius(25.0)
               .padding()
           }
           .padding()
           .cornerRadius(15.0)
           .padding()
        }
    }
}

// MARK: - App Card View
struct AppCardView: View {
    var imageName: String
    var appName: String
    var appDescription: String
    var appURL: String
    
    var body: some View {
        HStack {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .cornerRadius(7)
            
            VStack(alignment: .leading) {
                Text(appName)
                    .font(.title3)
                Text(appDescription)
                    .font(.caption)
            }
            .frame(alignment: .leading)
            
            Spacer()
            Button(action: {
                if let url = URL(string: appURL) {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("Try")
                    .font(.headline)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
    }
}
/*
//well but want to add adview on it
import SwiftUI
import UIKit

// Data Model for Anger Entry
struct AngerEntry: Identifiable, Codable {
    var id: UUID
    let date: Date
    var text: String
    var angerLevel: String // Can be "Low", "Medium", or "High"
    
    init(id: UUID = UUID(), date: Date, text: String, angerLevel: String) {
        self.id = id
        self.date = date
        self.text = text
        self.angerLevel = angerLevel
    }
}

// Main App View
struct AngryKidApp: App {
    @StateObject var dataStore = DataStore()
    
    
    var body: some Scene {
        WindowGroup {
            ContentView(dataStore: dataStore)
        }
    }
}

// Data Store for managing persistence
class DataStore: ObservableObject {
    @Published var entries: [AngerEntry] = []
    
    init() {
        loadEntries()
    }
    
    func saveEntries() {
        do {
            let encodedData = try JSONEncoder().encode(entries)
            UserDefaults.standard.set(encodedData, forKey: "angerEntries")
            print("Entries saved successfully.")
        } catch {
            print("Error saving entries: \(error)")
        }
    }
    
    func loadEntries() {
        if let encodedData = UserDefaults.standard.data(forKey: "angerEntries") {
            do {
                let savedEntries = try JSONDecoder().decode([AngerEntry].self, from: encodedData)
                entries = savedEntries
                print("Entries loaded successfully.")
            } catch {
                print("Error loading entries: \(error)")
            }
        }
    }
    
    func exportAllEntries() {
        var exportString = "Export From Angry Kid\n\n"
        exportString += entries.map { entry -> String in
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            let formattedDate = dateFormatter.string(from: entry.date)
            return "\(formattedDate) - \(entry.text) - Anger Level: \(entry.angerLevel)"
        }.joined(separator: "\n")
        
        let activityViewController = UIActivityViewController(activityItems: [exportString], applicationActivities: nil)
        
        UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
    }
}

// Main Content View
struct ContentView: View {
    @ObservedObject var dataStore: DataStore
    @State private var newText: String = ""
    @State private var selectedAngerLevel: String = "Low"
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(colors: [Color(#colorLiteral(red: 1, green: 0.5212053061, blue: 1, alpha: 1)),.clear], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            VStack {
                Text("Angry Kid")
                    .font(.title.bold())
                    .padding()
                
                TextField("Write down your anger here...", text: $newText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Picker(selection: $selectedAngerLevel, label: Text("Anger Level")) {
                    Text("Low").tag("Low")
                    Text("Medium").tag("Medium")
                    Text("High").tag("High")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                Button(action: {
                    saveEntry()
                    dataStore.saveEntries()
                }) {
                    Text("Save Anger")
                        .font(.title2)
                        .padding()
                }
                .frame(width: 233)
                .background(Color(#colorLiteral(red: 1, green: 0.5212053061, blue: 1, alpha: 1)))
                .cornerRadius(25)
                .foregroundColor(.black)
                .padding()
                .shadow(color: Color.black.opacity(0.5), radius: 5, x: 0, y: 2)
                
                Button(action: {
                    dataStore.exportAllEntries()
                }) {
                    Text("Export All")
                        .font(.title2)
                        .padding()
                }
                .frame(width: 233)
                .background(Color.white)
                .cornerRadius(25)
                .foregroundColor(.black)
                .padding()
                .shadow(color: Color.black.opacity(0.5), radius: 5, x: 0, y: 2)
                
                List {
                    ForEach(dataStore.entries) { entry in
                        VStack(alignment: .leading) {
                            Text("\(entry.date, formatter: dateFormatter)")
                                .font(.headline)
                            Text(entry.text)
                                .font(.body)
                                .foregroundColor(Color.gray)
                            Text("Anger Level: \(entry.angerLevel)")
                                .font(.caption)
                                .foregroundColor(Color.red)
                        }
                    }
                    .onDelete { indexSet in
                        deleteEntry(at: indexSet)
                        dataStore.saveEntries()
                    }
                }
            }
            .padding()
            .onDisappear {
                dataStore.saveEntries()
            }
        }
    }
    
    // Function to save a new anger entry
    func saveEntry() {
        guard !newText.isEmpty else { return }
        let newEntry = AngerEntry(date: Date(), text: newText, angerLevel: selectedAngerLevel)
        dataStore.entries.append(newEntry)
        newText = ""
    }
    
    // Function to delete an anger entry
    func deleteEntry(at offsets: IndexSet) {
        dataStore.entries.remove(atOffsets: offsets)
    }
    
    // Date formatter
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(dataStore: DataStore())
    }
}

*/

/*
//export features work well, want to add title to it
import SwiftUI
import UIKit

// Data Model for Anger Entry
struct AngerEntry: Identifiable, Codable {
    var id: UUID
    let date: Date
    var text: String
    var angerLevel: String // Can be "Low", "Medium", or "High"
    
    init(id: UUID = UUID(), date: Date, text: String, angerLevel: String) {
        self.id = id
        self.date = date
        self.text = text
        self.angerLevel = angerLevel
    }
}

// Main App View
struct AngryKidApp: App {
    @StateObject var dataStore = DataStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView(dataStore: dataStore)
        }
    }
}

// Data Store for managing persistence
class DataStore: ObservableObject {
    @Published var entries: [AngerEntry] = []
    
    init() {
        loadEntries()
    }
    
    func saveEntries() {
        do {
            let encodedData = try JSONEncoder().encode(entries)
            UserDefaults.standard.set(encodedData, forKey: "angerEntries")
            print("Entries saved successfully.")
        } catch {
            print("Error saving entries: \(error)")
        }
    }
    
    func loadEntries() {
        if let encodedData = UserDefaults.standard.data(forKey: "angerEntries") {
            do {
                let savedEntries = try JSONDecoder().decode([AngerEntry].self, from: encodedData)
                entries = savedEntries
                print("Entries loaded successfully.")
            } catch {
                print("Error loading entries: \(error)")
            }
        }
    }
    
    func exportAllEntries() {
        let exportString = entries.map { entry -> String in
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            let formattedDate = dateFormatter.string(from: entry.date)
            return "\(formattedDate) - \(entry.text) - Anger Level: \(entry.angerLevel)"
        }.joined(separator: "\n")
        
        let activityViewController = UIActivityViewController(activityItems: [exportString], applicationActivities: nil)
        
        UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
    }
}

// Main Content View
struct ContentView: View {
    @ObservedObject var dataStore: DataStore
    @State private var newText: String = ""
    @State private var selectedAngerLevel: String = "Low"
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(colors: [Color(#colorLiteral(red: 1, green: 0.5212053061, blue: 1, alpha: 1)),.clear], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            VStack {
                Text("Angry Kid")
                    .font(.largeTitle)
                    .padding()
                
                TextField("Write down your anger here...", text: $newText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Picker(selection: $selectedAngerLevel, label: Text("Anger Level")) {
                    Text("Low").tag("Low")
                    Text("Medium").tag("Medium")
                    Text("High").tag("High")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                Button("Save Anger") {
                    saveEntry()
                    dataStore.saveEntries()
                }
              
                .font(.title2)
                .padding()
                .frame(width: 233)
                .background(Color(#colorLiteral(red: 1, green: 0.5212053061, blue: 1, alpha: 1)))
                .cornerRadius(25)
                .foregroundColor(.black)
                .padding()
                .shadow(color: Color.black.opacity(0.5), radius: 5, x: 0, y: 2)
                
                Button("Export All") {
                    dataStore.exportAllEntries()
                }
                .font(.title2)
                .padding()
                .frame(width: 233)
                .background(Color.white)
                .cornerRadius(25)
                .foregroundColor(.black)
                .padding()
                .shadow(color: Color.black.opacity(0.5), radius: 5, x: 0, y: 2)
                
                List {
                    ForEach(dataStore.entries) { entry in
                        VStack(alignment: .leading) {
                            Text("\(entry.date, formatter: dateFormatter)")
                                .font(.headline)
                            Text(entry.text)
                                .font(.body)
                                .foregroundColor(Color.gray)
                            Text("Anger Level: \(entry.angerLevel)")
                                .font(.caption)
                                .foregroundColor(Color.red)
                        }
                    }
                    .onDelete { indexSet in
                        deleteEntry(at: indexSet)
                        dataStore.saveEntries()
                    }
                }
            }
            .padding()
            .onDisappear {
                dataStore.saveEntries()
        }
        }
    }
    
    // Function to save a new anger entry
    func saveEntry() {
        guard !newText.isEmpty else { return }
        let newEntry = AngerEntry(date: Date(), text: newText, angerLevel: selectedAngerLevel)
        dataStore.entries.append(newEntry)
        newText = ""
    }
    
    // Function to delete an anger entry
    func deleteEntry(at offsets: IndexSet) {
        dataStore.entries.remove(atOffsets: offsets)
    }
    
    // Date formatter
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(dataStore: DataStore())
    }
}

*/


/*

//app working well, able to save data, but I want export features
import SwiftUI

// Data Model for Anger Entry
struct AngerEntry: Identifiable, Codable {
    var id: UUID
    let date: Date
    var text: String
    var angerLevel: String // Can be "Low", "Medium", or "High"
    
    init(id: UUID = UUID(), date: Date, text: String, angerLevel: String) {
        self.id = id
        self.date = date
        self.text = text
        self.angerLevel = angerLevel
    }
}

// Main App View
struct AngryKidApp: App {
    @StateObject var dataStore = DataStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView(dataStore: dataStore)
        }
    }
}

// Data Store for managing persistence
class DataStore: ObservableObject {
    @Published var entries: [AngerEntry] = []
    
    init() {
        loadEntries()
    }
    
    func saveEntries() {
        do {
            let encodedData = try JSONEncoder().encode(entries)
            UserDefaults.standard.set(encodedData, forKey: "angerEntries")
            print("Entries saved successfully.")
        } catch {
            print("Error saving entries: \(error)")
        }
    }
    
    func loadEntries() {
        if let encodedData = UserDefaults.standard.data(forKey: "angerEntries") {
            do {
                let savedEntries = try JSONDecoder().decode([AngerEntry].self, from: encodedData)
                entries = savedEntries
                print("Entries loaded successfully.")
            } catch {
                print("Error loading entries: \(error)")
            }
        }
    }
}




// Main Content View
struct ContentView: View {
    @ObservedObject var dataStore: DataStore
    @State private var newText: String = ""
    @State private var selectedAngerLevel: String = "Low"
    
    var body: some View {
        VStack {
            Text("Angry Kid")
                .font(.largeTitle)
                .padding()
            
            TextField("Write down your anger here...", text: $newText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Picker(selection: $selectedAngerLevel, label: Text("Anger Level")) {
                Text("Low").tag("Low")
                Text("Medium").tag("Medium")
                Text("High").tag("High")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            Button("Save Anger Entry") {
                saveEntry()
                dataStore.saveEntries()
                
            }
            .padding()
            
            List {
                ForEach(dataStore.entries) { entry in
                    VStack(alignment: .leading) {
                        Text("\(entry.date, formatter: dateFormatter)")
                            .font(.headline)
                        Text(entry.text)
                            .font(.body)
                            .foregroundColor(Color.gray)
                        Text("Anger Level: \(entry.angerLevel)")
                            .font(.caption)
                            .foregroundColor(Color.red)
                    }
                }
                .onDelete { indexSet in
                      deleteEntry(at: indexSet)
                      dataStore.saveEntries() // Add saveEntries() call here
                  }
            }
        }
        .padding()
        
        .onDisappear {
               dataStore.saveEntries()
           }   }
    
    // Function to save a new anger entry
    func saveEntry() {
        guard !newText.isEmpty else { return }
        let newEntry = AngerEntry(date: Date(), text: newText, angerLevel: selectedAngerLevel)
        dataStore.entries.append(newEntry)
        newText = ""
    }
    
    // Function to delete an anger entry
    func deleteEntry(at offsets: IndexSet) {
        dataStore.entries.remove(atOffsets: offsets)
    }
    
    // Date formatter
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(dataStore: DataStore())
    }
}

*/
/*
//bagus namun mau savedata

import SwiftUI

// Data Model for Anger Entry
struct AngerEntry: Identifiable {
    let id = UUID()
    let date: Date
    var text: String
    var angerLevel: String // Can be "Low", "Medium", or "High"
}

// Main App View
struct AngryKidApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// Main Content View
struct ContentView: View {
    @State private var entries: [AngerEntry] = []
    @State private var newText: String = ""
    @State private var selectedAngerLevel: String = "Low"
    
    var body: some View {
        VStack {
            Text("Angry Kid")
                .font(.largeTitle)
                .padding()
            
            TextField("Write down your anger here...", text: $newText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Picker(selection: $selectedAngerLevel, label: Text("Anger Level")) {
                Text("Low").tag("Low")
                Text("Medium").tag("Medium")
                Text("High").tag("High")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            Button("Save Anger Entry") {
                saveEntry()
            }
            .padding()
            
            List {
                ForEach(entries) { entry in
                    VStack(alignment: .leading) {
                        Text("\(entry.date, formatter: dateFormatter)")
                            .font(.headline)
                        Text(entry.text)
                            .font(.body)
                            .foregroundColor(Color.gray)
                        Text("Anger Level: \(entry.angerLevel)")
                            .font(.caption)
                            .foregroundColor(Color.red)
                    }
                }
                .onDelete(perform: deleteEntry)
            }
        }
        .padding()
    }
    
    // Function to save a new anger entry
    func saveEntry() {
        guard !newText.isEmpty else { return }
        let newEntry = AngerEntry(date: Date(), text: newText, angerLevel: selectedAngerLevel)
        entries.append(newEntry)
        newText = ""
    }
    
    // Function to delete an anger entry
    func deleteEntry(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
    }
    
    // Date formatter
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}


#Preview {
    ContentView()
}
*/
