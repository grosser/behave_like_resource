root = File.join(File.dirname(__FILE__),'lib')
%w[behave_like_resource helpers].each do |file|
  require File.join([root,file])
end
