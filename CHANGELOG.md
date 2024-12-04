## 2.3.0

* **Added** new methods `fileFromMemory()` and `filesFromMemory()` for sharing small files using byte arrays. These methods should be used cautiously and are **not recommended for large files** due to potential memory issues.
* **Added** new methods `fileFromStorage()` and `filesFromStorage()` for sharing files using file paths. These methods are **recommended** for general use, especially with large files, to avoid memory-related errors.
* **Added** explicit namespace declaration for compatibility with latest Android Gradle Plugin.
* **Deprecated** methods `file()` and `files()`. It is recommended to use `fileFromStorage()` and `filesFromStorage()` instead. For small files, `fileFromMemory()` and `filesFromMemory()` can be used, but they are not recommended for large files due to potential memory issues.
* **Updated documentation** to clearly state the intended use cases for each method and to guide users toward the recommended approaches.
* **Breaking change**: If you are using the deprecated methods `file()` and `files()`, please switch to the new methods to avoid possible memory issues.

## 2.2.0

* Fix share file with text. When the text with one file was not shown.
* Detailed file type processing.
* **Breaking change**. To `files()` you need to pass the `mimeType` array.

## 2.1.1

* Fixed bug by granting permission. So now granting permission for the uri for each resolvable application.

## 2.1.0

* Published as `esys_flutter_share_plus`.
* `compileSdkVersion` upgraded to 31.

## 2.0.1

* migrate to V2

## 2.0.0

* migrate to null safety
* update path_provider to 2.0.0

## 1.0.3

* update example app

## 1.0.2

* update path_provider to 1.1.0
* optional text share added to Share.file & Share.files methods
* suppression of warnings "unchecked" in java code

## 1.0.1

* Update readme

## 1.0.0

* Breaking change. Adds support for sharing single and multiple files.

## 0.0.9

* Breaking change. Migrate from the deprecated original Android Support Library to AndroidX. This shouldn't result in any functional changes, but it requires   any Android apps using this plugin to [also migrate](https://developer.android.com/jetpack/androidx/migrate) if they're using the original support library.

## 0.0.8

* update path_provider to v0.5.0

## 0.0.7

* update compileSdkVersion to 28 and com.android.support:support-v4 to 28.0.0

## 0.0.6

* fixes crashes on iPad

## 0.0.5

* Use FileProvider subclass to avoid collisions

## 0.0.4

* meta information added

## 0.0.3

* meta information added

## 0.0.2

* meta information added

## 0.0.1

* initial release