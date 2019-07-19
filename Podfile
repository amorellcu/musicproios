# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

target 'musicprof' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for SteechesPatient
  pod 'Alamofire', '~> 4.8'
  pod 'AlamofireImage', '~> 3.5'
  pod 'AEAccordion'
  pod 'SCLAlertView'
  pod 'SwiftLocation'
  pod 'SwiftKeychainWrapper'
  pod 'JTAppleCalendar', '~> 7.1'
  pod 'FacebookCore', '~> 0.5.0'
  pod 'FacebookLogin', '~> 0.5.0'
  pod 'FacebookShare', '~> 0.5.0'
  pod 'FBSDKCoreKit', '~> 4.38.0'
  pod 'FBSDKLoginKit', '~> 4.38.0'
  pod 'FBSDKShareKit', '~> 4.38.0'
  pod 'Braintree'
  pod 'ActionSheetPicker-3.0', '~> 2.3.0'
  pod 'M13Checkbox'
  pod 'PusherSwift', '~> 7.0'
  pod 'PushNotifications', '~> 2.0.2'

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        facebook_pods = ['FacebookCore', 'FacebookLogin', 'FacebookShare']
        if facebook_pods.include? target.name
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '4.2'
            end
        end
    end
end

target 'musicprofTests' do
  inherit! :search_paths
  # Pods for testing
end

target 'musicprofUITests' do
  inherit! :search_paths
  # Pods for testing
end
