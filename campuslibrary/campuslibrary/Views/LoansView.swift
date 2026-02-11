//
//  LoansView.swift
//  campuslibrary
//
//  Created by user290937 on 2/10/26.
//

import SwiftUI

struct LoansView: View {
    
    @EnvironmentObject var holder: LibraryHolder
    
    
    var sortedLoans: [Loan] {
        holder.loans.sorted { ($0.borrowedAt ?? .distantPast) > ($1.borrowedAt ?? .distantPast) }
    }
    
    
    func statusText(_ loan: Loan) -> String {
        if loan.returnedAt == nil { return "Active" }
        return "Returned"
    }
    
    
    func isOverdue(_ loan: Loan) -> Bool {
        guard loan.returnedAt == nil,
              let due = loan.dueAt else { return false }
        return due < Date()
    }
    
    var body: some View {
        NavigationStack {
            List(sortedLoans) { loan in
                VStack(alignment: .leading) {
                    Text(loan.book?.title ?? "Book")
                        .font(.headline)
                    
                    
                    Text(statusText(loan))
                        .foregroundColor(isOverdue(loan) ? .red : .secondary)
                }
            }
            .navigationTitle("Loans")
        }
    }
}


#Preview {
    LoansView()
}
