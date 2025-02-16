import SwiftUI
//
//  AddTaskView.swift
//  To-Do list
//
//  Created by Alexander Baum on 29.10.24.
//


struct AddTaskView: View {
    @EnvironmentObject var taskManager: TaskManager // Заменили на EnvironmentObject
    @Binding var selectedTab: Int
    @State private var newTask: String = ""
    @State private var newDescription: String = ""
    @State private var selectedPriority = "Medium"
    @State private var dueDate = Date()
    @State private var showTitleError = false
    
    var body: some View {
        
        
        VStack {
            
            TextField("Enter new title", text: $newTask)
                .borderedField()
            
            TextEditor(text: $newDescription)
                .borderedField()
            
            HStack {
                Picker(selection: $selectedPriority, label: Text("Priority")) {
                    ForEach(getPriorities (), id: \.self) { priority in
                        Text(priority)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                Spacer()
                DatePicker("", selection: $dueDate, displayedComponents: [.date])
                    .datePickerStyle(CompactDatePickerStyle())
                
            }
            
            Button(action: {

                guard !newTask.isEmpty else {
                    showTitleError = true
                    return
                }
 
                taskManager.addTask(title: newTask,
                                    description: newDescription,
                                    priority: selectedPriority,
                                    dueDate: dueDate)
                selectedTab = 0
                newTask = ""
                newDescription = ""
                selectedPriority = "Medium"
                dueDate = Date()
                
            }) {
                Text("Add Task")
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
            
            Spacer()
        }
        .navigationTitle("Add Task")
        .alert(isPresented: $showTitleError) {
            Alert(
                title: Text("Error"),
                message: Text("Title cannot be empty."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
