require 'spec_helper'

describe Readgex::SimpleParser do
  subject { Readgex::SimpleParser }

  it { should be_an_instance_of Module }
  its(:ancestors) { should include(Readgex::Motion, Readgex::Core) }

  context 'included' do
    before do
      class Readgex::SimpleParser::TestClass
        include Readgex::SimpleParser
      end
    end
    subject { Readgex::SimpleParser::TestClass.new }

    describe '#char' do
      let(:test_string) { 'rockin like a hurricane' }
      before { subject.entire_input = test_string }

      context 'at the end of input' do
        before { subject.position = test_string.length }

        it 'should raise an error' do
          expect { subject.send(:char, 'c') }
              .to raise_error(Readgex::EndOfInputError)
        end
      end

      context 'before the end of input' do
        let(:position) { 1 }
        before { subject.position = position }
        context 'when the input matches the character' do
          it 'should yield the result' do
            subject.send(:char, test_string[position]) { |ch| ch }.should == test_string[position]
          end

          it 'should move forward' do
            expect { subject.send(:char, test_string[position]) }
                .to change { subject.position }
                .by(1)
          end
        end

        context 'when the input does not match the character' do
          it 'should raise an error' do
            expect { subject.send(:char, test_string[position.succ]) }
                .to raise_error(Readgex::MismatchError)
          end
        end
      end
    end

    describe '#string' do
      let(:test_string) { 'i am the walrus' }
      before do
        subject.entire_input = test_string
        subject.position = position
      end

      context 'at the end of input' do
        let(:position) { test_string.length }

        context 'when an empty string is the potential parse' do
          it 'should not raise an error and yield an empty String' do
            subject.send(:string, '') { |str| str }.should == ''
          end
        end

        context 'when a nonempty string is the potential parse' do
          it 'should raise an error' do
            expect { subject.send(:string, 'abc') { |str| nil } }
                .to raise_error(Readgex::EndOfInputError)
          end
        end
      end

      context 'before the end of input' do
        let(:position) { 5 }
        context 'when the string matches the input' do
          it 'should yield the string' do
            subject.send(:string, 'the') { |str| str }.should == 'the'
          end

          it 'should move forward' do
            expect { subject.send(:string, 'the') }
                .to change { subject.position }
                .by(3)
          end
        end

        context 'when the string does not match the input' do
          it 'should cosume no input' do
            expect { subject.send(:string, 'teh') { |str| str } }
                .to raise_error(Readgex::MismatchError)
          end
        end
      end
    end

    describe '#option', :current do
      let(:test_string) { 'blueprint' }
      before do
        subject.position = 0
        subject.entire_input = test_string
      end

      context 'when the first parser succeeds' do
        it 'should yield the result of that parse' do
          subject.send(:option, proc { string 'blue' }, proc { string 'red' }) do |res|
            res 
          end.should == 'blue'
        end
      end

      context 'when the last parser succeeds' do
        it 'should yield the result of that parse' do
          subject.send(:option, proc { string 'red' }, proc { string 'blue' }) do |res|
            res 
          end.should == 'blue'
        end
      end

      context 'when none of the parsers succeed' do
        it 'should raise an error' do
          expect do
            subject.send(:option, proc { string 'red' }, proc { string 'green' })
          end.to raise_error(Readgex::MismatchError)
        end
      end
    end

    describe '? methods' do
      before do
        subject.position = 1
        subject.entire_input = 'hello'
      end

      context 'when the parse fails' do
        it 'should yield nil' do
          subject.send(:char?, 'h') { |ch| ch }.should be_nil
        end

        it 'should not move forward' do
          expect { subject.send(:string?, 'he') }
              .to_not change { subject.position }
        end
      end

      context 'when the parse succeeds' do
        it 'should yield the result' do
          subject.send(:string?, 'ell') { |str| str }.should == 'ell'
        end

        it 'should move forward' do
          expect { subject.send(:string?, 'ell') }
              .to change { subject.position }
              .by(3)
        end
      end
    end
  end
end
