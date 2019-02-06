# RocketChatViewController

RocketChatViewController is a Swift library that Rocket.Chat created to facilitate other teams to have a chat screen inside their applications. The library implements most functionality needed, such as displaying and updating the list of messages with a powerful diffing algorithm; a customizable message composer, with already-implemented features such as message autocompletion, editing, quoting, send and upload buttons.

We've been using RocketChatViewController in our [iOS application](https://github.com/RocketChat/Rocket.Chat.iOS) for a while now so it's very stable and you can already use it in your iOS app.

The architecture of the list is purely inspired in [IGListKit](https://github.com/Instagram/IGListKit) and depends on [DifferenceKit](https://github.com/ra1028/DifferenceKit) library to run the differences on the list elements. The whole list is completely `UIKit` based and works on top of a `UICollectionView`.

## Creators

- [@cardoso](https://github.com/cardoso)
- [@filipealva](https://github.com/filipealva)
- [@rafaelks](https://github.com/rafaelks)
