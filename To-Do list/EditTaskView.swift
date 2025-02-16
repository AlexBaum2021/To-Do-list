import SwiftUI
//
//  EditTaskView.swift
//  To-Do list
//
//  Created by Alexander Baum on 29.10.24.
//


struct EditTaskView: View {
    @Binding var task: Task
    @Environment(\.dismiss) var dismiss
    @State private var showTitleError = false

    
    var body: some View {
        VStack {
            TextField("Task Title", text: $task.title)
                .borderedField()
                .border(task.title.isEmpty ? Color.red : Color.white, width: 1)
            
            TextEditor(text: $task.description)
                .borderedField()
            
            HStack {
                Picker("Priority", selection: $task.priority) {
                    ForEach(getPriorities (), id: \.self) { priority in
                        Text(priority)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Spacer()
                
                DatePicker("Due Date", selection: $task.dueDate, displayedComponents: .date)
                    .datePickerStyle(CompactDatePickerStyle())
            }
            .padding()
      
            Spacer()
        }
        .navigationTitle("Edit Task")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    if task.title.isEmpty {
                        showTitleError = true
                    } else {
                        dismiss()
                    }
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
            }
        }
        .alert(isPresented: $showTitleError) {
            Alert(
                title: Text("Error"),
                message: Text("Title cannot be empty."),
                dismissButton: .default(Text("OK"))
            )
        }
        
        
        
    }
}
