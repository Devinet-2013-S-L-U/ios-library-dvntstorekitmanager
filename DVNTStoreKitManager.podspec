Pod::Spec.new do |s|
    
    s.name             = 'DVNTStoreKitManager'
    s.version          = '1.2.7'
    s.summary          = 'An amazing StoreKit wrapper.'
    s.description      = 'A wrapper to use StokeKit easily.'
    s.homepage         = 'https://www.devinet.es'
    s.license          = { :type => 'Copyright (c) 2025 Devinet 2013, S.L.U.', :file => 'LICENSE' }
    s.author           = { 'Raúl Vidal Muiños' => 'contacto@devinet.es' }
    s.social_media_url = 'https://twitter.com/devinet_es'
    s.platform         = :ios, '16.2'
    s.ios.deployment_target = '13.0'
    s.swift_versions   = ['3.0', '4.0', '4.1', '4.2', '5.0', '5.1', '5.2', '5.3', '5.4', '5.5', '5.6', '5.7', '5.8', '5.9', '5.10']
    s.source           = { :git => 'https://bitbucket.org/Devinet_Team/ios-library-dvntstorekitmanager.git', :tag => s.version.to_s }
    s.frameworks       = 'UIKit', 'StoreKit'
    s.source_files     = 'Sources/DVNTStoreKitManager/Classes/**/*'
    s.exclude_files    = 'Sources/DVNTStoreKitManager/**/*.plist'
    
    s.dependency 'DVNTAlertManager', '~>1.3.4'
    s.dependency 'SwiftyReceiptValidator', '~>7.0.0'
end
