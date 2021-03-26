**CLASS**

# `TextWindow`

**Contents**

- [Properties](#properties)
  - `textBuffer`
  - `boxStyle`
  - `textData`
- [Methods](#methods)
  - `init(embedIn:)`
  - `clear()`
  - `newline()`
  - `add(_:)`
  - `add(_:)`
  - `replace(with:)`
  - `replace(with:)`
  - `colsDidChange()`
  - `rowsDidChange()`
  - `display()`

```swift
public class TextWindow : TermWindow
```

Text display window, with styles

## Properties
<details><summary markdown="span"><code>textBuffer</code></summary>

```swift
var textBuffer : NSMutableAttributedString = NSMutableAttributedString(string: "")
```

Text buffer
TODO: trim string above a certain size

</details>

<details><summary markdown="span"><code>boxStyle</code></summary>

```swift
public var boxStyle : TermBoxType = .simple
```

Current box style

</details>

<details><summary markdown="span"><code>textData</code></summary>

```swift
var textData : [(TermColor,TermStyle,String)] = []
```

Current decomposition of the text

</details>

## Methods
<details><summary markdown="span"><code>init(embedIn:)</code></summary>

```swift
public override init(embedIn: TermWindow? = nil)
```

</details>

<details><summary markdown="span"><code>clear()</code></summary>

```swift
public func clear()
```

Clears the entire text buffer

</details>

<details><summary markdown="span"><code>newline()</code></summary>

```swift
public func newline()
```

Adds a new line to the buffer

</details>

<details><summary markdown="span"><code>add(_:)</code></summary>

```swift
public func add(_ txt: String)
```

Add a default style string to the buffer
- Parameter txt: the string to add

#### Parameters

| Name | Description |
| ---- | ----------- |
| txt | the string to add |

</details>

<details><summary markdown="span"><code>add(_:)</code></summary>

```swift
public func add(_ txt: NSAttributedString)
```

Add a styled string to the buffer
- Parameter txt: the string to add

#### Parameters

| Name | Description |
| ---- | ----------- |
| txt | the string to add |

</details>

<details><summary markdown="span"><code>replace(with:)</code></summary>

```swift
public func replace(with txt: String)
```

Replaces the entire text buffer with the given string
- Parameter txt: the string replacing the buffer

#### Parameters

| Name | Description |
| ---- | ----------- |
| txt | the string replacing the buffer |

</details>

<details><summary markdown="span"><code>replace(with:)</code></summary>

```swift
public func replace(with txt: NSAttributedString)
```

Replaces the entire text buffer with the given string
- Parameter txt: the string replacing the buffer

#### Parameters

| Name | Description |
| ---- | ----------- |
| txt | the string replacing the buffer |

</details>

<details><summary markdown="span"><code>colsDidChange()</code></summary>

```swift
override func colsDidChange()
```

</details>

<details><summary markdown="span"><code>rowsDidChange()</code></summary>

```swift
override func rowsDidChange()
```

</details>

<details><summary markdown="span"><code>display()</code></summary>

```swift
func display()
```

Main function: displays the text on screen

</details>