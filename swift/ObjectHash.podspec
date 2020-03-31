Pod::Spec.new do |s|
    s.name                  = 'ObjectHash'
    s.version               = '0.0.1'
    s.summary               = 'A way to cryptographically hash objects (in the JSON-ish sense) that works cross-language. And, therefore, cross-encoding.'
    s.homepage              = 'http://www.vchain.tech'
    s.author                = { 'Denis Zenin' => 'denis.zenin@vchain.tech' }
    s.license               = { :type => 'MIT'}
    s.platform              = :ios
    s.swift_version         = '4.1'
    s.ios.deployment_target = '11.0'

    s.source                = { :git => "https://github.com/vchain-dev/objecthash.git", :tag => '0.0.1' }
    s.source_files          = 'swift/ObjectHash/*.swift'
end
