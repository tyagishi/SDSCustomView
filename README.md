# SDSCustomView

convenience view collection
every view is already used for app but basically all views are under develop for improvement.

## RectangleSelector
View for selecting rectangle area
```swift
import SwiftUI
import SDSCustomView

struct ContentView: View {
    @State private var selectedRect: CGRect = .zero
    @State private var state: SelectionStatus = .selection

    var body: some View {
        VStack {
            Image("Photo").resizable().scaledToFit()
                .overlay {
                    RectangleSelector(state: $state, rect: $selectedRect).zIndex(1.0)
                }
                .onChange(of: selectedRect, {
                    print("new rect: \(selectedRect)")
                })
                .overlay {
                    if state == .done,
                       selectedRect.size != .zero {
                        RectShape(rect: selectedRect).stroke(lineWidth: 3).foregroundStyle(.orange)
                    }
                }
            HStack {
                Text("Current State: \(state.description)")
                Spacer()
                Button(action: {
                    state = .selection
                    selectedRect = .zero
                }, label: { Text("Re-Active") })
                Button(action: {
                    state = .resize
                }, label: { Text("Adjust") })
            }
        }
        .padding()
    }
}
```
## LazyView
NagivationStack/TabView container load chid views at initial time.
It might cause performance issue. if necessary wrap child view with LazyView, then child view initialization would be delayed.
```swift
struct ContentView: View {
    var body: some View {
        VStack {
            TabView(content: {
                Tab(content: { LazyView(View1()) },
                    label: { Label("View1", systemImage: "gear") })
                Tab(content: { LazyView(View2()) },
                    label: { Label("View2", systemImage: "gear") })
            })
        }
        .padding()
    }
}
```

## EditableText/EditableValue
initially Text but it will become TextField with click.

### option: indirectEdit
Useful for textField in List, otherwise updating List (comes from updating binding data) will take a way focus from TextField
Note: in indirectEdit-mode, need to have "return" or "loose focus" to apply input to binding

```
struct ContentView: View {
    @State private var text = "Hello"
    @State private var texts = ["Hello", "World"]
    var body: some View {
        VStack {
            EditableText(value: $text)
            List($texts, id: \.self) { $text in
                EditableText(value: $text)
                    .indirectEdit()
            }
        }
        .padding()
    }
}

```

## EditableToken/TokenField/TokenView
initially token view but it will become TokenField with click
note: EditableToken is not implemented yet
```
struct ContentView: View {
    @State private var selectedTokens: [String] = []
    @State private var tokens = ["Hello", "World"]
    var body: some View {
        VStack {
            let getSet = (getter: {
                return selectedTokens
            }, setter: { (newNames: [String]) in
                selectedTokens = newNames
            })
            TokenField(getSet: getSet, selectableTokens: tokens))
        }
        .padding()
    }
}

```

## AsyncView
View will display data which will be delivered later (then might be updated via Publisher)

```
import SwiftUI
import Combine
import SDSCustomView

struct ContentView: View {
    let updateProvider = PassthroughSubject<Int,Never>()

    var body: some View {
        VStack {
            AsyncView(content: { (value: Int) in
                Text(String(value))
            }, placeholder: {
                ProgressView()
            }, dataProvider: {
                return await longCalc()
            }, updateProvider: updateProvider.eraseToAnyPublisher())
            Button(action: {
                updateProvider.send((1...10).randomElement()!)
            }, label: { Text("Random") })
        }
    }
    
    func longCalc() async -> Int {
        // after long calculation
        try? await Task.sleep(for: .seconds(3))
        return 2
    }
}
```

## StatefulButton

## LongPressableButton

## TableView
currently only for macOS

## FixedWidthLabel

Sometimes we want to have fixed-width label"s" those have same width.
Usually we don't mind width value itself, but want to align leading/center/traiing in same width.

looks like following.

<img width=30% alt="FixedWidthLabel" src="https://user-images.githubusercontent.com/6419800/164699567-ec2592c4-3191-4b7e-8f4e-b137b62dd488.png">

You can easily achieve above layout with
```
VStack {
  FixedWidthLabel("123",widthFor: "0000").alignment(.trailing)
  FixedWidthLabel(  "1",widthFor: "0000").alignment(.trailing)
}
```

basically above is equivalent with following.
```
VStack {
    Text("0000")
      .hidden()
      .overlay(
         Text("123")
         .frame(maxWidth: .infinity, alignment: .trainling)
      )
    Text("0000")
      .hidden()
      .overlay(
         Text("1")
         .frame(maxWidth: .infinity, alignment: .trainling)
      )
}
```

Just for reducing boilerplates.

Note: it is NOT ultimately fixed width label.
in case user modify their text size setting, label width would be affected.


## obsoleted
 - HierarchicalReorderableForEach (OutlineView with Drag&Drop support, pure SwiftUI)
 - ChartView (pure SwiftUI) (will be obosleted soon)
 - OutlineView (based on AppKit)
 - TableView (based on AppKit)


