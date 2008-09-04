require File.dirname(__FILE__) + '/../test_helper'
require 'enterprise_registration_controller'

# Re-raise errors caught by the controller.
class EnterpriseRegistrationController; def rescue_action(e) raise e end; end

class EnterpriseRegistrationControllerTest < Test::Unit::TestCase

#  all_fixtures:users
all_fixtures
  def setup
    @controller = EnterpriseRegistrationController.new
    @request    = ActionController::TestRequest.new
    @request.stubs(:ssl?).returns(true)
    @response   = ActionController::TestResponse.new
    login_as 'ze'
  end

  def test_local_files_reference
    assert_local_files_reference
  end
  
  def test_valid_xhtml
    assert_valid_xhtml
  end
  
  should 'go to the first step on index' do
    get :index
    assert_response :success
    assert_template 'basic_information'
  end

  should 'prompt for basic information' do
    get :index
    %w[ name identifier address contact_phone contact_person
        acronym foundation_year legal_form economic_activity ].each do |item|
      assert_tag :tag => 'input', :attributes => { :name => "create_enterprise[#{item}]" }
    end
    assert_tag :tag => 'textarea', :attributes => { :name => "create_enterprise[management_information]"}
    assert_tag :tag => 'select', :attributes => { :name => "create_enterprise[region_id]"}
  end

  should 'get back to entering basic information if data is invalid' do
    post :index, :create_enterprise => {}
    assert_response :success
    assert_template 'basic_information'
  end

  should 'prompt for selecting validator' do
    data = { 'name' => 'My new enterprise', 'identifier' => 'mynew' }

    create_enterprise = CreateEnterprise.new
    CreateEnterprise.expects(:new).with(data).returns(create_enterprise)

    validator1 = mock()
    validator1.expects(:id).returns(1)
    validator1.expects(:name).returns("validator1")
    validator1.expects(:validation_methodology).returns("methodology1")
    validator1.expects(:validation_restrictions).returns("restrictions1")

    validator2 = mock()
    validator2.expects(:id).returns(2)
    validator2.expects(:name).returns("validator2")
    validator2.expects(:validation_methodology).returns("methodology2")
    validator2.expects(:validation_restrictions).returns("restrictions2")


    region = mock()
    region.expects(:validators).returns([validator1, validator2]).at_least_once
    create_enterprise.expects(:region).returns(region)

    # all data but validator selected
    create_enterprise.expects(:valid_before_selecting_target?).returns(true)
    create_enterprise.expects(:valid?).returns(false) 

    post :index, :create_enterprise => data
    assert_template 'select_validator'
  end

  should 'provide confirmation at the end of the process' do
    data = { 'name' => 'My new enterprise', 'identifier' => 'mynew' }

    create_enterprise = CreateEnterprise.new
    CreateEnterprise.expects(:new).with(data).returns(create_enterprise)

    # all including validator selected
    validator = mock()
    validator.stubs(:name).returns("lalala")
    create_enterprise.expects(:valid_before_selecting_target?).returns(true)
    create_enterprise.expects(:valid?).returns(true) # validator already selected
    create_enterprise.expects(:save!)
    create_enterprise.expects(:target).returns(validator)

    post :index, :create_enterprise => data
    assert_template 'confirmation'
  end

  should 'filter html from name' do
    post :index, :create_enterprise => { 'name' => '<b>name</b>', 'identifier' => 'mynew' }
    assert_sanitized assigns(:create_enterprise).name
  end

  should 'filter html from address' do
    post :index, :create_enterprise => { 'name' => 'name', 'identifier' => 'mynew', :address => '<b>address</b>' }
    assert_sanitized assigns(:create_enterprise).address
  end

  should 'filter html from contact_phone' do
    post :index, :create_enterprise => { 'name' => 'name', 'identifier' => 'mynew', :contact_phone => '<b>contact_phone</b>' }
    assert_sanitized assigns(:create_enterprise).contact_phone
  end

  should 'filter html from contact_person' do
    post :index, :create_enterprise => { 'name' => 'name', 'identifier' => 'mynew', :contact_person => '<b>contact_person</b>' }
    assert_sanitized assigns(:create_enterprise).contact_person
  end

  should 'filter html from acronym' do
    post :index, :create_enterprise => { 'name' => 'name', 'identifier' => 'mynew', :acronym => '<b>acronym</b>' }
    assert_sanitized assigns(:create_enterprise).acronym
  end

  should 'filter html from legal_form' do
    post :index, :create_enterprise => { 'name' => 'name', 'identifier' => 'mynew', :legal_form => '<b>legal_form</b>' }
    assert_sanitized assigns(:create_enterprise).legal_form
  end

  should 'filter html from economic_activity' do
    post :index, :create_enterprise => { 'name' => 'name', 'identifier' => 'mynew', :economic_activity => '<b>economic_activity</b>' }
    assert_sanitized assigns(:create_enterprise).economic_activity
  end
  
  should 'filter html from management_information' do
    post :index, :create_enterprise => { 'name' => 'name', 'identifier' => 'mynew', :management_information => '<b>management_information</b>' }
    assert_sanitized assigns(:create_enterprise).management_information
  end

  should 'load only regions with validator organizations' do
    env = Environment.default

    reg1 = env.regions.create!(:name => 'Region with validator')
    reg1.validators.create!(:name => 'Validator one', :identifier => 'validator-one')
    reg2 = env.regions.create!(:name => 'Region without validator')

    get :index

    assert_includes assigns(:regions), [reg1.name, reg1.id]
    assert_tag :tag => 'option', :content => "Region with validator"
    assert_no_tag :tag => 'option', :content => "Region without validator"
  end

end
