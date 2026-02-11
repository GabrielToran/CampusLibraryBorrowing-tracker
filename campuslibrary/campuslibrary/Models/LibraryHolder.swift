//
//  LibraryHolder.swift
//  campuslibrary
//
//  Created by user290937 on 2/10/26.
//

import Foundation
import CoreData
import Combine


class LibraryHolder: ObservableObject {
    
    //UI state
    @Published var selectedCategory: Category? =  nil
    @Published var searchText: String = ""
    
    
    
    
    //data
    @Published var categories : [Category] = []
    @Published var  books : [Book] = []
    @Published var loans : [Loan] = []
    @Published var members : [Member] = []
    
    init(_ context: NSManagedObjectContext ) {
        //seed the date
        seedIfNeeded(context)
                
        //refresh
        refreshAll(context)
        
    }
    
    //MARK !!-- refresh methods
    func refreshAll(_ context: NSManagedObjectContext){
        refreshCategories(context)
        refreshBooks(context)
          refreshMembers(context)
                refreshLoans(context)
    }
    
    
    
    func refreshCategories(_ context: NSManagedObjectContext) {
        categories = fetchCategories(context)
    }
    
    
    func refreshBooks(_ context: NSManagedObjectContext) {
              books = fetchBooks(context)
    }
    
    func refreshMembers(_ context: NSManagedObjectContext) {
              members = fetchMembers(context)
    }
    
    func refreshLoans(_ context: NSManagedObjectContext) {
              loans = fetchloans(context)
    }
    
    
    
    
    //MARK !! --fetch methods
    func fetchCategories(_ context: NSManagedObjectContext) -> [Category] {
        do {
            return try context.fetch(categoriesFetch())
        }catch {
            fatalError("Unresolved error \(error)")
        }
        
    }
    
    //books
    func fetchBooks(_ context:NSManagedObjectContext) -> [Book] {
        do {
            return try context.fetch(booksFetch())
        }catch {
            fatalError("Unresolved error \(error)")
        }
    }
    
   //members
    func fetchMembers(_ context:NSManagedObjectContext) -> [Member] {
        do {
            return try context.fetch(membersFetch())
        }catch {
            fatalError("Unresolved error \(error)")
        }
    }
    //loans
    func fetchloans(_ context:NSManagedObjectContext) -> [Loan] {
        do {
            return try context.fetch(loansFetch())
        }catch {
            fatalError("Unresolved error \(error)")
        }
    }
    
    
    //fetch requests
    func categoriesFetch() -> NSFetchRequest<Category> {
        let request = Category.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Category.name, ascending: true)
            
        ]
        return request
        
    }
    
    func booksFetch() -> NSFetchRequest<Book> {
        let request = Book.fetchRequest()
        
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Book.title, ascending: true),
            
            NSSortDescriptor(keyPath: \Book.addedAt, ascending: true)
        ]
        request.predicate = booksPredicate()
        return request
    }
    
    
    func membersFetch() -> NSFetchRequest<Member> {
        let request = Member.fetchRequest()
        
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Member.name, ascending: true),
            
        
        ]
        return request
    }
    
    
    func loansFetch() -> NSFetchRequest<Loan> {
        let request = Loan.fetchRequest()
        
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Loan.borrowedAt, ascending: true),
            
            
        ]
        return request
    }
    
    
    //MARK !! -- Predicate filter + search
    
    private  func booksPredicate() -> NSPredicate? {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        var parts : [NSPredicate] = []
        
        if let category = selectedCategory {
            parts.append(NSPredicate(format: "category == %@", category))
        }
        if !trimmed.isEmpty {
            // search in name OR details (case/diacritic insensitive)
                        parts.append(NSPredicate(format: "(author CONTAINS[cd] %@) OR (details CONTAINS[cd] %@)", trimmed, trimmed))
        }
        if parts.isEmpty {return nil }
        if parts.count == 1 { return parts[0] }
        
        return NSCompoundPredicate(andPredicateWithSubpredicates: parts)

    }
    
    //set the category
    func setCategory(_ category: Category? , _ context: NSManagedObjectContext) {
        selectedCategory = category
        
        //refresh the list of books
        refreshBooks(context)
    }
    
    func setSearch(_ text: String, _ context: NSManagedObjectContext) {
            searchText = text
            refreshBooks(context)
        }
    
    //MARK !! --  Category CRUD
    
    func createCatgory(name: String, _ context: NSManagedObjectContext) {
        let n = name.trimmingCharacters(in: .whitespacesAndNewlines)
               guard !n.isEmpty else { return }

               let c = Category(context: context)
               c.id = UUID()
               c.name = n

               saveContext(context)
        
    }
    
    
    
    //MARK !! - Book CRUD
    func createBook(
            title: String,
            author: String,
            isbn: String?,
            category: Category?,
            _ context: NSManagedObjectContext
        ) {
            let t = title.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !t.isEmpty else { return }

            let b = Book(context: context)
            b.id = UUID()
            b.title = t
            b.author = author.trimmingCharacters(in: .whitespacesAndNewlines)
            b.isbn = isbn
            b.addedAt = Date()
            b.isAvailable = true
            b.category = category

            saveContext(context)
        }
    
     func updateBook(
        book: Book,
        title: String,
        author: String,
        isbn: String,
        isAvailable: Bool,
        category: Category?,
        _ context: NSManagedObjectContext
     ) {
         book.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
         book.author = author.trimmingCharacters(in: .whitespacesAndNewlines)
         book.isbn = isbn.trimmingCharacters(in: .whitespacesAndNewlines)
         book.isAvailable = isAvailable
         book.category = category
         
         saveContext(context)
     }

        func deleteBook(_ book: Book, _ context: NSManagedObjectContext) {
            context.delete(book)
            saveContext(context)
        }
    
    //MARK !! -- Member CRUD
    func createMember(name: String, email: String, _ context: NSManagedObjectContext) {
        let n = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !n.isEmpty else {return}
        
        let m = Member(context: context)
        m.id = UUID()
        m.name = n
        m.email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        m.joinedAt = Date()
        
        saveContext(context)
    }
    
    func deleteMember(_ member: Member, _ context: NSManagedObjectContext) {
        context.delete(member)
        saveContext(context)
    }
    
    //MARK !! -- Borrow Logic
    func borrowBook(member: Member, book: Book, dueDays: Int = 7 , _ context: NSManagedObjectContext) -> Bool {
        guard book.isAvailable else { return  false }

                let loan = Loan(context: context)
                loan.id = UUID()
                loan.borrowedAt = Date()
                loan.dueAt = Calendar.current.date(byAdding: .day, value: dueDays, to: Date())
                loan.returnedAt = nil
                loan.member = member
                loan.book = book

                book.isAvailable = false

                saveContext(context)
        return true
    }
    
    //MARK !! -- Return  Logic
    
    func returnLoan(_ loan: Loan, _ context: NSManagedObjectContext) {
           guard loan.returnedAt == nil else { return }

           loan.returnedAt = Date()
           loan.book?.isAvailable = true

           saveContext(context)
       }
    
     // MARK !! -- Seed
    private func seedIfNeeded(_ context: NSManagedObjectContext) {
            let req: NSFetchRequest<Category> = Category.fetchRequest()
            req.fetchLimit = 1
            let count = (try? context.count(for: req)) ?? 0
            guard count == 0 else { return }

            let fiction = Category(context: context)
            fiction.id = UUID()
            fiction.name = "Fiction"
        
        let b1 = Book(context: context)
               b1.id = UUID()
               b1.title = "1984"
               b1.author = "George Orwell"
               b1.addedAt = Date()
               b1.isAvailable = true
               b1.category = fiction

            saveContext(context)
        }
    
    
    
    
    func saveContext(_ context: NSManagedObjectContext) {
        
        do {
            try context.save()
            //refresh context
            refreshAll(context)
            
        } catch {
            
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        
        
    }
    
}
