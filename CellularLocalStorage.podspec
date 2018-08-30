#
# Be sure to run `pod lib lint cellularlocalstorage.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |spec|
 spec.name             = 'CellularLocalStorage'
 spec.swift_version    = '4.2'
 spec.module_name      = 'LocalStorage'
 spec.version          = '4.2.0'
 spec.summary          = 'Persist and access data safely'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

 spec.description      = 'Module for saving data locally'

 spec.homepage         = 'www.cellular.de'
 spec.license          = { :type => 'MIT', :file => 'LICENSE' }
 spec.author           = { 'Cellular GmbH' => 'office@cellular.de' }
 spec.source           = { :git => 'https://github.com/cellular/localstorage-swift.git', :tag =>spec.version.to_s }

  # Deployment Targets
 spec.ios.deployment_target = '9.0'
 spec.tvos.deployment_target = '9.0'
 spec.watchos.deployment_target = '2.0'

    # Core Subspec

    spec.subspec 'Core' do |sub|
        sub.dependency 'CELLULAR/Result', '~> 4.1.0'
        sub.dependency 'CELLULAR/Locking', '~> 4.1.0'
        sub.source_files = 'Source/Core/**/*.swift'
    end

    # Encoder Subspecs

    spec.subspec 'Wrap' do |sub|
        sub.dependency 'Wrap', '~> 3.0.0'
        sub.dependency 'CellularLocalStorage/Core'
        sub.source_files = 'Source/Wrap/WrapEncoder.swift'
    end

    # Decoder Subspecs

    spec.subspec 'Unbox' do |sub|
        sub.dependency 'Unbox', '~> 2.5.0'
        sub.dependency 'CellularLocalStorage/Core'
        sub.source_files = 'Source/Unbox/UnboxDecoder.swift'
    end

    # Default Subspecs

    spec.default_subspecs = 'Core'
end
