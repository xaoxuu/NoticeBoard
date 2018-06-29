Pod::Spec.new do |s|
  s.name = 'NoticeBoard'
  s.version = '1.0.0'
  s.license = 'MIT'
  s.summary = '状态栏消息、进度条、横幅消息'
  s.homepage = "http://xaoxuu.com"
  s.authors = { 'Robert Payne' => 'robertpayne@me.com' }
  s.source = { :git => "https://github.com/xaoxuu/NoticeBoard.git", :tag => "#{s.version}", :submodules => false}
  s.ios.deployment_target = '8.0'

  s.source_files = 'NoticeBoard/*.swift'

  s.requires_arc = true
end
