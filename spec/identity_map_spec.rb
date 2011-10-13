require File.join(File.dirname(__FILE__), 'spec_helper')


share_examples_for "containing the entity" do
  after(:each) { finish_tx }

  it "exist in the identity map" do
    Neo4j::IdentityMap.instance.load(subject).should_not be_nil
  end

  it "has the same object id" do
    Neo4j::IdentityMap.instance.load(subject).object_id.should == subject.object_id
  end

  context "when loaded" do
    before(:each) { @loaded = Neo4j::Node.load(subject.neo_id) }

    it "exist in the identity map" do
      Neo4j::IdentityMap.instance.load(subject).should_not be_nil
    end

    it "has the same object id" do
      Neo4j::IdentityMap.instance.load(subject).object_id.should == subject.object_id
    end

    it "the loaded object is the same" do
      @loaded.object_id.should == subject.object_id
    end
  end
end

share_examples_for "not containing the entity" do
  after(:each) { finish_tx }

  it "does not exist in the identity map" do
    Neo4j::IdentityMap.instance.load(subject).should be_nil
  end

  context "when loaded" do
    before(:each) { @loaded = Neo4j::Node.load(subject.neo_id) }

    it "exist in the identity map" do
      Neo4j::IdentityMap.instance.load(subject).should_not be_nil
    end

    it "has the same object id" do
      Neo4j::IdentityMap.instance.load(subject).object_id.should == @loaded.object_id
    end

    it "when loading again it should return the same instance" do
      Neo4j::Node.load(subject.neo_id).object_id.should == @loaded.object_id
    end
  end
end


describe "Identity Map" do

  class ClassIncludedNodeMixin
    include Neo4j::NodeMixin
    property :name
  end

  context "Created a Neo4j::NodeMixin class but not committed it" do
    before(:each) { new_tx; @instance = ClassIncludedNodeMixin.new }
    subject { @instance }
    it_should_behave_like "containing the entity"
  end

  context "Created and committed a Neo4j::NodeMixin class" do
    before(:each) { new_tx; @instance = ClassIncludedNodeMixin.new; finish_tx }
    subject { @instance }
    it_should_behave_like "not containing the entity"
  end

  class RailsModelIdentiyTest < Neo4j::Rails::Model
    property :name
    index :name
  end

  context "Created a Rails model but not committed it" do
    before(:each) { new_tx; @instance = RailsModelIdentiyTest.create }
    subject { @instance }
    it_should_behave_like "containing the entity"
  end

  context "Created and committed a Rails model" do
    before(:each) { @instance = RailsModelIdentiyTest.create }
    subject { @instance }
    it_should_behave_like "not containing the entity"
  end

  context "A found none committed rails model" do
    before(:each) do
      new_tx
      Neo4j.ref_node.outgoing(:foobar) << RailsModelIdentiyTest.create(:name => '12345')
      @instance = Neo4j.ref_node.node(:outgoing, :foobar)
    end
    after(:each) { @instance.destroy; finish_tx }

    subject { @instance }
    it_should_behave_like "containing the entity"
  end

  context "A found Rails and committed model" do
    before(:each) do
      RailsModelIdentiyTest.create(:name => '12345') # commits
      @instance = RailsModelIdentiyTest.find_by_name('12345')
    end
    after(:each) { @instance.destroy }

    subject { @instance }
    it_should_behave_like "containing the entity"
  end

  context "after commit" do
    it "should clean the identity map" do
      imap = Neo4j::IdentityMap.instance
      imap.store(Neo4j.ref_node, "thing")
      imap.identity_map.size.should > 0
      new_tx
      Neo4j::Node.new
      #Neo4j.ref_node[:foo] = 'bar'
      finish_tx
      imap.identity_map.size.should == 0
    end
  end
end
