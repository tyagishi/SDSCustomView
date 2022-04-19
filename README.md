# SDSCustomView

convenience view collection

## FixedWidthLabel

Sometimes we want to have fixed-width labels.
Usually we don't mind width value itself, but want to align leading/center/traiing.

We want to see layout like

<img width="558" alt="FixedWidthLabel" src="https://user-images.githubusercontent.com/6419800/163898941-a9f8ad45-a30c-421b-9afe-9473749696e5.png" width="80" >

You can easily achieve above layout with
```
VStack {
  FixedWidthLabel("123", "0000").alignment(.trailing)
  FixedWidthLabel(  "1", "0000").alignment(.trailing)
}
```

basically above is equal to  followings
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
