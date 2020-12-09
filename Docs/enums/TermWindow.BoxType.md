**ENUM**

# `TermWindow.BoxType`

```swift
public enum BoxType
```

Box type around the screen
- none is none
- simple is just dashes and pipes (straight lines all the way)
- ticked is simple + tick marks

## Cases
### `none`

```swift
case none
```

### `simple`

```swift
case simple
```

### `ticked(_:_:)`

```swift
case ticked([(col: Int, str: String)],[(row: Int, str: String)])
```
