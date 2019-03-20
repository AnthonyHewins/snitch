require 'rails_helper'
Dir.glob(Rails.root.join 'lib/assets/log_parsers/*').each do |f|
  require f
end

RSpec.describe DataLog do
  before :all do
    @path = Rails.root.join('tmp/data_log_test_20190101.tmp').to_path
    @headers = %w(1 2)
    CSV.open(@path, 'wb') {|csv| 2.times { csv << @headers }}
  end

  before :each do
    @obj = DataLog.new(@path, false, nil, nil, nil) {|row| nil}
  end

  subject {DataLog.new(@path, false, nil, nil, nil) {|row| nil}}
  it {should have_attr_reader :clean}
  it {should have_attr_reader :dirty}
  it {should have_attr_reader :filename}
  it {should have_attr_reader :date_override}
  it {should have_abstract_method :parse_row}

  context 'private:' do
    context '#read' do
      before :each do
        @read_result = @obj.send(:read, CSV.read(@path)) {|row| row.join('')}
      end

      it 'opens the CSV, maps a lambda over the CSV::Rows, and returns the result' do
        expect(@read_result).to eq ['12'] * 2
      end

      [:@clean, :@dirty].each do |var|
        it "inits #{var} to []" do
          expect(@obj.instance_variable_get var).to eq []
        end
      end
    end
    
    context '#parse_csv' do
      context 'on string input' do
        context 'when headers is true' do
          it 'returns CSV::Table' do
            expect(@obj.send :parse_csv, @path, true).to be_instance_of CSV::Table
          end

          it 'it uses the headers' do
            expect(@obj.send(:parse_csv, @path, true).headers).to eq @headers
          end
        end

        context 'when headers is false' do
          it 'returns a 2D array' do
            expect(@obj.send :parse_csv, @path, false).to be_instance_of Array
          end

          it 'it treats the first row as part of the content' do
            # It should match exactly the contents that was put into it
            expect(@obj.send(:parse_csv, @path, false)).to eq [@headers] * 2
          end
        end
        
        it 'sets the @filename to arg' do
          @obj.send :parse_csv, @path, false
          expect(@obj.filename).to eq @path
        end
      end

      context 'on SftpFile input' do
        before :each do
          @file = SftpFile.new filename: @path, text: File.read(@path)
        end

        context 'when headers is true' do
          it 'returns CSV::Table' do
            expect(@obj.send :parse_csv, @file, true).to be_instance_of CSV::Table
          end

          it 'it uses the headers' do
            expect(@obj.send(:parse_csv, @file, true).headers).to eq @headers
          end
        end

        context 'when headers is false' do
          it 'returns a 2D array' do
            expect(@obj.send :parse_csv, @file, false).to be_instance_of Array
          end

          it 'it treats the first row as part of the content' do
            # It should match exactly the contents that was put into it
            expect(@obj.send(:parse_csv, @file, false)).to eq [@headers] * 2
          end
        end
        
        it 'sets the @filename to arg.path' do
          @obj.send :parse_csv, @path, false
          expect(@obj.filename).to eq @file.filename
        end
      end

      context "on File input" do
        before :each do
          @file = File.open @path
        end

        context 'when headers is true' do
          it 'returns CSV::Table' do
            expect(@obj.send :parse_csv, @file, true).to be_instance_of CSV::Table
          end

          it 'it uses the headers' do
            expect(@obj.send(:parse_csv, @file, true).headers).to eq @headers
          end
        end

        context 'when headers is false' do
          it 'returns a 2D array' do
            expect(@obj.send :parse_csv, @file, false).to be_instance_of Array
          end

          it 'it treats the first row as part of the content' do
            # It should match exactly the contents that was put into it
            expect(@obj.send(:parse_csv, @file, false)).to eq [@headers] * 2
          end
        end
        
        it 'sets the @filename to arg.path' do
          @obj.send :parse_csv, @path, false
          expect(@obj.filename).to eq @file.path
        end
      end

      context "on CSV input" do
        it "calls read on the arg, returning CSV::Table if headers was set to true on the original CSV object" do
          file = CSV.open @path, headers: true
          expect(@obj.send :parse_csv, file, false).to be_instance_of CSV::Table
        end

        it "calls read on the arg, returning a 2D Array if headers was set to false on the original CSV object" do
          file = CSV.open @path, headers: false
          expect(@obj.send :parse_csv, file, false).to be_instance_of Array
        end

        it 'sets the @filename to arg.path' do
          file = CSV.open @path, headers: false
          @obj.send :parse_csv, file, false
          expect(@obj.filename).to eq file.path
        end
      end

      context "on CSV::Table input" do
        before :each do
          @table = CSV.read @path, headers: false
        end

        it "returns it" do
          expect(@obj.send :parse_csv, @table, false).to be @table
        end

        it 'sets the @filename to nil' do
          @obj.send :parse_csv, @table, false
          expect(@obj.filename).to be nil
        end
      end

      context "on Array input" do
        it "returns it" do
          expect(@obj.send :parse_csv, [], false).to eq []
        end

        it 'sets the @filename to nil' do
          @obj.send :parse_csv, [], false
          expect(@obj.filename).to be nil
        end
      end

      it 'raises a type error on anything else' do
        expect{@obj.send :parse_csv, 1, false}.to raise_error TypeError
      end
    end

    context '#parse_timestamp_args' do
      it "returns PaperTrail.create(insertion_date: arg) if its a Date" do
        date = Date.today
        expect(@obj.send :parse_timestamp_args, date, nil, CarbonBlackLog).to be_instance_of PaperTrail
      end

      it "returns PaperTrail.create(insertion_date: arg.to_date) if its a DateTime" do
        date = DateTime.now
        expect(@obj.send :parse_timestamp_args, date, nil, CarbonBlackLog).to be_instance_of PaperTrail
      end

      it "returns the arg if it's a NilClass instance" do
        expect(@obj.send :parse_timestamp_args, nil, nil, CarbonBlackLog).to eq nil
      end

      it "returns the arg if it's a PaperTrail instance" do
        paper_trail = create :paper_trail
        expect(@obj.send :parse_timestamp_args, paper_trail, nil, CarbonBlackLog).to eq paper_trail
      end

      it 'raises a type error on anything else' do
        expect{@obj.send :parse_timestamp_args, 1, nil, nil}.to raise_error TypeError
      end
    end

    context '#decide_on_timestamp(date_override, regex)' do
      it 'takes precendence on date_override and returns it if it isnt nil' do
        expect(@obj.send :decide_on_timestamp, 1, 2).to eq 1
      end

      it 'returns nil if both args are nil' do
        expect(@obj.send :decide_on_timestamp, nil, nil).to be nil
      end

      it 'uses regex to parse the filename for a timestamp otherwise' do
        expect(@obj.send :decide_on_timestamp, nil, /[0-9]+/).to eq Date.new(2019, 1, 1)
      end
    end

    context '#find_or_create_paper_trail' do
      it 'finds a PaperTrail before creating it if matches exactly' do
        already_exists = create :paper_trail, filename: @obj.filename
        expect(
          @obj.send(:find_or_create_paper_trail, already_exists.insertion_date, already_exists.log_type)
        ).to eq already_exists
      end

      it 'creates the PaperTrail if it doesnt exist' do
        expect{@obj.send(:find_or_create_paper_trail, Date.today, CyberAdaptLog)}
          .to change{PaperTrail.count}.by 1
      end
    end
  end
end
