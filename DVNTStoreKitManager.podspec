Pod::Spec.new do |s|
    
    s.name             = 'DVNTStoreKitManager'
    s.version          = '1.0.4'
    s.summary          = 'An amazing StoreKit wrapper.'
    s.description      = 'A wrapper to use StokeKit easily.'
    s.homepage         = 'https://www.devinet.es'
    s.license          = { :type => 'Copyright (c) 2020 Devinet 2013, S.L.U.', :file => 'LICENSE' }
    s.author           = { 'Raúl Vidal Muiños' => 'contacto@devinet.es' }
    s.social_media_url = 'https://twitter.com/devinet_es'
        
    s.ios.deployment_target = "12.0"
    
    s.swift_versions   = ['3.0', '4.0', '4.1', '4.2', '5.0', '5.1', '5.2']
    s.source           = { :git => 'https://bitbucket.org/Devinet_Team/ios-library-dvntstorekitmanager.git', :tag => s.version.to_s }
    s.frameworks       = 'UIKit', 'StoreKit'
    s.source_files     = 'Sources/DVNTStoreKitManager/Classes/**/*'
    s.exclude_files    = 'Sources/DVNTStoreKitManager/**/*.plist'
    
    s.dependency 'DVNTAlertManager', '~>1.1.2'
    s.dependency 'SwiftyReceiptValidator', '~>6.1.0'
end
