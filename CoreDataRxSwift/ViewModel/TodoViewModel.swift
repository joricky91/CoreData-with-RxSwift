//
//  TodoViewModel.swift
//  CoreDataRxSwift
//
//  Created by Jonathan Ricky Sandjaja on 09/02/23.
//

import Foundation
import CoreData
import RxSwift

class TodoViewModel {
    var todos = BehaviorSubject<[Todo]>(value: [Todo]())
    let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    func fetchTodoItem() {
        let request = NSFetchRequest<Todo>(entityName: "Todo")
        
        do {
            guard let todoData = try context?.fetch(request) else { return }
            self.todos.onNext(todoData)
        } catch {
            print("Error fetching data. Error: \(error)")
        }
    }
}
