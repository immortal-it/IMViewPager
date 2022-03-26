Pod::Spec.new do |s|
  s.name = 'IMViewPager'
  s.version = '0.0.1'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.homepage = 'https://github.com/immortal-it'
  s.authors = { 'immortal' => 'immortal.me@gmail.com' }
  s.summary = 'IMViewPager in Swift.'
  
  s.source = { :git => 'https://github.com/immortal-it/IMViewPager.git', :tag => s.version }
  s.source_files = 'IMViewPager/**/*.{swift}'

  s.swift_version = ['5.1', '5.2', '5.3']
  s.ios.deployment_target = '10.0'
  
 end
