import SwiftUI
import Combine


struct Task: Codable, Identifiable {
    var id = UUID()
    var title: String
    var priority: String
    var dueDate: Date
    var description: String
    var isCompleted: Bool
}

class TaskManager: ObservableObject {
    @Published var tasks: [Task] = [] {
        didSet {
            saveTasks(tasks)
        }
    }
    
    init() {
        tasks = loadTasks()
    }
    
    func addTask(title: String, description: String, priority: String, dueDate: Date) {
        let newTask = Task(title: title, priority: priority, dueDate: dueDate, description: description, isCompleted: false)
        tasks.append(newTask)
    }
    
    func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }
    
    func saveTasks(_ tasks: [Task]) {
        let filename = getDocumentsDirectory().appendingPathComponent("tasks.json")
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(tasks) {
            try? data.write(to: filename)
        }
    }
    
    func loadTasks() -> [Task] {
        let filename = getDocumentsDirectory().appendingPathComponent("tasks.json")
        if let data = try? Data(contentsOf: filename) {
            let decoder = JSONDecoder()
            if let tasks = try? decoder.decode([Task].self, from: data) {
                return tasks
            }
        }
        return []
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

extension DateFormatter {
    static let taskDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}

struct TaskListView: View {
    @State private var selectedTask: Task?
    @ObservedObject var taskManager: TaskManager
    @Binding var selectedTab: Int
    var body: some View {
        
        List {
            ForEach($taskManager.tasks) { $task in
                HStack (alignment: .center)  {
                    VStack(alignment: .leading) {
                        Text(task.title)
                            .font(.headline)
                        Text(task.description)
                            .font(.body)
                        HStack {
                            Text(task.priority)
                            Spacer()
                            Text(" \(DateFormatter.taskDateFormatter.string(from: task.dueDate))")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        
                        Spacer()
                        
                        HStack {
                            
                            
                            
                            Spacer()
                            Toggle(isOn: $task.isCompleted) {
                                Text(task.isCompleted ? "Done" : "Not Done")
                                    .foregroundColor(task.isCompleted ? .green : .gray)
                            }
                            .toggleStyle(SwitchToggleStyle())
                            
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            
                        }
                        
                    }
                    .layoutPriority(1)
                    Divider()
                    NavigationLink(destination: EditTaskView(task: $task)) {}
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



struct AddTaskView: View {
    
    @ObservedObject var taskManager: TaskManager
    @Binding var selectedTab: Int
    @State private var newTask: String = ""
    @State private var newDescription: String = ""
    @State private var selectedPriority = "Medium"
    @State private var dueDate = Date()
    let priorities = ["Low", "Medium", "High"]
    
    var body: some View {
        
        
        VStack {
            
            
            TextField("Enter new title", text: $newTask)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextEditor(text: $newDescription)
                .frame(height: 200)
                .border(Color.gray, width: 1)
                .padding()
            
            HStack {
                Picker(selection: $selectedPriority, label: Text("Priority")) {
                    ForEach(priorities, id: \.self) { priority in
                        Text(priority)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                Spacer()
                DatePicker("", selection: $dueDate, displayedComponents: [.date])
                    .datePickerStyle(CompactDatePickerStyle())
                
            }
            
            Button(action: {
                guard !newTask.isEmpty else { return }
                
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
        
    }
}

struct EditTaskView: View {
    @Binding var task: Task
    @Environment(\.dismiss) var dismiss

    let priorities = ["Low", "Medium", "High"]
    
       
    var body: some View {
        VStack {
            TextField("Task Title", text: $task.title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .foregroundColor(task.title.isEmpty ? Color.red : Color.blue)
                .border(task.title.isEmpty ? Color.red : Color.white, width: 1)
            
            TextEditor(text: $task.description)
                .frame(height: 200)
                .border(Color.gray, width: 1)
                .padding()
            
            HStack {
                Picker("Priority", selection: $task.priority) {
                    ForEach(priorities, id: \.self) { priority in
                        Text(priority)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Spacer()
                
                DatePicker("Due Date", selection: $task.dueDate, displayedComponents: .date)
                    .datePickerStyle(CompactDatePickerStyle())
            }
            .padding()
            
            Button(action: {
                guard !task.title.isEmpty else { return }
               
                dismiss()
            }) {
                Text("Save Changes")
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
            
            Spacer()
        }
        .navigationTitle("Edit Task")
    }
}

struct ContentView: View {
    @StateObject private var taskManager = TaskManager()
    @State private var selectedTab = 0
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                
                TaskListView(taskManager: taskManager, selectedTab: $selectedTab)
                    .tabItem {
                        Label("Tasks", systemImage: "list.bullet")
                    }
                    .tag(0)
                
                AddTaskView(taskManager: taskManager, selectedTab: $selectedTab)
                    .tabItem {
                        Label("Add Task", systemImage: "plus.circle")
                    }
                    .tag(1)
            }
            .padding()
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
