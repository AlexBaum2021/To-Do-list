import SwiftUI
//import Combine


struct Task: Codable, Identifiable {
    var id = UUID()
    var title: String
    var priority: String
    var dueDate: Date
    var description: String
    var isCompleted: Bool
}
func getPriorities (defaultValue: Bool = false) -> [String] {
     return defaultValue ? ["Medium"] : ["Low", "Medium", "High"]
}
extension View {
    func borderedField() -> some View {
        self
            .border(Color.blue, width: 1)
            .padding()
    }
}

class TaskManager: ObservableObject {
//    enum TaskPriority: String, CaseIterable {
//        case low = "Low"
//        case medium = "Medium"
//        case high = "High"
//    }
   
    
    
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






struct ContentView: View {
    //@StateObject private var taskManager = TaskManager()
    @State private var selectedTab = 0
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                
                TaskListView(selectedTab: $selectedTab)
                    .tabItem {
                        Label("Tasks", systemImage: "list.bullet")
                    }
                    .tag(0)
                
                AddTaskView(selectedTab: $selectedTab)
                    .tabItem {
                        Label("Add Task", systemImage: "plus.circle")
                    }
                    .tag(1)
            }
            .padding()
        }
        .environmentObject(TaskManager())
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
