
source 'https://github.com/CocoaPods/Specs.git'
#source 'https://dl.cloudsmith.io/public/avatye/ios-sdk/cocoapods/index.git'

platform :ios, '13.0'

#use_frameworks! :linkage => :static
use_frameworks!

target 'PointHomeSample' do
  # Comment the next line if you don't want to use dynamic frameworks

  # Pods for PointHomeSample
  
  pod 'AdCashFramework', :path => '../AvatyeFrameworks/sdk-ad-library-ios-src/'
  pod 'AvatyePointHome', :path => '../AvatyeFrameworks/sdk-point-home-ios-src'

    # AvatyePointHome cloudsmith Test
#  pod 'AvatyePointHome', '1.8.6'
#  pod 'AvatyeAdCash', '3.1.27'

#  pod 'AvatyeAdCash', :path => '../AvatyeFrameworks/sdk_adcash_ios/'
#  pod 'AvatyePointHome', :path => '../AvatyeFrameworks/sdk_pointhome_ios'

#  pod 'AdPopcornSSP', '2.9.10'
  # mediation
  # NAM
  pod "NAMSDK" , '8.4.0'
  pod "NAMSDK/MediationNDA", '8.4.0'

  # AppLovin
  pod 'AppLovinSDK', '13.1.0'
  # Pangle
  pod 'Ads-Global', '~> 7.1.0.7'
  # UnityAds
  pod 'UnityAds', '4.14.1'
  # Vungle
  pod "VungleAds", '7.4.5'
  # Mintegral
  pod 'MintegralAdSDK', '7.7.1'
  # FaceBook Audience Network
  pod 'FBAudienceNetwork', '6.14.0'
  # GoogleAds / AdMob
#  pod 'Google-Mobile-Ads-SDK', '12.2.0'
  # Fyber
  pod 'FairBidSDK', '3.47.0'
  # cauly
  pod 'CaulySDK', :git => 'https://github.com/cauly/CaulySDK_iOS.git', :tag => '3.1.22'

  pod 'AdFitSDK', '~> 3.14.0'

  # 기타
#  pod 'BuzzvilSDK', '= 6.0.1'

  pod 'DropDown'
  
  
end

post_install do |installer|
    installer.generated_projects.each do |project|
        project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
            end
        end
    end
end
