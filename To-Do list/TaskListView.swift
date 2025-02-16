import SwiftUI
//import Combine
//
//  TaskListView.swift
//  To-Do list
//
//  Created by Alexander Baum on 29.10.24.
//

struct TaskListView: View {
    @EnvironmentObject var taskManager: TaskManager
    @Binding var selectedTab: Int

    var body: some View {
        List {
            ForEach($taskManager.tasks) { $task in
                HStack(alignment: .center) {
                    VStack(alignment: .leading) {
                        Text(task.title).font(.headline)
                        Text(task.description).font(.body)
                        HStack {
                            Text(task.priority)
                            Spacer()
                            Text("Due: \(DateFormatter.taskDateFormatter.string(from: task.dueDate))")
                                .font(.subheadline).foregroundColor(.gray)
                        }
                        .font(.subheadline).foregroundColor(.gray)

                        Toggle(isOn: $task.isCompleted) {
                            Text(task.isCompleted ? "Done" : "Not Done")
                                .foregroundColor(task.isCompleted ? .green : .gray)
                        }
                        .toggleStyle(SwitchToggleStyle())
                        .font(.subheadline).foregroundColor(.gray)
                    }
                    .layoutPriority(1)
                    
                    NavigationLink(destination: EditTaskView(task: $task)) {
                        EmptyView()
                    }
                    .padding(.trailing)
                }
                .frame(maxWidth: .infinity)
            }
            .onDelete(perform: taskManager.deleteTask)
        }
        .navigationTitle("Tasks")
        .listStyle(InsetListStyle())
    }
}
