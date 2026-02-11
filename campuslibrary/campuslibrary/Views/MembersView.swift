//
//  MembersView.swift
//  campuslibrary
//
//  Created by user290937 on 2/10/26.
//

import SwiftUI

struct MembersView: View {
    
    @EnvironmentObject var holder: LibraryHolder
    @Environment(\.managedObjectContext) private var context
    
    
    @State private var showAdd = false
    @State private var showBorrowAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(holder.members) { member in
                    NavigationLink(destination: MemberDetailView(member: member)) {
                        Text(member.name ?? "Unnamed")
                    }
                }
            }
            .navigationTitle("Members")
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
                AddMemberView()
                    .environmentObject(holder)
            }
        }
    }
}

struct MemberDetailView: View {
    let member: Member
    @EnvironmentObject var holder: LibraryHolder
    @Environment(\.managedObjectContext) private var context
    
    
    @State private var showBorrowSheet = false
    @State private var selectedBook: Book? = nil
    @State private var showBorrowAlert = false
    @State private var alertMessage = ""
    
    
    var activeLoans: [Loan] {
        holder.loans.filter { $0.member == member && $0.returnedAt == nil }
    }
    
    
    var pastLoans: [Loan] {
        holder.loans.filter { $0.member == member && $0.returnedAt != nil }
    }
    
    var availableBooks: [Book] {
            holder.books.filter { $0.isAvailable }
        }
    
    
    var body: some View {
        List {
            Section("Active Loans") {
                ForEach(activeLoans) { loan in
                    Text(loan.book?.title ?? "Book")
                }
            }
            
            
            Section("Past Loans") {
                ForEach(pastLoans) { loan in
                    Text(loan.book?.title ?? "Book")
                }
            }
            
            
            Section {
                Button("Borrow a Book") {
                    if availableBooks.isEmpty {
                        alertMessage = "No books are currently available for borrowing."
                        showBorrowAlert = true
                    } else {
                        showBorrowSheet = true
                    }
                }
                .disabled(availableBooks.isEmpty)
                .sheet(isPresented: $showBorrowSheet) {
                    BorrowBookView(member: member)
                        .environmentObject(holder)
                        .environment(\.managedObjectContext, context)
                }
            }
        }
        .navigationTitle(member.name ?? "Member")
        .alert(alertMessage, isPresented: $showBorrowAlert) {
            Button("OK", role: .cancel) {}
        }
    }
}


struct BorrowBookView: View {
    let member: Member
    @EnvironmentObject var holder: LibraryHolder
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedBook: Book? = nil
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var availableBooks: [Book] {
        holder.books.filter { $0.isAvailable }
    }
    
    var body: some View {
        NavigationStack {
            List(availableBooks, id: \.id) { book in
                HStack {
                    VStack(alignment: .leading) {
                        Text(book.title ?? "Untitled")
                            .font(.headline)
                        Text(book.author ?? "Unknown author")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    if selectedBook == book {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedBook = book
                }
            }
            .navigationTitle("Select a Book")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Borrow") {
                        guard let book = selectedBook else { return }
                        let success = holder.borrowBook(member: member, book: book, dueDays: 7, context)
                        if success {
                            dismiss()
                        } else {
                            alertMessage = "This book is not available."
                            showAlert = true
                        }
                    }
                    .disabled(selectedBook == nil)
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert(alertMessage, isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            }
        }
    }
}





struct AddMemberView: View {
    @EnvironmentObject var holder: LibraryHolder
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var context
    
    
    @State private var name = ""
    @State private var email = ""
    
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                TextField("Email", text: $email)
            }
            .navigationTitle("Add Member")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        holder.createMember(name: name,
                            email:email,
                            context)
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    MembersView()
}
