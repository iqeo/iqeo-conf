require 'spec_helper'
require 'iqeo/configuration'
require 'stringio'

include Iqeo

describe Configuration do

  def simple_eval_string
    "alpha 1
    bravo 'two'
    charlie 3.0
    delta :four"
  end

  def simple_explicit_configuration
    conf = Configuration.new
    conf.alpha 1
    conf.bravo 'two'
    conf.charlie 3.0
    conf.delta :four
    conf
  end

  def simple_configuration_example conf
    conf.should_not be_nil
    conf.alpha.should   == 1     and conf.alpha.should be_a Integer
    conf.bravo.should   == "two" and conf.bravo.should be_a String
    conf.charlie.should == 3.0   and conf.charlie.should be_a Float
    conf.delta.should   == :four and conf.delta.should be_a Symbol
  end

  def nested_configuration_example conf
    conf.alpha.should be true
    conf.foxtrot.should be true
    simple_configuration_example conf.bravo
    conf.bravo.foxtrot.should be true
    simple_configuration_example conf.echo
    conf.echo.foxtrot.should be true
  end

  context 'v1.0' do

    it 'reports the correct version' do
      Configuration.version.should == CONFIGURATION_VERSION
    end

    context 'at creation' do

      it 'does not require a block' do
        Configuration.new.should be_a Configuration
      end

      it 'accept a block with arity 0' do
        Configuration.new {  }.should be_a Configuration
      end

      it 'instance_eval a block with arity 0' do
        conf_eval = nil
        conf_new = Configuration.new { conf_eval = self }
        conf_new.should be conf_eval
      end

      it 'accept a block with arity 1' do
        Configuration.new { |arg| }.should be_a Configuration
      end

      it 'yield self to block with arity 1' do
        conf_yielded = nil
        conf_new = Configuration.new { |conf| conf_yielded = conf }
        conf_new.should be conf_yielded
      end

      it 'accept a block with arity > 1' do
        Configuration.new { |arg1,arg2,arg3| }.should be_a Configuration
      end

      it 'yield self to block with arity > 1' do
        conf_yielded = nil
        conf_new = Configuration.new { |conf,arg1,arg2| conf_yielded = conf }
        conf_new.should be conf_yielded
      end


      it 'accepts defaults from another configuration' do
        conf = Configuration.new simple_explicit_configuration
        simple_configuration_example conf
      end

      it 'overrides defaults from another configuration' do
        conf_default = Configuration.new( simple_explicit_configuration ) { echo true }
        conf_default.echo.should be true
        conf = Configuration.new( conf_default ) { echo false }
        simple_configuration_example conf
        conf.echo.should be false
      end

      context 'can load' do

        it 'simple eval DSL from string' do
          simple_configuration_example Configuration.read simple_eval_string
        end

        it 'simple eval DSL from file (StringIO)' do
          simple_configuration_example Configuration.load StringIO.new simple_eval_string
        end

        it 'simple eval DSL from file (mock & expected methods)' do
          file = mock
          file.should_receive( :respond_to? ).with( :read ).and_return true
          file.should_receive( :read ).and_return simple_eval_string
          simple_configuration_example Configuration.load file
        end

        it 'simple eval DSL from filename (expected methods)' do
          File.should_receive( :read ).with( "filename" ).and_return simple_eval_string
          simple_configuration_example Configuration.load "filename"
        end

        it 'complex eval DSL from string' do
          string = "alpha true
                    bravo do
                      charlie true
                      delta do
                        echo true
                      end
                    end"
          conf = Configuration.read string
          conf.should_not be_nil
          conf.alpha.should be true
          conf.bravo.should be_a Configuration
          conf.bravo.alpha.should be true
          conf.bravo.charlie.should be true
          conf.bravo.delta.should be_a Configuration
          conf.bravo.delta.alpha.should be true
          conf.bravo.delta.charlie.should be true
          conf.bravo.delta.echo.should be true
        end

      end # loads

    end # creation

    context 'settings retrieval' do

      it 'returns nil for non-existent settings' do
        simple_explicit_configuration.not_a_setting.should be_nil
      end

      it 'delegates hash methods to internal hash' do
          conf = Configuration.new
          conf.alpha 1
          conf.bravo 2
          conf.charlie 3
          conf.delta 4
        conf.should_not be_nil
        sum = 0
        expect do
          conf.each { |k,v| sum += v }
        end.to_not raise_error
        sum.should == 10
        conf.size.should == 4
      end

    end # settings retrieval

    context 'single value setting' do

      it 'accepts simple values' do
        simple_configuration_example simple_explicit_configuration
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
        conf.alpha.bravo.charlie.should be true
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
        conf.alpha.bravo.__send__(:_parent).should be conf.alpha
        conf.alpha.__send__(:_parent).should be conf
        conf.__send__(:_parent).should be_nil
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
        conf.top.should be true
        conf.alpha.top.should be true
        conf.alpha.middle.should be true
        conf.alpha.bravo.top.should be true
        conf.alpha.bravo.middle.should be true
        conf.alpha.bravo.bottom.should be true
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
          conf.alpha.should be true
          conf.bravo.should be_a Configuration
          conf.bravo.alpha.should be true
          conf.bravo.charlie.should be true
          conf.bravo.delta.should be_a Configuration
          conf.bravo.delta.alpha.should be true
          conf.bravo.delta.charlie.should be true
          conf.bravo.delta.echo.should be true
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

        context 'nested configuration' do

          it 'supported via do..end' do
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
            conf.alpha.should be true
            conf.bravo.should be_a Configuration
            conf.bravo.alpha.should be true
            conf.bravo.charlie.should be true
            conf.bravo.delta.should be_a Configuration
            conf.bravo.delta.alpha.should be true
            conf.bravo.delta.charlie.should be true
            conf.bravo.delta.echo.should be true
          end

          it 'supported via {..}' do
            conf = nil
            expect do
              conf = Configuration.new { |c1| c1.alpha true ; c1.bravo { |c2| c2.charlie true ; c2.delta { |c3| c3.echo true } } }
            end.to_not raise_error
            conf.should_not be_nil
            conf.alpha.should be true
            conf.bravo.should be_a Configuration
            conf.bravo.alpha.should be true
            conf.bravo.charlie.should be true
            conf.bravo.delta.should be_a Configuration
            conf.bravo.delta.alpha.should be true
            conf.bravo.delta.charlie.should be true
            conf.bravo.delta.echo.should be true
          end

          it 'can refer to an inherited setting' do
            conf = nil
            expect do
              conf = Configuration.new do |c1|
                c1.alpha true
                c1.hotel c1.alpha
                c1.bravo do |c2|
                  c2.charlie true
                  c2.foxtrot c2.alpha
                  c2.delta do |c3|
                    c3.echo true
                    c3.golf c3.alpha
                  end
                end
              end
            end.to_not raise_error
            conf.should_not be_nil
            conf.alpha.should be true
            conf.bravo.should be_a Configuration
            conf.bravo.alpha.should be true
            conf.bravo.charlie.should be true
            conf.bravo.delta.should be_a Configuration
            conf.bravo.delta.alpha.should be true
            conf.bravo.delta.charlie.should be true
            conf.bravo.delta.echo.should be true
            conf.bravo.delta.golf.should be true
            conf.bravo.foxtrot.should be true
            conf.hotel.should be true
          end

        end # nested configuration

        context 'can load' do

          it 'settings into the current configuration from a string' do
            conf = Configuration.new do |c|
              c.alpha false
              c._read simple_eval_string
              c.echo true
            end
            simple_configuration_example conf
            conf.echo.should be true
          end

          it 'settings into the current configuration from a file (StringIO)' do
            conf = Configuration.new do |c|
              c.alpha false
              c._load StringIO.new simple_eval_string
              c.echo true
            end
            simple_configuration_example conf
            conf.echo.should be true
          end

          it 'settings into a nested configuration from a string' do
            conf = Configuration.new do |c|
              c.alpha true
              c.bravo do |x|
                x._read simple_eval_string
              end
              c.echo { |x| x._read simple_eval_string }
              c.foxtrot true
            end
            nested_configuration_example conf
          end

          it 'settings into a nested configuration from a file (StringIO)' do
            conf = Configuration.new do |c|
              c.alpha true
              c.bravo do |x|
                x._load StringIO.new simple_eval_string
              end
              c.echo { |x| x._load StringIO.new simple_eval_string }
              c.foxtrot true
            end
            nested_configuration_example conf
          end

        end # can load

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

        context 'nested configuration' do

          it 'supported via do..end' do
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
            conf.alpha.should be true
            conf.bravo.should be_a Configuration
            conf.bravo.alpha.should be true
            conf.bravo.charlie.should be true
            conf.bravo.delta.should be_a Configuration
            conf.bravo.delta.alpha.should be true
            conf.bravo.delta.charlie.should be true
            conf.bravo.delta.echo.should be true
          end

          it 'supported via {..}' do
            conf = nil
            expect do
              conf = Configuration.new { |c1| c1.alpha true ; c1.bravo { |c2| c2.charlie true ; c2.delta { |c3| c3.echo true } } }
            end.to_not raise_error
            conf.should_not be_nil
            conf.alpha.should be true
            conf.bravo.should be_a Configuration
            conf.bravo.alpha.should be true
            conf.bravo.charlie.should be true
            conf.bravo.delta.should be_a Configuration
            conf.bravo.delta.alpha.should be true
            conf.bravo.delta.charlie.should be true
            conf.bravo.delta.echo.should be true
          end

          it 'can refer to an inherited setting' do
            conf = nil
            expect do
              conf = Configuration.new do
                alpha true
                hotel alpha
                bravo do
                  charlie true
                  foxtrot alpha
                  delta do
                    echo true
                    golf alpha
                  end
                end
              end
            end.to_not raise_error
            conf.should_not be_nil
            conf.alpha.should be true
            conf.bravo.should be_a Configuration
            conf.bravo.alpha.should be true
            conf.bravo.charlie.should be true
            conf.bravo.delta.should be_a Configuration
            conf.bravo.delta.alpha.should be true
            conf.bravo.delta.charlie.should be true
            conf.bravo.delta.echo.should be true
            conf.bravo.delta.golf.should be true
            conf.bravo.foxtrot.should be true
            conf.hotel.should be true
          end

        end # nested configuration

        context 'dynamic setting' do

          it 'name can be a local' do
            conf = nil
            expect do
              conf = Configuration.new do
                alpha true
                local1 = 'bravo'
                self[local1] = true
                local2 = 'charlie'
                self[local2] = true
              end
            end.to_not raise_error
            conf.should_not be_nil
            conf.alpha.should be true
            conf.bravo.should be true
            conf.charlie.should be true
          end

          it 'name can be a setting' do
            conf = nil
            expect do
              conf = Configuration.new do
                alpha true
                setting1 'bravo'
                self[setting1] = true
                setting2 'charlie'
                self[setting2] = true
              end
            end.to_not raise_error
            conf.should_not be_nil
            conf.alpha.should be true
            conf.bravo.should be true
            conf.charlie.should be true
            conf.setting1.should == 'bravo'
            conf.setting2.should == 'charlie'
          end

          it 'can reference a nested configuration' do
            conf = nil
            expect do
              conf = Configuration.new do
                alpha true
                local = :bravo
                self[local] = Configuration.new do
                  charlie true
                end
              end
            end.to_not raise_error
            conf.should_not be_nil
            conf.alpha.should be true
            conf.bravo.should be_a Configuration
            conf.bravo.alpha.should be true
            conf.bravo.charlie.should be true
          end

        end # dynamic setting

        context 'can load' do

          it 'settings into the current configuration from a string' do
            $simple_eval_string = simple_eval_string
            conf = Configuration.new do
              alpha true
              _read $simple_eval_string
            end
            simple_configuration_example conf
          end

          it 'settings into the current configuration from a file (StringIO)' do
            $simple_eval_string = simple_eval_string
            conf = Configuration.new do
              alpha true
              _load StringIO.new $simple_eval_string
            end
            simple_configuration_example conf
          end

          it 'settings into a nested configuration from a string' do
            $simple_eval_string = simple_eval_string
            conf = Configuration.new do
              alpha true
              bravo do
                _read $simple_eval_string
              end
              echo { _read $simple_eval_string }
              foxtrot true
            end
            nested_configuration_example conf
          end

          it 'settings into a nested configuration from a file (StringIO)' do
            conf = Configuration.new do
              alpha true
              bravo do
                _load StringIO.new $simple_eval_string
              end
              echo { _load StringIO.new $simple_eval_string }
              foxtrot true
            end
            nested_configuration_example conf
          end

        end # can load

      end # instance_eval DSL

    end # mode of usage

    context 'merge' do

      it 'updates its own configuration' do
        orig = simple_explicit_configuration
        orig.echo :original1
        orig.foxtrot :original2
        other = Configuration.new do
                  foxtrot :overridden
                  hotel :new
                end
        conf = orig._merge! other
        simple_configuration_example conf
        conf.echo.should be :original1
        conf.hotel.should be :new
        conf.foxtrot.should be :overridden
        conf.__send__(:_parent).should be nil
        conf.should be orig
      end

      it 'creates a new configuration' do
        orig = simple_explicit_configuration
        orig.echo :original1
        orig.foxtrot :original2
        other = Configuration.new do
                  foxtrot :overridden
                  hotel :new
                end
        conf = orig._merge other
        simple_configuration_example conf
        conf.echo.should be :original1
        conf.hotel.should be :new
        conf.foxtrot.should be :overridden
        conf.__send__(:_parent).should be nil
        conf.should_not be orig
      end

      it 'updates with a nested configuration' do
        orig = simple_explicit_configuration
        orig.echo    :original1
        orig.foxtrot :original2
        other = Configuration.new do
                  foxtrot :overridden
                  hotel   :new
                  nested do
                    golf  :also_new
                    hotel :overridden
                    echo  :overridden
                  end
                end
        conf = orig._merge! other
        simple_configuration_example conf
        conf.echo.should be :original1
        conf.hotel.should be :new
        conf.foxtrot.should be :overridden
        conf.nested.alpha.should be 1
        conf.nested.echo.should be :overridden
        conf.nested.foxtrot.should be :overridden
        conf.nested.golf.should be :also_new
        conf.nested.hotel.should be :overridden
        conf.nested.__send__(:_parent).should be conf
        conf.__send__(:_parent).should be nil
        conf.should be orig
      end

      it 'creates with a nested configuration' do
        orig = simple_explicit_configuration
        orig.echo    :original1
        orig.foxtrot :original2
        other = Configuration.new do
                  foxtrot :overridden
                  hotel   :new
                  nested do
                    golf  :also_new
                    hotel :overridden
                    echo  :overridden
                  end
                end
        conf = orig._merge other
        simple_configuration_example conf
        conf.echo.should be :original1
        conf.hotel.should be :new
        conf.foxtrot.should be :overridden
        conf.nested.alpha.should be 1
        conf.nested.echo.should be :overridden
        conf.nested.foxtrot.should be :overridden
        conf.nested.golf.should be :also_new
        conf.nested.hotel.should be :overridden
        conf.nested.__send__(:_parent).should be conf
        conf.__send__(:_parent).should be nil
        conf.should_not be orig
      end

      it 'updates by recursively merging conflicting nested configurations' do
        orig = simple_explicit_configuration
        orig.nested1 = Configuration.new do
          echo    :original
          foxtrot :original
          nested2 do
            golf  :original
            hotel :original
          end
        end
        other = Configuration.new do
          nested1 do
            echo  :replaced
            india :new
            nested2 do
              golf :replaced
              juliet :new
            end
          end
        end
        conf = orig._merge! other
        simple_configuration_example conf
        conf.nested1.echo.should be :replaced
        conf.nested1.foxtrot.should be :original
        conf.nested1.india.should be :new
        conf.nested1.nested2.golf.should be :replaced
        conf.nested1.nested2.hotel.should be :original
        conf.nested1.nested2.juliet.should be :new
        conf.nested1.__send__(:_parent).should be conf
        conf.__send__(:_parent).should be nil
        conf.should be orig
      end

      it 'creates by recursively merging conflicting nested configurations' do
        orig = simple_explicit_configuration
        orig.nested1 = Configuration.new do
          echo    :original
          foxtrot :original
          nested2 do
            golf  :original
            hotel :original
          end
        end
        other = Configuration.new do
          nested1 do
            echo  :replaced
            india :new
            nested2 do
              golf :replaced
              juliet :new
            end
          end
        end
        conf = orig._merge other
        simple_configuration_example conf
        conf.nested1.echo.should be :replaced
        conf.nested1.foxtrot.should be :original
        conf.nested1.india.should be :new
        conf.nested1.nested2.golf.should be :replaced
        conf.nested1.nested2.hotel.should be :original
        conf.nested1.nested2.juliet.should be :new
        conf.nested1.__send__(:_parent).should be conf
        conf.__send__(:_parent).should be nil
        conf.should_not be orig
      end

    end

  end # "v1.0"

  def simple_config_1
    Configuration.new do
      alpha   1
      bravo   'one'
      charlie 1.0
      delta   :one
    end
  end

  def simple_config_1_example conf
    conf.should_not be_nil
    conf.alpha.should   == 1     and conf.alpha.should be_a Integer
    conf.bravo.should   == "one" and conf.bravo.should be_a String
    conf.charlie.should == 1.0   and conf.charlie.should be_a Float
    conf.delta.should   == :one  and conf.delta.should be_a Symbol
  end

  def simple_config_2
    Configuration.new do
      echo    2
      foxtrot 'two'
      hotel   2.0
      india   :two
    end
  end

  def simple_config_2_example conf
    conf.should_not be_nil
    conf.echo.should    == 2     and conf.echo.should be_a Integer
    conf.foxtrot.should == "two" and conf.foxtrot.should be_a String
    conf.hotel.should   == 2.0   and conf.hotel.should be_a Float
    conf.india.should   == :two  and conf.india.should be_a Symbol
    conf['echo']
    #and conf[:echo].should be_a Integer

  end

  def simple_config_3
    Configuration.new do
      juliet 3
      kilo   'three'
      lima   3.0
      mike   :three
    end
  end

  def simple_config_3_example conf
    conf.should_not be_nil
    conf.juliet.should == 3       and conf.juliet.should be_a Integer
    conf.kilo.should   == "three" and conf.kilo.should be_a String
    conf.lima.should   == 3.0     and conf.lima.should be_a Float
    conf.mike.should   == :three  and conf.mike.should be_a Symbol
  end

  context 'v1.1' do

    context 'options' do

      it 'have defaults at Configuration creation' do
        conf = Configuration.new
        conf._options[:blankslate].should be true
        conf._options[:case_sensitive].should be true
      end

      it 'are accepted at Configuration creation' do
        conf = Configuration.new nil, :blankslate => false, :case_sensitive => false
        conf._options[:blankslate].should be false
        conf._options[:case_sensitive].should be false
      end

    end

    context 'wildcard *' do

      it 'returns an empty ConfigurationDelegator for subject with no child configurations' do
        conf = simple_config_1
        simple_config_1_example conf
        delegator = conf.*
        delegator.should be_a ConfigurationDelegator
        delegator.should be_empty
      end

      it 'returns ConfigurationDelegator containing child configurations for subject' do
        conf = simple_config_1
        conf.nested2 = simple_config_2
        conf.nested3 = simple_config_3
        simple_config_1_example conf
        simple_config_2_example conf.nested2
        simple_config_3_example conf.nested3
        delegator = conf.*
        delegator.should be_a ConfigurationDelegator
        delegator.size.should be 2
        delegator[0].should be conf.nested2
        delegator[1].should be conf.nested3
      end

    end

    context 'ConfigurationDelegator' do

      it 'can be created with no child configurations' do
        delegator = ConfigurationDelegator.new []
        delegator.should be_a ConfigurationDelegator
        delegator.should be_empty
      end

      context 'wildcard *' do

        # todo: question : should wildcard return nil for already empty ConfigurationDelegator / overshoot ?

        it 'returns an empty ConfigurationDelegator for ConfigurationDelegator with no child configurations' do
          conf = simple_config_1
          conf.nested2 = simple_config_2
          conf.nested3 = simple_config_3
          simple_config_1_example conf
          simple_config_2_example conf.nested2
          simple_config_3_example conf.nested3
          delegator = conf.*.*
          delegator.should be_a ConfigurationDelegator
          delegator.should be_empty
        end

        it 'returns an empty ConfigurationDelegator when overshoots' do
          conf = simple_config_1
          conf.nested2 = simple_config_2
          conf.nested3 = simple_config_3
          simple_config_1_example conf
          simple_config_2_example conf.nested2
          simple_config_3_example conf.nested3
          delegator = conf.*.*.*.*.*.*.*.*.*
          delegator.should be_a ConfigurationDelegator
          delegator.should be_empty
        end

        it 'returns ConfigurationDelegator containing child configurations for ConfigurationDelegator' do
          conf = simple_config_1
          conf.nested2 = simple_config_2
          conf.nested3 = simple_config_3
          conf.nested2.nested2 = simple_config_2
          conf.nested2.nested3 = simple_config_3
          conf.nested3.nested2 = simple_config_2
          conf.nested3.nested3 = simple_config_3
          simple_config_1_example conf
          simple_config_2_example conf.nested2
          simple_config_2_example conf.nested2.nested2
          simple_config_2_example conf.nested3.nested2
          simple_config_3_example conf.nested3
          simple_config_3_example conf.nested2.nested3
          simple_config_3_example conf.nested3.nested3
          delegator = conf.*.*
          delegator.size.should be 4
          delegator[0].should be conf.nested2.nested2
          delegator[1].should be conf.nested2.nested3
          delegator[2].should be conf.nested3.nested2
          delegator[3].should be conf.nested3.nested3
        end

      end # wildcard *

    end # ConfigurationDelagator

  end #v1.1

end

