#only used by Behave Like A Resource
#messy, but hard to do another way, without writing into global namespace
module BLAR
  module Helpers
    def mock_create(item,success,param=nil)
      if param
        item.class.expects(:new).with(param).returns item
      else
        item.class.expects(:new).returns item
      end
      item.expects(:save).returns success
    end
    
    def mock_update(item,success)
      expects_find(item)
      item.expects(:save).returns success
    end
    
    def expects_find(item=@item)
      item.class.expects(:find).with(item.to_param).returns(item)
    end
  
    def singular_path
      generic_path([@path_prefix,@item])
    end
    
    def plural_path
      @path_prefix+"_" + @item.class.to_s.downcase.pluralize + "_path"
    end
   
    
    #use with user OR [:admin,user]
    def generic_path(item)
      item = [item] unless item.kind_of? Array
      item.reject! &:blank?
      items = item + ['path']
      items.map! do |part| 
        raise "NO IDS!" if part.kind_of? Fixnum
        part = part.class if part.kind_of? ActiveRecord::Base
        part.to_s.underscore
      end
      send(items*'_',item[-1])
    end
    
    def sanitize_input
      raise "needs mocked @item!" unless @item
      @resource_redirects ||= {}
      @path_prefix ||= ""
      @item_name ||= @item.class.to_s.underscore
    end
  end
end