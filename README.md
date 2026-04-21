> BlueToast is version 3 of the BezelNotification package. Original functionality will be preserved, but future focus will be on in-window toasts.
>
> Version 3 is currently in **alpha testing**, meaning that some functionality works and some doesn't. Please refrain from submitting bug reports unless you're in the Blue Husky Alpha Testers group.



![macOS 14+](https://img.shields.io/badge/17%2B-grey?label=iOS&labelColor=blue) ![iOS 17+](https://img.shields.io/badge/17%2B-grey?label=iOS&labelColor=blue)




# BlueToast

Formerly (`BH`)`BezelNotification`, BlueToast is a way to present toasts in your apps across all Apple platforms.

![BlueToast examples](./docs/images/blueToastExamples.png)



## What is a toast?

Maybe you already know what it is, but it's not a HIG paradigm so I'll explain here for those who don't know.

Toasts are brief messages that appear on-screen for a moment, to tell the user that something happened, and then go away.
They're a very common paradigm in Android, and Apple system-level things sometimes use them as well, though folks have historically called these things like "bezel notifications" "popup UI", etc.. Things like the volume UI coming up when you change the volume, or Xcode's "Build Succeeded", or the Apple Pencil charging UI when you place it on the side of your iPad.

Here's some examples from outside this library:

![Examples of other toast messages](./docs/images/otherToastExamples.png)


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

You know those square notifications macOS does when you change the volume 'n' stuff? This is like that, but you can actually use it in your projects.

![A comparison between this package's bezel notifications and the macOS native ones. They're identical, except this package's version is more customizable.](./macOS%20%26%20BezelNotification%20comparison.png)

> This does _not_ use any secret system APIs (but instead creates its own bezel notifications from scratch), so this cannot interact with nor affect macOS's own system bezel notifications. If one is already showing, this might obscure it or be obscured by it instead of replacing it or waiting for it to hide.
> 
> This also means it can be used in App Store apps 🥳

The legacy of this package is its ability to show "bezel notifications" which look exactly like the system bezel notifications.

Version 3 of this package focuses more on in-app toasts, but it does indeed preserve and actively maintain the original functionality, just renamed from `BHBezelNotification` to `SystemBezelNotification` and moved from direct usage to the same API as all the new toast styles. Just use `.toastStyle(.systemBezel)`, and the same `.toast(...` API that all toasts use!

Of course, because of how system bezels work, they're only available on macOS. Other platforms cannot use it, but they can still use the Bezel style, which mimics the same style but constrained within an view. 



### Bezel

This is the in-window version of the System Bezel toast, which is available on all supported platforms.



### Snackbar



### Capsule



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



## Try it out!

To try out BlueToast without instaling it into your own project first, you can use [this demo app I put together](https://github.com/KyLeggiero/BlueToast-Demo-App)!
