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

# Case 1
RSpec.describe Book do
  describe '#reserve' do
    context 'when the book is already reserved' do
      it 'returns falsey value' do
        reserved = true
        book = Book.new(reserved: reserved)
        book.reserve
        expect(book.reserved).to be_falsey
      end
    end
  end
end

# Case 2
RSpec.describe Book do
  describe '#reserve' do
    context 'when the book is already reserved' do
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
end


# Good:
RSpec.describe Book do
  describe '#reserve' do
    subject { book.reserve }
    let(:book) { Book.new(reserved: reserved) }

    context 'when the book is already reserved' do
      let(:reserved) { true }

      it 'returns falsey value' do
        is_expected.to be_falsey
      end
    end
  end
end


# -----------------------------------------------------------------------------
# Use subject and named subject
# Not good:
RSpec.describe Book do
  describe '#reserve' do
    let(:book) { Book.new(reserved: false) }
    let(:user) { User.new }

    it 'returns truthy value' do
      expect(book.reserve(user)).to be_truthy
    end

    it 'reserved user returns correct user' do
      book.reserve(user)
      expect(book.reserved_user).to eq user
    end
  end
end

# Better
RSpec.describe Book do
  describe '#reserve' do
    subject { book.reserve }

    let(:book) { Book.new(reserved: false) }
    let(:user) { User.new }

    it 'returns truthy value' do
      is_expected.to be_truthy
    end

    it 'reserved user returns correct user' do
      subject
      expect(book.reserved_user).to eq user
    end
  end
end

# Good
RSpec.describe Book do
  describe '#reserve' do
    subject(:reserve_book) { book.reserve }

    let(:book) { Book.new(reserved: false) }
    let(:user) { User.new }

    it 'returns truthy value' do
      is_expected.to be_truthy
    end

    it 'reserved user returns correct user' do
      reserve_book
      expect(book.reserved_user).to eq user
    end

    it 'number of books that the user reserved increases by 1' do
      expect { reserve_book }.to change { user.reserved_books.count }.by(1)
    end
  end
end

# -----------------------------------------------------------------------------
# Reserved DRY
# Not good:
RSpec.shared_examples 'reservation' do |decrease_by:, has_due_date:|
  it "reserve the book and decrease remainings by -#{decrease_by}" do
    expect { reserve_book }.to change { user.remainings_count }.by(- decrease_by)
    expect(book.reserved_user).to eq user
    expect(book.reservation.due_date.present?).to be has_due_date
  end
end

RSpec.describe Book do
  describe '#reserve' do
    subject(:reserve_book) { book.reserve }
    let(:book) { Book.new }

    context 'when user has admin role' do
      let(:user) { User.new(role: [:admin]) }
      it_bahaves_like "reservation", decrease_by: 0, has_due_date: false
    end

    context 'when user has normal role' do
      let(:user) { User.new(role: [:normal]) }
      it_bahaves_like "reservation", decrease_by: 1, has_due_date: true
    end
  end
end

# Good:
RSpec.describe Book do
  describe '#reserve' do
    subject(:reserve_book) { book.reserve }
    let(:book) { Book.new }

    context 'when user has admin role' do
      let(:user) { User.new(role: [:admin]) }

      it "reserve and decrease remaining count and has no due date" do
        expect { reserve_book }.not_to change { user.remaining_count }
        expect(book.reserved_user).to eq user
        expect(book.reservation.due_date.present?).to be_falsey
      end
    end

    context 'when user has normal role' do
      let(:user) { User.new(role: [:normal]) }

      it "reserve and decrease remaining count and has no due date" do
        expect { reserve_book }.to change { user.remaining_count }.by(1)
        expect(book.reserved_user).to eq user
        expect(book.reservation.due_date.present?).to be_truthy
      end
    end
  end
end


# Expect change
# Not Good:
Rspec.describe Book do
  describe '#reserve' do
    subject(:reserve_book) { book.reserve(user) }
    let!(:user) { User.new(remaining_count: 3) }

    it 'decrease remaining count by 1' do
      reserve_book
      expect(user.remaining_count).to eq 2
    end
  end
end

# Better
Rspec.describe Book do
  describe '#reserve' do
    subject(:reserve_book) { book.reserve(user) }
    let!(:user) { User.new(remaining_count: 3) }

    it 'decrease remaining count by 1' do
      expect { reserve_book }.to change { user.remaining_count }.by(-1)
    end
  end
end


# -----------------------------------------------------------------------------
# Should not update context value
# Not good:

# Case 1
RSpec.describe Book do
  describe '#reserve' do
    subject { book.reserve }
    let(:book) { Book.new(avalilable: true) }

    context 'when the book is not available' do
      before do
        book.update(available: false)
      end

      # ...
    end
  end
end

# Case 2
RSpec.describe Book do
  describe '#reserve' do
    subject { book.reserve }
    let(:book) { Book.new(available: available, country: country) }
    let(:available) { true }
    let(:country) { :jp }

    context 'when the book is not available' do
      let(:available) { false }

      # ...
    end
  end
end


# Better
RSpec.describe Book do
  describe '#reserve' do
    subject { book.reserve }
    let(:book) { Book.new(available: available, country: :jp) }

    context 'when the book is not available' do
      let(:available) { false }

      # ...
    end
  end
end
