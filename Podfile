source 'https://github.com/CocoaPods/Specs.git'
source 'https://dl.cloudsmith.io/public/avatye/ios-sdk/cocoapods/index.git'
# Uncomment the next line to define a global platform for your project
 platform :ios, '13.0'

target 'SPCTestSample' do
  # Comment the next line if you don't want to use dynamic frameworks
#  use_frameworks!

  # Pods for SPCTestSample
  pod 'AvatyeAdCash', :path => '../PointHomeSdk/sdk-ad-library-ios-src/'
#  pod 'AvatyePointHome', :path => '../AvatyeFrameworks/sdk-point-home-ios-src/'
  pod 'PointHome', :path => '../sdk-pointhome-spc-ios/'
  
#  pod 'AdPopcornSSP', '2.6.2'
  
#  pod 'PointHome', '1.4.13'

end

post_install do |installer|
    installer.pods_project.targets.each  do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      end
   end

   installer.pods_project.build_configuration_list.build_configurations.each do |configuration|
    configuration.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
  end
end
