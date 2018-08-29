source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!


def frameworks_pods
    pod 'CELLULAR/Locking', '~> 4.1.0'
    pod 'CELLULAR/Result', '~> 4.1.0'
    pod 'SwiftLint'
    pod 'Unbox'
    pod 'Wrap'
end

target 'CellularLocalStorage iOS' do
    platform :ios, '9.0'
  frameworks_pods

  target 'CellularLocalStorageTests' do
    inherit! :search_paths  
  end
end

target 'CellularLocalStorage tvOS' do
    platform :tvos, '9.0'
    frameworks_pods
end

target 'CellularLocalStorage watchOS' do
platform :watchos, '2.0'
    frameworks_pods
end
