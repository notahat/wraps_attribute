$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../lib')
require "#{File.dirname(__FILE__)}/active_record_base_without_table"
require 'wraps_attribute'

class Phone < String
  def initialize(value)
    super(value || '')
  end
  
  def normalize
    gsub(' ', '')
  end
  
  def valid?
    self =~ /\A[0-9 ]+\Z/
  end
  
  def valid_mobile?
    normalize =~ /\A04[0-9]{8}\Z/
  end
end

class MyModel < ActiveRecord::BaseWithoutTable
  column :phone, :string
  column :mobile, :string
  column :home_phone, :string
  
  wraps_attribute :phone, Phone
  wraps_attribute :mobile, Phone, :validate => :valid_mobile?, :message => "must be a valid mobile number"
  wraps_attribute :home_phone, Phone, :allow_blank => true
end

describe "An ActiveRecord model using wraps_attribute" do
  
  before do
    @object = MyModel.new(:phone => '12 3 45', :mobile => '0414 98 33 00', :home_phone => '')
  end
  
  it "should return an object of the wrapped class when asked for the attribute" do
    @object.phone.class.should == Phone
  end
  
  it "should return the correct value when asked for the attribute" do
    @object.phone.should == '12 3 45'
  end
  
  it "should normalize the attribute before saving" do
    @object.save
    @object.phone.should == '12345'
  end
  
  it "should return a mutable attribate" do
    @object.phone << '6789'
    @object.phone.should == '12 3 456789'
    @object.phone.class.should == Phone
  end
  
  it "should validate the attribute using the valid? method by default" do
    @object.should be_valid
    @object[:phone] = "abcde"
    @object.should_not be_valid
    @object.errors["phone"].should == "must be valid"
  end
  
  it "should vaildate the attribute using the provided method" do
    @object.should be_valid
    @object[:mobile] = "12345"
    @object.should_not be_valid
    @object.errors["mobile"].should == "must be a valid mobile number"
  end
  
end
