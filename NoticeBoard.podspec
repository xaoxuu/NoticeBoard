Pod::Spec.new do |s|
  s.name = 'NoticeBoard'
  s.version = "1.1.3"
  s.license = 'MIT'
  s.summary = '一个简单易用的应用内消息通知框架。'
  s.homepage = "http://xaoxuu.com"
  s.authors = { 'xaoxuu' => 'xaoxuu@gmail.com' }
  s.source = { :git => "https://github.com/xaoxuu/NoticeBoard.git", :tag => "#{s.version}", :submodules => false}
  s.ios.deployment_target = '8.0'

  s.source_files = 'NoticeBoard/*.swift'

  s.requires_arc = true
end
