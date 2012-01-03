require 'spec_helper'
require 'helpers/system_test_data'
include OrchestrationHelper

describe Hypervisor do
  before do
    disable_org_orchestration

    @organization = Organization.create!(:name => 'test_org', :cp_key => 'test_org')
    @environment = KTEnvironment.create!(:name => 'test', :prior => @organization.locker.id, :organization => @organization)

    Organization.stub!(:first).and_return(@organization)
  end

  describe "creating" do
    let(:virt_who_params) { {"env"=>@environment.name, "host2"=>["GUEST3", "GUEST4"], "owner"=>@organization.name} }
    let(:new_hypervisor_attrs) { SystemTestData.new_hypervisor }
    let(:hypervisor_record) { Hypervisor.find_by_uuid(new_hypervisor_attrs[:uuid]) }

    before do
      Candlepin::Consumer.stub(:register_hypervisors).with(virt_who_params).and_return({"created" => [new_hypervisor_attrs]}.with_indifferent_access)
    end

    it "should call cp" do
      Candlepin::Consumer.should_receive(:register_hypervisors).with(virt_who_params)
      System.register_hypervisors(@environment, virt_who_params)
    end

    it "should create hypervisor record" do
      System.register_hypervisors(@environment, virt_who_params)
      hypervisor_record.should be
    end

    it "should not create candlepin consumer" do
      Candlepin::Consumer.should_not_receive(:create)
      System.register_hypervisors(@environment, virt_who_params)
    end

    it "shoudl have lazy_attributes set" do
      response, hypervisors = System.register_hypervisors(@environment, virt_who_params)
      hypervisors.first.lazy_attributes.should_not == nil
    end
  end


end

