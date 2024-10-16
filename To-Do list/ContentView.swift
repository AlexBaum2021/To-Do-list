import SwiftUI



struct Task: Codable, Identifiable {
            var id = UUID()
            var title: String
            var priority: String
            var dueDate: Date
            var description: String
            var isCompleted: Bool
            }

struct ContentView: View {

    @State private var tasks: [Task] = []
    @State private var newTask: String = ""
    @State private var newDescription: String = ""
    @State private var selectedPriority = "Medium"
    let priorities = ["Low", "Medium", "High"]

    
    var body: some View {
        VStack {
           
            Text("To-Do List")
                .font(.largeTitle)
                .padding()

            
            TextField("Enter new task", text: $newTask)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
           
            TextField("Enter new task", text: $newDescription)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
           
            Text("Select Task Priority:")
                        .font(.headline)

                  
            Picker(selection: $selectedPriority, label: Text("Priority")) {
                        ForEach(priorities, id: \.self) { priority in
                            Text(priority)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    
                    Text("Selected Priority: \(selectedPriority)")
                        .padding()


           
            Button(action: {
             
                if !newTask.isEmpty {
                    
                    let addTask = Task(title: newTask,
                                       priority: selectedPriority,
                                       dueDate: Date(),
                                       description: newDescription,
                                       isCompleted: false)
                    tasks.append(addTask)
                    saveTasks(tasks)

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

    
            List {
                ForEach($tasks) { $task in
                    VStack(alignment: .leading) {
                                Text(task.title)
                                    .font(.headline)
                                Text(task.description)
                                        .font(.body)
                                HStack {
                                    Text(task.priority)
                                    Spacer()
                                    Text("Due: \(task.dueDate, style: .date)")
                                }
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        
                                
                        
                        Spacer()
                                               
                                            
                                               Toggle(isOn: $task.isCompleted) {
                                                   
                                                   Text(task.isCompleted ? "Done" : "Not Done")
                                                       .foregroundColor(task.isCompleted ? .green : .red)
                                               }
                                               .onChange(of: task.isCompleted) {
                                                                          saveTasks(tasks)
                                                                      }
                                               .labelsHidden()
                            }
                  
                }
                .onDelete(perform: deleteTask)
            }
        }
        .padding()
        .onAppear {
            tasks = loadTasks()
        }
       
    }


        func deleteTask(at offsets: IndexSet) {
            tasks.remove(atOffsets: offsets)
            saveTasks(tasks)
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
