# SDSCustomView

convenience view collection
every view is already used for app but basically all views are under develop for improvement.

## EditableText
initially Text but it will become TextField with click.

### EditableTextBuffered
TextField but does not update Binding data until onSubmit
Useful for textField in List, otherwise updating List (comes from updating binding data) will take a way focus from TextField

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


