# Describe and context
# Not good:
RSpec.describe Book do
  describe '#reserve' do
    it 'raises already reserved error when already reserved' do
      # ...
    end

    it 'reserves the book when the book is available' do
      # ...
    end
  end
end

# Good:
RSpec.describe Book do
  describe '#reserve' do
    context 'when already reserved' do
      it 'raises already reserved error' do
        # ...
      end
    end

    context 'the book is available' do
      it 'reserves the book' do
        # ...
      end
    end
  end
end

# -----------------------------------------------------------------------------
# Use signle-level contexts
# Not good:

RSpec.describe Book do
  describe '#reserve' do
    context 'when already reserved' do
      let(:reserved) { true }
      context 'when the users reservation limit is exceeded' do
        let(:exceeded) { true }
        # ...
      end

      context 'when the users reservation limit is not exceeded' do
        let(:exceeded) { false }
        # ...
      end
    end

    context 'the book is available' do
      let(:reserved) { false }
      context 'when the users reservation limit is exceeded' do
        let(:exceeded) { true }
        # ...
      end

      context 'when the users reservation limit is not exceeded' do
        let(:exceeded) { false }
        # ...
      end
    end
  end
end

# Good:

RSpec.describe Book do
  describe '#reserve' do
    context 'when already reserved and the user reservation limit is exceeded' do
      let(:reserved) { true }
      let(:exceeded) { true }
      # ...
    end

    context 'when already reserved and the users reservation limit is not exceeded' do
      let(:reserved) { true }
      let(:exceeded) { false }
      # ...
    end

    context 'the book is available and the user reservation limit is exceeded' do
      let(:reserved) { false }
      let(:exceeded) { true }
      # ...
    end

    context 'the book is available and the user has enough reservation limit' do
      let(:reserved) { false }
      let(:exceeded) { false }
      # ...
    end
  end
end


# -----------------------------------------------------------------------------
# Use let
# Not good:

RSpec.describe Book do
  describe '#reserve' do
    context 'when the book is already reserved' do
      it 'returns falsey value' do
        reserved = true
        book = Book.new(reserved: reserved)
        book.reserve
        expect(book.reserved).to be_truthy
      end
    end
  end
end

RSpec.describe Book do
  describe '#reserve' do
    before do
      @reserved = true
      @book = Book.new(reserved: reserved)
      @book.reserve
    end

    it 'returns falsey value' do
      expect(@book.reserve).to be_falsey
    end
  end
end


# Good:
RSpec.describe Book do
  describe '#reserve' do
    subject { book.reserve }
    let(:book) { Book.new(reserved: reserved) }
    let(:reserved) { true }

    it 'returns falsey value' do
      is_expected.to be_falsey
    end
  end
end
