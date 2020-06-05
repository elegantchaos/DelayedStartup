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
            List {
                ForEach(model.items) { item in
                    HStack {
                        Text(item.name)
                        Button(action: { self.delete(item: item) })  {
                            Text("Delete")
                        }
                    }
                }
            }

            Spacer()
            
            HStack {
                Button(action: add) {
                    Text("Add")
                }
                
                Button(action: test) {
                    Text("Test")
                }
            }

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    func add() {
        viewState.selectItemsToAdd()
    }
    
    func test() {
        model.performStartup()
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
