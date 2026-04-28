> Howl is version 3 of the BezelNotification package. Original functionality will be preserved, but future focus will be on in-window toasts. You can still `import BezelNotification`, but you're encouraged to `import Howl` instead.
>
> Version 3 is currently in **beta testing**, meaning that some functionality works and some doesn't. Please refrain from submitting bug reports unless you're in the Blue Husky Beta Testers group.



![macOS 14+](https://img.shields.io/badge/14%2B-grey?label=macOS&labelColor=blue) ![iOS 17+](https://img.shields.io/badge/17%2B-grey?label=iOS&labelColor=blue)

# Howl: Toast notifications for Apple platforms

Formerly (`BH`)`BezelNotification`, Howl is a way to present toasts in your apps in Apple platforms.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="./examples/Mac%20screenshots%20%28dark%29.png">
  <source media="(prefers-color-scheme: light)" srcset="./examples/Mac%20screenshots%20%28light%29.png">
  <img alt="Howl demo on macOS" src="./examples/Mac%20screenshots%20%28light%29.png">
</picture>

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="./examples/iPhone%20screenshots%20%28dark%29.png">
  <source media="(prefers-color-scheme: light)" srcset="./examples/iPhone%20screenshots%20%28light%29.png">
  <img alt="Howl demo on iOS" src="./examples/iPhone%20screenshots%20%28light%29.png">
</picture>



## What is a toast?

Maybe you already know what it is, but it's not a HIG paradigm so I'll explain here for those who don't know.

Toasts are brief messages that appear on-screen for a moment, to tell the user that something happened, and then go away.
They're a very common paradigm in Android, and Apple system-level things sometimes use them as well, though folks have historically called these things like "bezel notifications" "popup UI", etc.. Things like the volume UI coming up when you change the volume, or Xcode's "Build Succeeded", or the Apple Pencil charging UI when you place it on the side of your iPad.

Here's some examples from outside this library:

![TODO: Examples of other toast messages](./docs/images/otherToastExamples.png)


## Usage

This is designed to strike a balance between ease-of-use and customizability. For instance, this is the primary way it is intended to be used in the general case:

```swift
myView
    .toast(isPresented: $isLoading, text: "Loading...", icon: .myLoadingIcon)
```



## Styles

You can further customize the appearance using toast styles.

```swift
myView
    .toast(isPresented: $isLoading, text: "Loading...", icon: .myLoadingIcon)
    .toastStyle(.snackbar)
```

This, just like all SwiftUI styles, can be applied to parent views and will cascade to child views.
For example, you can set this on your `ContentView` to set the style of all toasts in your app, but have one which is different by setting the style on its view.

Of course, if you don't specify a style, a reasonable `.default` will be used instead.

This repo comes with some premade styles to get you started!



### System Bezel

![macOS 14+](https://img.shields.io/badge/14%2B-grey?label=macOS&labelColor=blue)

You know those square notifications macOS does when you change the volume 'n' stuff? This is like that, but you can actually use it in your projects.

```swift
myView
    .toastStyle(.systemBezel)
```

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="./examples/macOS%20%26%20SystemBezelNotification%20comparison%20%28dark%29.png">
  <source media="(prefers-color-scheme: light)" srcset="./examples/macOS%20%26%20SystemBezelNotification%20comparison%20%28light%29.png">
  <img alt="A comparison between this package's bezel notifications and the macOS native ones. They're identical, except this package's version is more customizable." src="./examples/macOS%20%26%20SystemBezelNotification%20comparison%20%28light%29.png">
</picture>

> This does _not_ use any secret system APIs (but instead creates its own bezel notifications from scratch), so this cannot interact with nor affect macOS's own system bezel notifications. If one is already showing, this might obscure it or be obscured by it instead of replacing it or waiting for it to hide.
> 
> This also means it can be used in App Store apps 🥳

The legacy of this package is its ability to show "bezel notifications" which look exactly like the system bezel notifications.

Version 3 of this package focuses more on in-app toasts, but it does indeed preserve and actively maintain the original functionality, just renamed from `BHBezelNotification` to `SystemBezelNotification` and moved from direct usage to the same API as all the new toast styles. Just use `.toastStyle(.systemBezel)`, and the same `.toast(...` API that all toasts use!

Of course, because of how system bezels work, they're only available on macOS. Other platforms cannot use it, but they can still use the Bezel style, which mimics the same style but constrained within an view. 



### Bezel

![macOS 14+](https://img.shields.io/badge/14%2B-grey?label=macOS&labelColor=blue) ![iOS 17+](https://img.shields.io/badge/17%2B-grey?label=iOS&labelColor=blue)

This is the in-window version of the System Bezel toast, which is available on all supported platforms.

```swift
myView
    .toastStyle(.bezel)
```

![TODO: Screenshots of the bezel toast](./examples/toast-bezel.png)



### Snackbar

![macOS 14+](https://img.shields.io/badge/14%2B-grey?label=macOS&labelColor=blue) ![iOS 17+](https://img.shields.io/badge/17%2B-grey?label=iOS&labelColor=blue)

This is similar to the kind of bottom-left notifications you'd see in many websites and Android apps.

```swift
myView
    .toastStyle(.snackbar)
```

![TODO: Screenshots of the bezel toast](./examples/toast-snackbar.png)





### Capsule

![macOS 14+](https://img.shields.io/badge/14%2B-grey?label=macOS&labelColor=blue) ![iOS 17+](https://img.shields.io/badge/17%2B-grey?label=iOS&labelColor=blue)

This is similar to the kind of bottom-center notifications you'd see in various Android apps and low-priority system alerts.

```swift
myView
    .toastStyle(.capsule)
```

![TODO: Screenshots of the bezel toast](./examples/toast-capsule.png)



### Custom styling

Toast styles are open; you can create your own! (Unlike `PickerStyle` 😤)

All you have to do is create a `struct` which implements the `ToastStyle` protocol. You style the way the toast will look when it appears, and this framework handles the rest.

```swift
struct MyToastStyle: ToastStyle {
    
    func body(_ configuration: Configuration) -> some View {
        Text(configuration.text)
            .foregroundStyle(.black)
            .background(Color.pink.blendMode(.plusLighter))
            .onTapGesture(perform: configuration.action?.userDidInteract ?? {})
            
            .transition(.move(edge: .top).animation(.bouncy))
    }
}



extension ToastStyle where Self == MyToastStyle {
    static let mine: Self { .init() }
}
``` 

All these parameters (aside from the callback) can be encapsulated in a `BezelParameters` object. This is useful for keeping pre-defned bezels, serializing them for user-customization, etc.

> ℹ️ Be aware that this is _not_ run within the SwiftUI framework. It must build a SwiftUI view in its `body` (which _will_ be rendered within SwiftUI), and that body function will be passed the current environment values in case it needs them.
> If you need to use things like `@State` or `@EnvironmentObject` fields, you can use a custom SwiftUI view somewhere inside the view built by the `body` function, and inside that custom view you may use `@State` and all other SwiftUI paradigms.




## Try it out!

To try out Howl without instaling it into your own project first, you can use [this demo app I put together](https://github.com/KyLeggiero/Howl-Demo-App)!
