//
//  ContentView.swift
//  campuslibrary
//
//  Created by user290937 on 2/10/26.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var holder: LibraryHolder
    
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \Book.addedAt, ascending: true)],
//        animation: .default)
//    private var books: FetchedResults<Book>
    init(context: NSManagedObjectContext) {
           _holder = StateObject(wrappedValue: LibraryHolder(context))
       }
    
    
    var body: some View {
        
        
        TabView {
            BooksView()
                .environmentObject(holder)
                .tabItem { Label("Books", systemImage: "book") }
            
            LoansView()
                .environmentObject(holder)
                .tabItem { Label("Loan",systemImage: "arrow.left.arrow.right" ) }
            
            MembersView()
                .environmentObject(holder)
                .tabItem { Label("Member", systemImage: "person.3") }
        }
        
        
        
//        NavigationView {
//            List {
//                ForEach(items) { item in
//                    NavigationLink {
//                        Text("Item at \(item.timestamp!, formatter: itemFormatter)")
//                    } label: {
//                        Text(item.timestamp!, formatter: itemFormatter)
//                    }
//                }
//                .onDelete(perform: deleteItems)
//            }
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    EditButton()
//                }
//                ToolbarItem {
//                    Button(action: addItem) {
//                        Label("Add Item", systemImage: "plus")
//                    }
//                }
//            }
//            Text("Select an item")
//        }
    }

//    private func addItem() {
//        withAnimation {
//            let newItem = Item(context: viewContext)
//            newItem.timestamp = Date()
//
//            do {
//                try viewContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//    }

//    private func deleteItems(offsets: IndexSet) {
//        withAnimation {
//            offsets.map { items[$0] }.forEach(viewContext.delete)
//
//            do {
//                try viewContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview{
   
}
    
    

