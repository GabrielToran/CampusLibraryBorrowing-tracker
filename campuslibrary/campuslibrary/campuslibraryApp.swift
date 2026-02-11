//
//  campuslibraryApp.swift
//  campuslibrary
//
//  Created by user290937 on 2/10/26.
//

import SwiftUI
import CoreData

@main
struct campuslibraryApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject var holder: LibraryHolder

        init() {
            let context = persistenceController.container.viewContext
            _holder = StateObject(wrappedValue: LibraryHolder(context))
        }
    
    var body: some Scene {
        WindowGroup {
            ContentView(context: persistenceController.container.viewContext)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                                       }
    }
}
