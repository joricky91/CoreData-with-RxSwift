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
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func fetchTodoItem() {
        let request = NSFetchRequest<Todo>(entityName: "Todo")
        
        do {
            let todoData = try context.fetch(request)
            self.todos.onNext(todoData)
        } catch {
            print("Error fetching data. Error: \(error)")
        }
    }
    
    func saveData(task: String) {
        let newTodo = Todo(context: context)
        newTodo.id = UUID()
        newTodo.task = task
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        print("success")
    }
}
