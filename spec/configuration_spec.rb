require 'spec_helper'
require 'iqeo/configuration'
require 'stringio'

include Iqeo

describe Configuration do

  it 'reports the correct version' do
    Configuration.version.should == Configuration::VERSION
  end

  context 'creation' do

    it 'does not require a block' do
      Configuration.new.should be_a Configuration
    end

    it 'accepts a block with arity 0' do
      Configuration.new {  }.should be_a Configuration
    end

    it 'instance_eval\'s block with arity 0' do
      conf_eval = nil
      conf_new = Configuration.new { conf_eval = self }
      conf_new.should be conf_eval
    end

    it 'accepts a block with arity 1' do
      Configuration.new { |arg| }.should be_a Configuration
    end

    it 'yields self to block with arity 1' do
      conf_yielded = nil
      conf_new = Configuration.new { |conf| conf_yielded = conf }
      conf_new.should be conf_yielded
    end

  end # creation

  context 'settings retrieval' do

    it 'returns nil for non-existent settings' do
      conf = Configuration.new
      conf.not_a_setting.should be_nil
    end

  end # settings retrieval

  context 'single value setting' do

    it 'accepts simple values' do
      conf = nil
      expect do
        conf = Configuration.new
        conf.alpha 1
        conf.bravo 'two'
        conf.charlie 3.0
        conf.delta :four
      end.to_not raise_error
      conf.should_not be_nil
      conf.alpha.should   == 1     and conf.alpha.should be_a Fixnum
      conf.bravo.should   == 'two' and conf.bravo.should be_a String
      conf.charlie.should == 3.0   and conf.charlie.should be_a Float
      conf.delta.should == :four   and conf.delta.should be_a Symbol
    end

    it 'accepts complex values' do
      conf = Configuration.new
      conf.alpha = [ :a, :b, :c ]
      conf.bravo = { :a => 1, :b => 2, :c => 3 }
      conf.alpha.should == [ :a, :b, :c] and conf.alpha.should be_an Array
      conf.alpha.size.should == 3
      conf.alpha[0].should == :a
      conf.alpha[1].should == :b
      conf.alpha[2].should == :c
      conf.bravo.should == { 'a' => 1, 'b' => 2, 'c' => 3} and conf.bravo.should be_a Hash
      conf.bravo.size.should == 3
      conf.bravo[:a].should == 1
      conf.bravo[:b].should == 2
      conf.bravo[:c].should == 3
    end

  end # single value setting

  context 'multiple value setting' do

    it 'accepts hash without brackets' do
      conf = Configuration.new
      conf.alpha :a => 1, :b => 2, :c => 3
      conf.alpha.should == { 'a' => 1, 'b' => 2, 'c' => 3} and conf.alpha.should be_a Hash
    end

    it 'treats multiple values as an array' do
      conf = nil
      expect do
        conf = Configuration.new
        conf.alpha :a, :b, :c
      end.to_not raise_error
      conf.should_not be_nil
      conf.alpha.should == [ :a, :b, :c ] and conf.alpha.should be_an Array
    end

    it 'treats hash without brackets after multiple values as last element of array' do
      conf = Configuration.new
      conf.alpha 1, 2, 3, :a => 4, :b => 5, :c => 6
      conf.alpha.should == [ 1, 2, 3, { 'a' => 4, 'b' => 5, 'c' => 6} ] and conf.alpha.should be_a Array
    end

  end # multiple value setting

  context 'hash operators [] & []= access' do

    it 'accepts symbol keys' do
      conf = nil
      expect do
        conf = Configuration.new
        conf[:alpha] = 1
      end.to_not raise_error
      conf[:alpha].should == 1
    end

    it 'accepts non-symbol (string) keys' do
      conf = nil
      expect do
        conf = Configuration.new
        conf['alpha'] = 1
      end.to_not raise_error
      conf.should_not be_nil
      conf['alpha'].should == 1
    end

  end # hash operators [] & []= access

  context 'nested configuration' do

    it 'is supported' do
      conf = nil
      expect do
        conf = Configuration.new
        conf.alpha Configuration.new
        conf.alpha.bravo Configuration.new
        conf.alpha.bravo.charlie true
      end.to_not raise_error
      conf.should_not be_nil
      conf.alpha.should be_a Configuration
      conf.alpha.bravo.should be_a Configuration
      conf.alpha.bravo.charlie.should be_true
    end

    it 'knows its parent when referenced directly' do
      conf = nil
      expect do
        conf = Configuration.new
        conf.alpha Configuration.new
        conf.alpha.bravo Configuration.new
        conf.alpha.bravo.charlie true
      end.to_not raise_error
      conf.should_not be_nil
      conf.alpha.bravo._parent.should be conf.alpha
      conf.alpha._parent.should be conf
      conf._parent.should be_nil
    end

    it 'knows its parent when contained in an enumerable' do
      conf = nil
      expect do
        conf = Configuration.new
        conf.alpha Configuration.new, Configuration.new, Configuration.new
      end.to_not raise_error
      conf.should_not be_nil
      conf.alpha.each { |child| child._parent.should be conf }
      conf._parent.should be_nil
    end

    it 'inherits settings' do
      conf = nil
      expect do
        conf = Configuration.new
        conf.alpha Configuration.new
        conf.alpha.bravo Configuration.new
        conf.top = true
        conf.alpha.middle = true
        conf.alpha.bravo.bottom = true
      end.to_not raise_error
      conf.should_not be_nil
      conf.top.should be_true
      conf.alpha.top.should be_true
      conf.alpha.middle.should be_true
      conf.alpha.bravo.top.should be_true
      conf.alpha.bravo.middle.should be_true
      conf.alpha.bravo.bottom.should be_true
    end

    it 'can override inherited settings' do
      conf = nil
      expect do
        conf = Configuration.new
        conf.alpha Configuration.new
        conf.alpha.bravo Configuration.new
        conf.level = 1
        conf.alpha.level = 2
        conf.alpha.bravo.level = 3
      end.to_not raise_error
      conf.should_not be_nil
      conf.level.should == 1
      conf.alpha.level.should == 2
      conf.alpha.bravo.level.should == 3
    end

  end # nested configuration

  context 'mode of usage' do

    context 'explicit' do

      it 'accepts settings without =' do
        conf = nil
        expect do
          conf = Configuration.new
          conf.alpha :value
        end.to_not raise_error
        conf.should_not be_nil
        conf.alpha.should == :value
      end

      it 'accepts settings with =' do
        conf = nil
        expect do
          conf = Configuration.new
          conf.alpha = :value
        end.to_not raise_error
        conf.should_not be_nil
        conf.alpha.should == :value
      end

      it 'can refer to an existing setting' do
        conf = nil
        expect do
          conf = Configuration.new
          conf.alpha = :value
          conf.bravo = conf.alpha
          conf.charlie conf.bravo
        end.to_not raise_error
        conf.should_not be_nil
        conf.alpha.should == :value
        conf.bravo.should == :value
        conf.charlie.should == :value
      end

      it 'returns value when creating/changing a setting' do
        conf = nil
        expect do
          conf = Configuration.new
          conf.bravo = conf.alpha = :value
        end.to_not raise_error
        conf.should_not be_nil
        conf.alpha.should == :value
        conf.bravo.should == :value
      end

      it 'supports nested configuration via Configuration.new' do
        conf = nil
        expect do
          conf = Configuration.new
          conf.alpha true
          conf.bravo Configuration.new
          conf.bravo.charlie true
          conf.bravo.delta Configuration.new
          conf.bravo.delta.echo true
        end.to_not raise_error
        conf.should_not be_nil
        conf.alpha.should be_true
        conf.bravo.should be_a Configuration
        conf.bravo.alpha should be_true
        conf.bravo.charlie should be_true
        conf.bravo.delta.should be_a Configuration
        conf.bravo.delta.alpha.should be_true
        conf.bravo.delta.charlie.should be_true
        conf.bravo.delta.echo.should be_true
      end

    end # explicit

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
        conf.should_not be_nil
        conf.alpha.should == :value
        conf.bravo.should == :value
      end

      it 'supports nested configuration via do..end' do
        conf = nil
        expect do
          conf = Configuration.new do |c1|
            c1.alpha true
            c1.bravo do |c2|
              c2.charlie true
              c2.delta do |c3|
                c3.echo true
              end
            end
          end
        end.to_not raise_error
        conf.should_not be_nil
        conf.alpha.should be_true
        conf.bravo.should be_a Configuration
        conf.bravo.alpha should be_true
        conf.bravo.charlie should be_true
        conf.bravo.delta.should be_a Configuration
        conf.bravo.delta.alpha.should be_true
        conf.bravo.delta.charlie.should be_true
        conf.bravo.delta.echo.should be_true
      end

      it 'supports nested configuration via {..}' do
        conf = nil
        expect do
          conf = Configuration.new { |c1| c1.alpha true ; c1.bravo { |c2| c2.charlie true ; c2.delta { |c3| c3.echo true } } }
        end.to_not raise_error
        conf.should_not be_nil
        conf.alpha.should be_true
        conf.bravo.should be_a Configuration
        conf.bravo.alpha should be_true
        conf.bravo.charlie should be_true
        conf.bravo.delta.should be_a Configuration
        conf.bravo.delta.alpha.should be_true
        conf.bravo.delta.charlie.should be_true
        conf.bravo.delta.echo.should be_true
      end

    end # yield DSL

    context 'instance_eval DSL' do

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

      it 'sets local variables with =' do
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
          conf = Configuration.new do
            alpha :value
            bravo alpha
            charlie bravo
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
        conf.should_not be_nil
        conf.alpha.should == :value
        conf.bravo.should == :value
      end

      it 'supports nested configuration via do..end' do
        conf = nil
        expect do
          conf = Configuration.new do
            alpha true
            bravo do
              charlie true
              delta do
                echo true
              end
            end
          end
        end.to_not raise_error
        conf.should_not be_nil
        conf.alpha.should be_true
        conf.bravo.should be_a Configuration
        conf.bravo.alpha should be_true
        conf.bravo.charlie should be_true
        conf.bravo.delta.should be_a Configuration
        conf.bravo.delta.alpha.should be_true
        conf.bravo.delta.charlie.should be_true
        conf.bravo.delta.echo.should be_true
      end

      it 'supports nested configuration via {..}' do
        conf = nil
        expect do
          conf = Configuration.new { |c1| c1.alpha true ; c1.bravo { |c2| c2.charlie true ; c2.delta { |c3| c3.echo true } } }
        end.to_not raise_error
        conf.should_not be_nil
        conf.alpha.should be_true
        conf.bravo.should be_a Configuration
        conf.bravo.alpha should be_true
        conf.bravo.charlie should be_true
        conf.bravo.delta.should be_a Configuration
        conf.bravo.delta.alpha.should be_true
        conf.bravo.delta.charlie.should be_true
        conf.bravo.delta.echo.should be_true
      end

    end # instance_eval DSL

  end # mode of usage

  context 'loads' do

    it 'simple eval DSL from string' do
      string = "alpha 1
                bravo 'two'
                charlie 3.0
                delta :four"
      conf = nil
      expect do
        conf = Configuration.read string
      end.to_not raise_error
      conf.should_not be_nil
      conf.alpha.should   == 1     and conf.alpha.should be_a Fixnum
      conf.bravo.should   == "two" and conf.bravo.should be_a String
      conf.charlie.should == 3.0   and conf.charlie.should be_a Float
      conf.delta.should   == :four and conf.delta.should be_a Symbol
    end

    it 'simple eval DSL from file (by StringIO fake)' do
      io = StringIO.new  "alpha 1
                          bravo 'two'
                          charlie 3.0
                          delta :four"
      conf = nil
      expect do
        conf = Configuration.file io
      end.to_not raise_error
      conf.should_not be_nil
      conf.alpha.should   == 1     and conf.alpha.should be_a Fixnum
      conf.bravo.should   == "two" and conf.bravo.should be_a String
      conf.charlie.should == 3.0   and conf.charlie.should be_a Float
      conf.delta.should   == :four and conf.delta.should be_a Symbol
    end

    it 'simple eval DSL from file (by mock and expected methods)' do
      file = mock
      file.should_receive( :respond_to? ).with( :read ).and_return true
      file.should_receive( :read ).and_return  "alpha 1
                                                bravo 'two'
                                                charlie 3.0
                                                delta :four"
      conf = nil
      expect do
        conf = Configuration.file file
      end.to_not raise_error
      conf.should_not be_nil
      conf.alpha.should   == 1     and conf.alpha.should be_a Fixnum
      conf.bravo.should   == "two" and conf.bravo.should be_a String
      conf.charlie.should == 3.0   and conf.charlie.should be_a Float
      conf.delta.should   == :four and conf.delta.should be_a Symbol
    end

    it 'simple eval DSL from filename (by expected methods)' do
      File.should_receive( :read ).with( "filename" ).and_return "alpha 1
                                                                  bravo 'two'
                                                                  charlie 3.0
                                                                  delta :four"
      conf = nil
      expect do
        conf = Configuration.file "filename"
      end.to_not raise_error
      conf.should_not be_nil
      conf.alpha.should   == 1     and conf.alpha.should be_a Fixnum
      conf.bravo.should   == "two" and conf.bravo.should be_a String
      conf.charlie.should == 3.0   and conf.charlie.should be_a Float
      conf.delta.should   == :four and conf.delta.should be_a Symbol
    end

    it 'complex eval DSL from string' do
      string = "alpha true
                bravo Configuration.new do
                  charlie true
                  delta Configuration.new do
                    echo true
                  end
                end"
      conf = nil
      expect do
        conf = Configuration.read string
      end.to_not raise_error
      conf.should_not be_nil
      conf.alpha.should be_true
      conf.bravo.should be_a Configuration
      conf.bravo.alpha should be_true
      conf.bravo.charlie should be_true
      conf.bravo.delta.should be_a Configuration
      conf.bravo.delta.alpha.should be_true
      conf.bravo.delta.charlie.should be_true
      conf.bravo.delta.echo.should be_true
    end

  end # loads

  it 'delegates hash methods to internal hash' do
    conf = nil
    expect do
      conf = Configuration.new
      conf.alpha 1
      conf.bravo 'two'
      conf.charlie 3.0
      conf.delta :four
    end.to_not raise_error
    conf.should_not be_nil
    expect do
      conf.each { |k,v| x = v }
    end.to_not raise_error
    conf.size.should == 4
  end

end