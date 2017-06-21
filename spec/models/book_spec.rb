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
