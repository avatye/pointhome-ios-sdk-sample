
source 'https://github.com/CocoaPods/Specs.git'
source 'https://dl.cloudsmith.io/public/avatye/ios-sdk/cocoapods/index.git'

platform :ios, '13.0'

#use_frameworks! :linkage => :static
use_frameworks!

target 'PointHomeSample' do
  # Comment the next line if you don't want to use dynamic frameworks

  # Pods for PointHomeSample
  
  pod 'AdCashFramework', :path => '../AvatyeFrameworks/sdk-ad-library-ios-src/'
  pod 'AvatyePointHome', :path => '../AvatyeFrameworks/sdk-point-home-ios-src'

    # AvatyePointHome cloudsmith Test
#  pod 'AvatyePointHome', '1.8.2'
#  pod 'AdPopcornSSP', '2.9.1'

#  pod 'AvatyeAdCash', :path => '../AvatyeFrameworks/sdk_adcash_ios/'
#  pod 'AvatyePointHome', :path => '../AvatyeFrameworks/sdk_pointhome_ios'

  # mediation
  # NAM
  pod "NAMSDK" , '7.5.3'
  pod "NAMSDK/MediationNDA", '7.5.3'

  # AppLovin
  pod 'AppLovinSDK', '13.0.1'
  # Pangle
  pod 'Ads-Global', '6.2.0.5'
  # UnityAds
  pod 'UnityAds', '4.12.2'
  # Vungle
  pod "VungleAds", '7.4.1'
  # Mintegral
  pod 'MintegralAdSDK', '7.7.1'
  # FaceBook Audience Network
  pod 'FBAudienceNetwork', '6.14.0'
  # GoogleAds / AdMob
  pod 'Google-Mobile-Ads-SDK', '10.13.0'
  # Fyber
  pod 'FairBidSDK', '3.47.0'
  # cauly
  pod 'CaulySDK', :git => 'https://github.com/cauly/CaulySDK_iOS.git', :tag => '3.1.22'

  pod 'AdFitSDK', '~> 3.14.0'

  # 기타
#  pod 'BuzzvilSDK', '= 5.3.1'
  
end

post_install do |installer|
  
  def installer.verify_no_static_framework_transitive_dependencies; end

    installer.pods_project.targets.each  do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      end
   end

#   installer.pods_project.build_configuration_list.build_configurations.each do |configuration|
#    configuration.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
#  end
end
