source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!

def frameworks_pods
    pod 'CELLULAR/Locking', '~> 5.0'
    pod 'SwiftLint', '~> 0.31.0'
    pod 'Unbox', '~> 4.0'
    pod 'Wrap', '~> 3.0'
end

target 'CellularLocalStorage iOS' do
  platform :ios, '10.3'
  frameworks_pods

  target 'CellularLocalStorageTests iOS' do
    inherit! :search_paths
    frameworks_pods
  end
end

target 'CellularLocalStorage tvOS' do
    platform :tvos, '10.2'
    frameworks_pods
    
    target 'CellularLocalStorageTests tvOS' do
      inherit! :search_paths
      frameworks_pods
    end
end

target 'CellularLocalStorage watchOS' do
platform :watchos, '2.2'
    frameworks_pods
end
