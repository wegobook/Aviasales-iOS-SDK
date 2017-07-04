Aviasales Travel iOS SDK
=================
[![CocoaPods](https://img.shields.io/cocoapods/v/AviasalesSDK.svg)](https://cocoapods.org/pods/AviasalesSDK)
[![CocoaPods](https://img.shields.io/cocoapods/p/AviasalesSDK.svg)](https://cocoapods.org/pods/AviasalesSDK)
[![Travis](https://img.shields.io/travis/KosyanMedia/Aviasales-iOS-SDK/master.svg)](https://travis-ci.org/KosyanMedia/Aviasales-iOS-SDK)

## Description

[Aviasales](https://www.aviasales.ru) Travel iOS SDK is a framework for flights and hotels search engine integration. When your user books flight or hotel, you get paid. Aviasales, Jetradar and Hotellook official apps are based on this framework.

This framework includes:

* two static libraries to integrate with flights and hotels search engine;
* UI template project.
 
You may create your flights and hotels search apps based on this template. To track statistics and payments, please visit our affiliate network website — [Travelpayouts.com](https://www.travelpayouts.com/).

To learn more about the Travelpayouts affiliate network, please visit [Travelpayouts FAQ](https://support.travelpayouts.com/hc/en-us/articles/203955613-Commission-and-payments).

## <a name="usage"></a>How to build your own app using the template project
### 📲 Setup
1. Download the latest release of template project (not beta) here: [https://github.com/KosyanMedia/Aviasales-iOS-SDK/releases](https://github.com/KosyanMedia/Aviasales-iOS-SDK/releases).
2. Download dependencies via ```pod install --repo-update``` command in Terminal. Do not forget to ```cd``` to the template project folder.  
**Use the ```AviasalesSDKTemplate.xcworkspace``` to work with your project**.
3. Add your partner's token and marker in ```Config.h``` file to constants ```kJRAPIToken``` and ```kJRPartnerMarker```.
4. If you don't have partner marker and API token, please sign up on [Travelpayouts](https://travelpayouts.com/).

### 📱 iOS versions support
Framework supports iOS 9.0 and higher

### 🖼 App Icon
**Don't forget to replace app icons** (by default the template includes simple white icons). To do this you will need to replace images in ```AviasalesSDKTemplate/Resources/App.xcassets/AppIcon.appiconset``` folder (20.png, 29.png, 40.png etc) with your own images with same names.

### ✈️🏨 Tab selection
If you want to remove flights or hotels search tab, change values of TICKETS_ENABLED and HOTELS_ENABLED to 0 in "Build Settings" in project settings. Settings tab can't be removed.

### 🇺🇸🇷🇺 Localization
Text localizations can be added with NSLSKey in "Attributes Inspector" section of xib-files.

### 🔧🌻 Color customization
You can choose color scheme in ColorSchemeConfigurator.swift file. Just add to currentColorScheme variable one of these values: BlackColorScheme() / BlueColorScheme() / PurpleColorScheme(). Or set CustomColorScheme() value and set up any color scheme you need in CustomColorScheme.swift file.
You can also customize the appearance and colors of elements in xib files. Check the available for editing fields in the "Attributes Inspector" section. You can use any values from JRColorScheme.h as color keys.

Here is a list of primary fields with explanations:

|Title|Description|
|--------|--------|
tintColor | Color of all buttons and icons in the app
searchFormTintColor | Color of icons and buttons on the search screens
navigationBarBackgroundColor | Color of the navigation bar
navigationBarItemColor | Color of the navigation bar elements
searchFormBackgroundColor | Background color on the search screens
searchFormTextColor | Text color on the search screens
searchFormSeparatorColor | Color of the separator bars on the search screens
mainButtonBackgroundColor | Background color for "Search" buttons on the search screens
mainButtonTitleColor | Text color on the "Search" buttons on the search screens

If you need more customization (hotel photos loading activity indicator color, filters elements color, etc.), use settings in JRColorScheme.m file.

### 🤑 Appodeal ads setup

To get additional profit from advertisements, we've integrated Mobile Ads [Appodeal SDK](https://www.appodeal.com/) in the app. To configure it, specify the **kAppodealApiKey** parameter in the **Config.h** file (get your API key by registering at [Appodeal](https://www.appodeal.com/)).

By default, ads will appear on the waiting screens for tickets and hotels searching.

To test ads, turn on the **kAppodealTestingMode** test mode in the **Config.h** file. This test mode will work only in **Debug** configuration.

If you don't want to show ads to your users, set **NO** for **kShowAppodealAds** and leave **kAppodealApiKey** blank.

### ⭐️ Feedback
Set up **kContactUsEmail** and **kAppStoreRateLink** parameters in **Config.h** file to activate "Contact us" and "Rate this app" links.

## 🏭 Use of Fabric/Crashlytics
**Fabric/Crashlytics** SDK is included in the Template project. It monitors crashes and helps distribute builds to testers. To activate these functions you need to register and get **API Key** и **Build Secret** at https://fabric.io. Further steps:
1) Fill in corresponding values in **fabric.sh** in the root folder
2) Fill in **Fabric > APIKey** in **AviasalesSDKTemplate-Info.plist**
