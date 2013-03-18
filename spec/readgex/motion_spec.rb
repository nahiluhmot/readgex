require 'spec_helper'

describe Readgex::Motion do
  subject { Readgex::Motion }
  it { should be_an_instance_of Module }
  its(:ancestors) { should include(Readgex::Core) }

  context 'included' do
    before do
      class Readgex::Motion::TestClass
        include Readgex::Motion
      end
    end

    subject { Readgex::Motion::TestClass.new }

    describe '#one_forward' do
      let(:test_string) { 'here i am' }
      before do
        subject.entire_input = test_string
        subject.position = position
      end

      describe 'before the end of input' do
        let(:position) { subject.input.length.pred }

        it 'should move the position forward one' do
          expect { subject.send(:one_forward) }.to change { subject.position }.by(1)
        end

        it 'should return the specified character' do
          subject.send(:one_forward).should == test_string[-1]
        end
      end

      describe 'at the end of input' do
        let(:position) { subject.input.length }

        it 'should raise an error' do
          expect { subject.send(:one_forward) }.to raise_error(Readgex::EndOfInputError)
        end
      end
    end

    describe '#one_backward' do
      let(:test_string) { 'i am here' }
      before do
        subject.entire_input = test_string
        subject.position = position
      end

      describe 'after the beginning of input' do
        let(:position) { 1 }

        it 'should move the position backward one' do
          expect { subject.send(:one_backward) }.to change { subject.position }.by(-1)
        end

        it 'should return the specified character' do
          subject.send(:one_backward).should == test_string[position]
        end
      end

      describe 'at the beginning of input' do
        let(:position) { 0 }

        it 'should raise an error' do
          expect { subject.send(:one_backward) }.to raise_error(Readgex::BeginningOfInputError)
        end
      end
    end

    describe '#forward' do
      let(:test_string) { 'this is me' }
      let(:position) { 3 }
      before do
        subject.entire_input = test_string
        subject.position = position
      end

      context 'with a number less than 0' do
        it 'should raise an error' do
          expect { subject.send(:forward, -1) }.to raise_error(ArgumentError)
        end
      end

      context 'with a number greater than or equal to 0' do
        context 'when the position moves too far forward' do
          it 'should raise an error' do
            expect { subject.send(:forward, 100) }.to raise_error(Readgex::EndOfInputError)
          end
        end

        context 'when the position does not move too far forward' do
          it 'should move the position forward the specified amount' do
            expect { subject.send(:forward, 2) }.to change { subject.position }.by(2)
          end

          it 'should return the consumed input' do
            subject.send(:forward, 2).join.should == test_string[position .. position.succ]
          end
        end
      end
    end

    describe '#backward' do
      let(:test_string) { 'hi mom it is me' }
      let(:position) { 5 }
      before do
        subject.entire_input = test_string
        subject.position = position
      end

      context 'with a number less than 0' do
        it 'should raise an error' do
          expect { subject.send(:backward, -1) }.to raise_error(ArgumentError)
        end
      end

      context 'with a number greater than or equal to 0' do
        context 'when the position moves too far backward' do
          it 'should raise an error' do
            expect { subject.send(:backward, 100) }.to raise_error(Readgex::BeginningOfInputError)
          end
        end

        context 'when the position does not move too far backward' do
          it 'should move the position backward the specified amount' do
            expect { subject.send(:backward, 3) }.to change { subject.position }.by(-3)
          end

          it 'should return the consumed input' do
            subject.send(:backward, 4).join.should == test_string[position - 3 .. position].reverse
          end
        end
      end
    end

    describe '#forward_while' do
      let(:test_string) { 'we should leave' }
      let(:position) { 6 }
      before do
        subject.entire_input = test_string
        subject.position = position
      end

      context 'when no block is given' do
        it 'should raise an error' do
          expect { subject.send(:forward_while) }.to raise_error(ArgumentError)
        end
      end

      context 'when a block is given' do
        context 'whose arity is 0' do
          let(:sequence) { [true, true, false] }

          it 'should go forward while the block returns true' do
            expect { subject.send(:forward_while) { sequence.shift } }
                .to change { subject.position }.by(2)
          end
        end

        context 'whose artiy is greater than 0' do
          it 'should go forward while the block returns true' do
            expect { subject.send(:forward_while) { |c| c != 'v' } }
                .to change { subject.position }
                .from(position)
                .to(test_string.index('v'))
          end
        end
      end
    end

    describe '#backward_while' do
      let(:test_string) { 'i am trapped' }
      let(:position) { 7 }
      before do
        subject.entire_input = test_string
        subject.position = position
      end

      context 'when no block is given' do
        it 'should raise an error' do
          expect { subject.send(:backward_while) }.to raise_error(ArgumentError)
        end
      end

      context 'when a block is given' do
        context 'whose arity is 0' do
          let(:sequence) { [true, true, true, false] }

          it 'should go backward while the block returns true' do
            expect { subject.send(:backward_while) { sequence.shift } }
                .to change { subject.position }.by(-3)
          end
        end

        context 'whose artiy is greater than 0' do
          it 'should go backward while the block returns true' do
            expect { subject.send(:backward_while) { |c| c != 'm' } }
                .to change { subject.position }
                .from(position)
                .to(test_string.index('m'))
          end
        end
      end
    end

    describe '#forward_until' do
      let(:test_string) { 'we should leave' }
      let(:position) { 6 }
      before do
        subject.entire_input = test_string
        subject.position = position
      end

      context 'when no block is given' do
        it 'should raise an error' do
          expect { subject.send(:forward_until) }.to raise_error(ArgumentError)
        end
      end

      context 'when a block is given' do
        context 'whose arity is 0' do
          let(:sequence) { [false, false, true] }

          it 'should go forward until the block returns true' do
            expect { subject.send(:forward_until) { sequence.shift } }
                .to change { subject.position }.by(2)
          end
        end

        context 'whose artiy is greater than 0' do
          it 'should go forward until the block returns true' do
            expect { subject.send(:forward_until) { |c| c == 'v' } }
                .to change { subject.position }
                .from(position)
                .to(test_string.index('v'))
          end
        end
      end
    end

    describe '#backward_until' do
      let(:test_string) { 'i am trapped' }
      let(:position) { 7 }
      before do
        subject.entire_input = test_string
        subject.position = position
      end

      context 'when no block is given' do
        it 'should raise an error' do
          expect { subject.send(:backward_until) }.to raise_error(ArgumentError)
        end
      end

      context 'when a block is given' do
        context 'whose arity is 0' do
          let(:sequence) { [false, false, false, true] }

          it 'should go backward until the block returns true' do
            expect { subject.send(:backward_until) { sequence.shift } }
                .to change { subject.position }.by(-3)
          end
        end

        context 'whose artiy is greater than 0' do
          it 'should go backward until the block returns true' do
            expect { subject.send(:backward_until) { |c| c == 'm' } }
                .to change { subject.position }
                .from(position)
                .to(test_string.index('m'))
          end
        end
      end
    end

    describe '? methods' do
      let(:test_string) { 'i am sick of making these up' }
      let(:position) { 6 }

      before do
        subject.entire_input = test_string
        subject.position = position
      end

      context 'forward motion' do
        context 'when the end of input is not reached' do
          it 'should move the position forward' do
            expect { subject.send(:forward_until?) { |ch| ch == 'k' } }
                .to change { subject.position }
                .from(position)
                .to(test_string.index('k'))
          end

          it 'should return what it consumes' do
            subject.send(:forward_until?) { |ch| ch == 'k' }
                .join.should == test_string[position..test_string.index('k').pred]
          end
        end

        context 'when the end of input is reached' do
          it 'should consume until the end of input' do
            expect { subject.send(:forward_until?) { |ch| ch == 'z' } }
                .to change { subject.position }
                .from(position)
                .to(test_string.length)
          end

          it 'should return what it consumes' do
            subject.send(:forward_until?) { |ch| ch == 'z' }.join.should == test_string[position..-1]
          end
        end
      end

      context 'backward motion' do
        context 'when the beginning of input is not reached' do
          it 'should move the position backward' do
            expect { subject.send(:backward?, 3) }
                .to change { subject.position }
                .by(-3)
          end

          it 'should return what it consumes' do
            subject.send(:backward?, 3).reverse.join.should == test_string[position - 2..position]
          end
        end

        context 'when the beginning of input is reached' do
          it 'should consume until the beginning of input' do
            expect { subject.send(:backward?, 100) }
                .to change { subject.position }
                .from(position)
                .to(0)
          end

          it 'should return what it consumes' do
            subject.send(:backward?, 100).reverse.join.should == test_string[0..position]
          end
        end
      end
    end
  end
end
