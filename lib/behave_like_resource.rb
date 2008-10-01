def behave_like_resource
  describe 'behave like resource' do
    behave_like_resource_show
    behave_like_resource_index
    behave_like_resource_new
    behave_like_resource_create
    behave_like_resource_edit
    behave_like_resource_update
    behave_like_resource_destroy
  end
end

def behave_like_resource_index
  describe 'behave like resource show' do
    include BLAR::Helpers
    before(:each) { sanitize_input }
  
    it "renders index" do
      ret = [@item,@item,@item]
      #find is called with :all, options(two) do not matter...
      @item.class.expects(:find).with{|one,two| one.to_sym == :all rescue false}.returns ret
      
      get :index
      
      response.should render_template('index')
      assigns[@item_name.pluralize].size.should == ret.size
    end
  end
end

def behave_like_resource_show
  include BLAR::Helpers
  before(:each) { sanitize_input }

  it "renders show" do
    expects_find
    get :show, :id => @item.to_param
    
    response.should render_template('show')
    assigns[@item_name].should equal(@item)
  end
end

def behave_like_resource_new
  include BLAR::Helpers
  before(:each) { sanitize_input }
  
  it "renders new" do
    @item.expects(:save).never
    @item.class.expects(:new).returns(@item)
    
    get :new
    
    response.should render_template('new')
    assigns[@item_name].should equal(@item)
  end
end

def behave_like_resource_create
  include BLAR::Helpers
  before(:each) { sanitize_input }
  
  def do_post success
    param = {}
    @item.stubs(:new_record?).returns(true)
    mock_create(@item,success,param)
    post :create, @item_name => param
  end
  
  it "create succeeds when valid" do
    do_post true
    
    response.should redirect_to(@resource_redirects[:create] || singular_path)
  end
  
  it "create fails when invalid" do
    do_post false
    
    response.should render_template('new')
    assigns(@item_name).should == @item
  end
end

def behave_like_resource_edit
  include BLAR::Helpers
  before(:each) { sanitize_input }

  it "renders edit" do
    expects_find
    
    get :edit , :id => @item.to_param
    
    response.should render_template('edit')
    assigns[@item_name].should equal(@item)
  end
end

def behave_like_resource_update
  include BLAR::Helpers
  before(:each) { sanitize_input }
  
  def do_put success
    param = {}
    expects_find
    @item.stubs(:new_record?).returns(false)#for generic processing
    
    #direct update OR set+save
    @item.stubs(:update_attributes).with(param).returns(success)
    @item.stubs(:attributes=).with(param)
    @item.stubs(:save).returns(success)
    
    put :update, :id => @item.to_param, @item_name.to_sym => param
  end

  it "update succeeds when valid" do
    do_put true
    
    response.should redirect_to(@resource_redirects[:update]||singular_path)
  end

  it "update fails when invalid" do
    do_put false
    
    response.should render_template('edit')
    assigns[@item_name].should equal(@item)
  end
end

def behave_like_resource_destroy
  include BLAR::Helpers
  before(:each) { sanitize_input }

  it "renders destroy" do
    expects_find
    @item.expects(:destroy)
    request.env["HTTP_REFERER"] = "/addresses/12"
    
    delete :destroy, :id => @item.to_param
    
    response.should redirect_to(@resource_redirects[:destroy]||"/addresses/12")
  end
end