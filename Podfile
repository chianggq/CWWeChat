platform :ios, '9.0'

target 'CWWeChat' do

  use_frameworks!
  inhibit_all_warnings!

  # Pods for CWWeChat  
  # layout
  pod 'SnapKit'

  # request
  pod 'YYText'
  pod 'SwiftyImage'
  pod 'Kingfisher'

  pod 'SQLiteMigrationManager.swift'
  pod 'SQLite.swift'
  pod 'RxSwift'
  pod 'RxCocoa'

  pod 'Moya/RxSwift'
# log
  pod 'SwiftyBeaver'
  
  # chat
  pod 'XMPPFramework', :git => 'https://github.com/robbiehanson/XMPPFramework.git', :branch => 'master'

  # UI
  pod 'MBProgressHUD'
 
  pod 'CWActionSheet'
  pod 'CWShareView'

  pod 'FSPagerView'
  
  # tool
  pod 'Hue'
  pod 'SwiftyJSON'
  pod 'KVOController'
  
  pod 'SwiftLint'


  # 本地pod
  pod 'TableViewManager', :path => './Module/TableViewManager/TableViewManager.podspec'
  pod 'ChatClient', :path => './Module/ChatClient/ChatClient.podspec'
  pod 'ChatKit', :path => './Module/ChatKit/ChatKit.podspec'
  pod 'MomentKit', :path => './Module/MomentKit/MomentKit.podspec'


    # Your 'node_modules' directory is probably in the root of your project,
    # but if not, adjust the `:path` accordingly
    pod 'React', :path => './ReactNative/node_modules/react-native', :subspecs => [
    'Core',
    'CxxBridge', # Include this for RN >= 0.47
    'DevSupport', # Include this to enable In-App Devmenu if RN >= 0.43
    'RCTText',
    'RCTNetwork',
    'RCTWebSocket', # needed for debugging
    # Add any other subspecs you want to use in your project
    ]
    # Explicitly include Yoga if you are using RN >= 0.42.0
    pod 'yoga', :path => './ReactNative/node_modules/react-native/ReactCommon/yoga'

    # Third party deps podspec link
    pod 'DoubleConversion', :podspec => './ReactNative/node_modules/react-native/third-party-podspecs/DoubleConversion.podspec'
    pod 'glog', :podspec => './ReactNative/node_modules/react-native/third-party-podspecs/GLog.podspec'
    pod 'Folly', :podspec => './ReactNative/node_modules/react-native/third-party-podspecs/Folly.podspec'


  target 'CWWeChatTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'Quick'
    pod 'Nimble'
  end

end


post_install do |installer|
    installer.pods_project.targets.each do |target|
        if target.name == 'Quick' || target.name == 'Nimble'
            print "Changing Quick swift version to 3.2\n"
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '3.2'
            end
        end
    end
end


