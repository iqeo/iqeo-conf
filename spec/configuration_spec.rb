require 'spec_helper'
require 'iqeo/configuration'

include Iqeo

describe Configuration do

  it 'should report the correct version' do
    Configuration.version.should == Configuration::VERSION
  end

  context 'at creation' do

    it 'should not require a block' do
      Configuration.new.should be_a Configuration
    end

    it 'should accept a block with arity 0' do
      Configuration.new {  }.should be_a Configuration
    end

    it 'should instance eval block with arity 0' do
      conf_eval = nil
      conf_new = Configuration.new { conf_eval = self }
      conf_new.should be conf_eval
    end

    it 'should accept a block with arity 1' do
      Configuration.new { |arg| }.should be_a Configuration
    end

    it 'should yield self to block with arity 1' do
      conf_yielded = nil
      conf_new = Configuration.new { |conf| conf_yielded = conf }
      conf_new.should be conf_yielded
    end

  end

  context 'instance' do

    it 'sets and retrieves simple values' do
      conf = nil
      expect do
        conf = Configuration.new
        conf.alpha 1
        conf.bravo "two"
        conf.charlie 3.0
        conf.delta :four
      end.to_not raise_error
      conf.should_not be_nil
      conf.alpha.should   == 1     and conf.alpha.should be_a Fixnum
      conf.bravo.should   == "two" and conf.bravo.should be_a String
      conf.charlie.should == 3.0   and conf.charlie.should be_a Float
      conf.delta.should == :four   and conf.delta.should be_a Symbol
    end

    it 'sets and retrieves complex values' do
      conf = nil
      expect do
        conf = Configuration.new
        conf.alpha = [ :a, :b, :c ]
        conf.bravo = { :a => 1, :b => 2, :c => 3 }
      end.to_not raise_error
      conf.should_not be_nil
      conf.alpha.should == [ :a, :b, :c] and conf.alpha.should be_an Array
      conf.alpha.size.should == 3
      conf.alpha[0].should == :a
      conf.alpha[1].should == :b
      conf.alpha[2].should == :c
      conf.bravo.should == { :a => 1, :b => 2, :c => 3} and conf.bravo.should be_a Hash
      conf.bravo.size.should == 3
      conf.bravo[:a].should == 1
      conf.bravo[:b].should == 2
      conf.bravo[:c].should == 3
    end

    it 'returns nil when retrieving non-existent settings' do
      conf = Configuration.new
      conf.not_a_setting.should be_nil
    end

    it 'sets and retrieves multiple values as an array' do
      conf = nil
      expect do
        conf = Configuration.new
        conf.alpha :a, :b, :c
      end.to_not raise_error
    conf.should_not be_nil
    conf.alpha.should == [ :a, :b, :c ] and conf.alpha.should be_an Array
    end

  end

  context 'yield DSL' do

    it 'accepts settings without =' do
      conf = nil
      expect do
        conf = Configuration.new do |c|
          c.alpha :value
        end
      end.to_not raise_error
      conf.should_not be_nil
      conf.alpha.should == :value
    end

    it 'accepts settings with =' do
      conf = nil
      expect do
        conf = Configuration.new do |c|
          c.alpha = :value
        end
      end.to_not raise_error
      conf.should_not be_nil
      conf.alpha.should == :value
    end

    it 'can refer to an existing setting' do
      conf = nil
      expect do
        conf = Configuration.new do |c|
          c.alpha = :value
          c.bravo = c.alpha
          c.charlie c.bravo
        end
      end.to_not raise_error
      conf.should_not be_nil
      conf.alpha.should == :value
      conf.bravo.should == :value
      conf.charlie.should == :value
    end

    it 'returns value when creating/changing a setting' do
      conf = nil
      expect do
        conf = Configuration.new do |c|
          c.bravo = c.alpha = :value
        end
      end.to_not raise_error
      conf.alpha.should == :value
      conf.bravo.should == :value
    end

  end

  context 'eval DSL' do

    it 'accepts settings without =' do
      conf = nil
      expect do
        conf = Configuration.new do
          alpha :value
        end
      end.to_not raise_error
      conf.should_not be_nil
      conf.alpha.should == :value
    end

    it 'set local variables with =' do
      conf = alpha = nil
      expect do
        alpha = nil
        conf = Configuration.new do
          alpha = :value
          bravo alpha
        end
      end.to_not raise_error
      conf.should_not be_nil
      conf.alpha.should be_nil
      conf.bravo.should == :value
      alpha.should == :value        # local alpha set by matching variables
    end

    it 'can refer to an existing setting' do
      conf = nil
      expect do
        conf = Configuration.new do |c|
          c.alpha :value
          c.bravo c.alpha
          c.charlie c.bravo
        end
      end.to_not raise_error
      conf.should_not be_nil
      conf.alpha.should == :value
      conf.bravo.should == :value
      conf.charlie.should == :value
    end

    it 'returns value when creating/changing a setting' do
      conf = nil
      expect do
        conf = Configuration.new do
          bravo alpha :value
        end
      end.to_not raise_error
      conf.alpha.should == :value
      conf.bravo.should == :value
    end

  end

end