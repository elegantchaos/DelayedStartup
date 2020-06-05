// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/06/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI
import SwiftUIExtensions

struct ContentView: View {
    @EnvironmentObject var model: Model
    @EnvironmentObject var viewState: ViewState
    @State var editing: Bool = false
    
    var body: some View {
        VStack {
            Text("Startup Items:")
            List() {
                ForEach(model.items) { item in
                    HStack {
                        if self.editing {
                            Button(action: { self.delete(item: item) })  {
                                SystemImage("NSStopProgressFreestandingTemplate")
                                    .foregroundColor(Color.red)
                            }.buttonStyle(BorderlessButtonStyle())

                        }
                        Text(item.name)
                    }
                }.onDelete(perform: delete)
            }.bindEditing(to: $editing)


            Spacer()
            
            HStack {
                Button(action: add) {
                    Text("Add")
                }
                
                Button(action: test) {
                    Text("Test")
                }
                
                Button(action: { self.editing = !self.editing }) {
                    Text("Edit")
                }
            }

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    func add() {
        viewState.selectItemsToAdd()
    }
    
    func test() {
        model.performStartup()
    }

    func delete(at offsets: IndexSet) {
        model.delete(at: offsets)
    }

    func delete(item: Model.Item) {
        model.delete(item: item)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
