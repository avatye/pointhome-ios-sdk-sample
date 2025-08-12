
source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '13.0'

#use_frameworks! :linkage => :static
use_frameworks!

target 'PointHomeSample' do
  # Comment the next line if you don't want to use dynamic frameworks

  # Pods for PointHomeSample
  pod 'AdCashFramework', :path => '../PointHomeSdk/src_adcash_ios/'
  #pod 'AvatyeAdCash', :path => '../PointHomeSdk/sdk_adcash_ios/'
  pod 'AvatyePointHome', :path => '../PointHomeSdk/src_pointhome_ios'
  #pod 'AvatyePointHome', :path => '../PointHomeSdk/sdk_pointhome_ios'

  # pod 'AvatyePointHome', '1.9.2'

  # mediation
  # NAM
  pod "NAMSDK" , '8.8.0'
  pod "NAMSDK/MediationNDA", '8.8.0'

  # AppLovin
  pod 'AppLovinSDK', '13.3.1'

  # Pangle
  pod 'Ads-Global', '~> 7.2.0.5'

  # UnityAds
  pod 'UnityAds', '4.16.0'

  # Vungle
  pod "VungleAds", '7.5.2'

  # Mintegral
  pod 'MintegralAdSDK', '7.7.7'

  # FaceBook Audience Network
  pod 'FBAudienceNetwork', '6.20.1'

  # GoogleAds / AdMob
  pod 'Google-Mobile-Ads-SDK', '12.8.0'

  # Fyber
  pod 'FairBidSDK', '3.47.0'

  # cauly
  pod 'CaulySDK', :git => 'https://github.com/cauly/CaulySDK_iOS.git', :tag => '3.1.22'

  pod 'AdFitSDK', '~> 3.14.0'

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
