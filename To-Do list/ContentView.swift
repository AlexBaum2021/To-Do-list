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
            saveTasks(tasks) // Сохраняем задачи при любом изменении
        }
    }

    init() {
        tasks = loadTasks() // Загружаем задачи при инициализации
    }

    func addTask(title: String, description: String, priority: String, dueDate: Date) {
        let newTask = Task(title: title, priority: priority, dueDate: dueDate, description: description, isCompleted: false)
        tasks.append(newTask)
    }

    func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets) // Удаляем задачу
    }
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


struct TaskListView: View {
    @ObservedObject var taskManager: TaskManager
//    @State private var isEnabled = false
   // @Binding var tasks: [Task]
    var body: some View {
        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter
        }()
        NavigationStack {
            
            
            List {
                ForEach($taskManager.tasks) { $task in
                    VStack(alignment: .leading) {
                        Text(task.title)
                            .font(.headline)
                        Text(task.description)
                            .font(.body)
                        HStack {
                            Text(task.priority)
                            Spacer()
                           // Text("Due: \(task.dueDate, style: .date)")
                            Text("Due: \(dateFormatter.string(from: task.dueDate))")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        
                        
                        Spacer()
                        
                        HStack {
                            //                            Text(task.priority)
                            Spacer()
                            Toggle(isOn: $task.isCompleted) {
                                Text(task.isCompleted ? "Done" : "Not Done")
                                    .foregroundColor(task.isCompleted ? .green : .red)
                            }
                            .toggleStyle(SwitchToggleStyle())
                            .onChange(of: task.isCompleted) {
                             //   saveTasks(tasks)
                        }
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        
                        
                        }
                        .labelsHidden()
                    }
                    
                }
                
              .onDelete(perform: taskManager.deleteTask)
            }
            .navigationTitle("Tasks")
            
            }
    }
    
//    func deleteTask(at offsets: IndexSet) {
//        tasks.remove(atOffsets: offsets)
////        //saveTasks(tasks)
//    }
    
}

struct AddTaskView: View {
//    @Binding var tasks: [Task]
    @ObservedObject var taskManager: TaskManager
    @Binding var selectedTab: Int
    @State private var navigateToTasks = false
    @State private var newTask: String = ""
    @State private var newDescription: String = ""
    @State private var selectedPriority = "Medium"
    @State private var dueDate = Date()
    let priorities = ["Low", "Medium", "High"]
     
    var body: some View {
        
        NavigationStack {
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
                    
                    if !newTask.isEmpty {
                        
//                        let addTask = Task(title: newTask,
//                                           description: newDescription,
//                                           priority: selectedPriority,
//                                           dueDate: dueDate,
//                                                isCompleted: false)
                        //tasks.append(addTask)
                        taskManager.addTask(title: newTask,
                                            description: newDescription,
                                            priority: selectedPriority,
                                            dueDate: dueDate)
                        navigateToTasks = true
                       //saveTasks(tasks)
                        selectedTab = 0
                        newTask = ""
                        newDescription = ""
                    }
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
}


///


struct ContentView: View {
//    @State private var tasks: [Task] = []
    @StateObject private var taskManager = TaskManager()
    @State private var selectedTab = 0
    var body: some View {
     
            
            
        TabView(selection: $selectedTab) {
                    
                    TaskListView(taskManager: taskManager)
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
//        .onAppear {
//            tasks = loadTasks()
//        }
        
    }
    
    

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
