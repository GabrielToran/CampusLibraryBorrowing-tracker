//
//  BooksView.swift
//  campuslibrary
//
//  Created by user290937 on 2/10/26.
//

import SwiftUI

struct BooksView: View {
    
    @EnvironmentObject var holder: LibraryHolder
    @Environment(\.managedObjectContext) private var context


    @State private var showAdd = false
    @State private var showEdit: Book? = nil
    
    var filteredBooks: [Book] {
        holder.books.filter { book in
            let matchesCategory = holder.selectedCategory == nil || book.category == holder.selectedCategory
            
            
            let text = holder.searchText.lowercased()
            let matchesSearch = text.isEmpty ||
            (book.title?.lowercased().contains(text) ?? false) ||
            (book.author?.lowercased().contains(text) ?? false)
            
            
            return matchesCategory && matchesSearch
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredBooks) { book in
                    NavigationLink(value: book) {
                        VStack(alignment: .leading) {
                            Text(book.title ?? "Untitled")
                                .font(.headline)
                            
                            
                            Text(book.author ?? "Unknown author")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onDelete { indexSet in
                    indexSet.map { filteredBooks[$0] }.forEach { book in
                        holder.deleteBook(book, context)
                    }
                }
            }
            .navigationTitle("Books")
            .searchable(text: Binding(
                get: { holder.searchText },
                set: { holder.setSearch($0, context) }
            ), prompt: "Search title or author")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAdd = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAdd) {
                AddBookView()
                    .environmentObject(holder)
            }
        }
    }
}

struct AddBookView: View {
    @EnvironmentObject var holder: LibraryHolder
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var context
    
    
    @State private var title = ""
    @State private var author = ""
    @State private var isbn = ""
    
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
                TextField("Author", text: $author)
                TextField("ISBN", text: $isbn)
            }
            .navigationTitle("Add Book")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        holder.createBook(title: title, author: author,
                            isbn: isbn,
                                          category: nil,             context)
                        dismiss()
                    }
                }
            }
        }
    }
}

struct EditBookView: View {
    @EnvironmentObject var holder: LibraryHolder
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var context
    
    @State var book: Book
    @State private var title: String = ""
    @State private var author: String = ""
    @State private var isbn: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
                TextField("Author", text: $author)
                TextField("ISBN", text: $isbn)
            }
            .navigationTitle("Edit Book")
            .onAppear {
                title = book.title ?? ""
                author = book.author ?? ""
                isbn = book.isbn ?? ""
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        holder.updateBook(
                            book: book,
                            title: title,
                            author: author,
                            isbn: isbn,
                            isAvailable: book.isAvailable,
                            category: book.category,
                            
                            context
                        )
                        dismiss()
                    }
                }
            }
        }
    }
}



