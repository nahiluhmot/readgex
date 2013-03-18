require 'spec_helper'

describe Readgex::Core do
  subject { Readgex::Core }

  it { should be_an_instance_of Module }

  context 'included' do
    before do
      class Readgex::Core::TestClass
        include Readgex::Core
      end
    end

    subject { Readgex::Core::TestClass.new }

    [:input, :position, :parser].each do |field|
      it { should respond_to field }
      it { should respond_to :"#{field}=" }
    end

    describe '#beginning_of_input?' do
      context 'when the position is 0' do
        before { subject.position = 0 }

        its(:beginning_of_input?) { should be_true }
      end

      context 'when the position is not 0' do
        before { subject.position = 1 }

        its(:beginning_of_input?) { should be_false }
      end
    end

    describe '#end_of_input?' do
      let(:test_string) { 'hello world' }
      before { subject.input = test_string.split('') }

      context 'when the position the length of the input' do
        before { subject.position = test_string.length }

        its(:end_of_input?) { should be_true }
      end

      context 'when the position is not 0' do
        before { subject.position = test_string.length.pred }

        its(:end_of_input?) { should be_false }
      end
    end

    describe '#with_last_result' do
      let(:test_string) { 'kanye west' }
      before { subject.last_result = test_string }

      it 'should yield the last result' do
        subject.with_last_result { |str| str }.should == test_string
      end
    end

    describe '#consumed_input' do
      let(:test_string) { 'i am a robot' }
      before do
        subject.input = test_string.split('')
        subject.position = position
      end

      context 'when the position is 0' do
        let(:position) { 0 }
        its(:consumed_input) { should be_empty }
      end

      context 'when the position is not 0' do
        let(:position) { 2 }
        its(:consumed_input) { should == test_string[0..position.pred].split('') }
      end
    end

    describe '#peek' do
      let(:test_string) { 'sic' }
      let(:position) { 1 }
      before do
        subject.input = test_string.split('')
        subject.position = position
      end

      it 'should return the current character' do
        subject.peek.should == test_string[position]
      end
    end

    describe '#entire_input' do
      let(:test_string) { 'hey there jim' }
      before { subject.input = test_string.split('') }

      it 'should return the original String' do
        subject.entire_input.should == test_string
      end
    end

    describe '#entire_input=' do
      let(:test_string) { 'my name is tom' }
      before { subject.entire_input = test_string }

      it 'should set @input to the String split by each character' do
        subject.input.should == test_string.split('')
      end
    end
  end
end
