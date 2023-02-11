//
//  ViewController.swift
//  CoreDataRxSwift
//
//  Created by Jonathan Ricky Sandjaja on 07/02/23.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    private var viewModel = TodoViewModel()
    private var bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = "Todo List"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(tapAddButton))
        view.addSubview(tableView)
        setupContraints()
        viewModel.fetchTodoItem()
        setupBindings()
    }

    lazy var tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    func setupBindings() {
        tableView.rx.setDelegate(self).disposed(by: bag)
        
        viewModel.todos.bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)) { row, item, cell in
            cell.textLabel?.text = item.task
        }
        .disposed(by: bag)
    }
    
    func setupContraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            tableView.heightAnchor.constraint(equalTo: safeArea.heightAnchor),
        ])
    }
    
    @objc func tapAddButton() {
        let alert = UIAlertController(title: "Add Task", message: "Enter your new task", preferredStyle: .alert)
        
        alert.addTextField { field in
            field.placeholder = "Enter task..."
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { _ in
            if let field = alert.textFields?.first {
                if let text = field.text, !text.isEmpty {
                    self.viewModel.saveData(task: text)
                    self.viewModel.fetchTodoItem()
                }
            }
        }))
        
        present(alert, animated: true)
        
    }
    
}


extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteButton = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            do {
                let current = try self.viewModel.todos.value()[indexPath.row]
                self.viewModel.context.delete(current)
                
                do {
                    try self.viewModel.context.save()
                } catch {
                    print(error)
                }
                
                self.viewModel.fetchTodoItem()
            } catch {
                print(error)
            }
        }
        
        let swipe = UISwipeActionsConfiguration(actions: [deleteButton])
        return swipe
    }
}

