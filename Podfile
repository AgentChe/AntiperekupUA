source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '13.0'
inhibit_all_warnings!
use_frameworks!

target 'AntiperekupUA' do
  pod 'Alamofire'

  pod 'RxSwift'
  pod 'RxCocoa'  
  
  pod 'Kingfisher'
  
  pod 'NotificationBannerSwift'
  
  pod 'Firebase/Analytics'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Messaging'
end

post_install do |pi|
    pi.pods_project.targets.each do |t|
      t.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      end
    end
end
