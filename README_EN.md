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
2. Download dependencies via ```pod install --repo-update``` command in Terminal. Do not forget to ```cd``` to the template project folder. **Use the ```AviasalesSDKTemplate.xcworkspace``` to work with your project**.
3. Add your partner's token and marker in ```default_config.plist``` file to constants ```partner_marker``` and ```api_token```.
4. If you don't have partner marker and API token, please sign up on [Travelpayouts](https://travelpayouts.com/).
5. Use the ```default_config.plist``` config file to enable/disable flights/hotels tabs, to add app description, feedback email and App Store app link for the "About" page, to add localized values for external links and set default search parameters for the first app launch. 
### 📱 iOS versions support
Framework supports iOS 9.0 and higher
### 🖼 App Icon
**Do not forget to replace app icons** (Template project includes simple white icons by default). To do this you will need to replace icons in ```AviasalesSDKTemplate/Resources/App.xcassets/AppIcon.appiconset``` folder (20.png, 29.png, 40.png etc) with your own icons with same names.
### ✈️🏨 Tab selection
If you want to remove flights or hotels search tab, change values of ```flights_enabled``` and ```hotels_enabled``` to NO in Project settings. Settings tab can't be removed.
### 🔧 Predefined filters
If you want to limit search results by one or several airlines, add IATA's of these airlines to the config file with the ```available_airlines``` key as array elements. You can limit the cities for the hotel searching as well. To do this, set the ```selectable``` parameter to NO in the config file and fill the placeholder text for the search form header (```headers``` parameter in localization keys). Do not forget to specify search city id and title.
### 🇺🇸🇷🇺 Localization
Text localizations can be added with NSLSKey in "Attributes Inspector" section of xib-files.
### ✍🏻 RTL support
Travel SDK template app supports RTL languages. Note, that _hotel_ section becomes unavailable when you select RTL language in settings.
### 🔧🌻 Color customization
You can choose color scheme in ```ColorSchemeManager.swift``` file. Just add to ```current``` variable one of these values: BlackColorScheme() / BlueColorScheme() / PurpleColorScheme(). Or set CustomColorScheme() value and set up any color scheme you need in ```CustomColorScheme.swift``` file.
You can also customize the appearance and colors of elements in xib files. Check the available for editing fields in the "Attributes Inspector" section. You can use any values from ```JRColorScheme.h``` as color keys.
Here is a list of primary fields with explanations:

|Title|Description|
|--------|--------|
mainColor | Primary app color
actionColor | Actions highlight color
formTintColor | Search forms icons and buttons color
formBackgroundColor | Search forms background color
formTextColor | Saerch forms text color

If you need more customization (hotel photos loading activity indicator color, filters elements color, etc.), use settings in ```JRColorScheme.m``` file.
### 🤑 Appodeal ads setup
To get additional profit from ads, we've integrated Mobile Ads [Appodeal SDK](https://www.appodeal.com/) in the app. To configure it, specify the ```appodeal_key``` parameter in the ```default_config.plist``` file (get your API key by registering at [Appodeal](https://www.appodeal.com/)). Ads will appear on the waiting screens for tickets and hotels searching by default.
### ⭐️ Feedback
Set up the ```feedback_email``` and ```itunes_link``` parameters in ```default_config.plist``` file to activate "Contact us" and "Rate this app" links.
## 🏭 Use of Fabric/Crashlytics
**Fabric/Crashlytics** SDK is included in the Template project. It monitors crashes and helps distribute builds to testers. To activate these functions you need to register and get **API Key** и **Build Secret** at https://fabric.io. Further steps:
1) Fill in corresponding values in **fabric.sh** in the root folder
2) Fill in **Fabric > APIKey** in **AviasalesSDKTemplate-Info.plist**
