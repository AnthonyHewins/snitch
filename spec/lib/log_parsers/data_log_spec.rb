require 'tempfile'
require 'rails_helper'
Dir.glob(Rails.root.join 'log_parsers/*').each do |f|
  require f
end

RSpec.describe DataLog do
  before :all do
    @path = Rails.root.join('tmp/data_log_test_20190101.tmp').to_path
    @headers = %w(1 2)
    CSV.open(@path, 'wb') {|csv| 2.times { csv << @headers }}
  end

  before :each do
    @obj = DataLog.new(@path, false, FFaker::Time.date) {|row| nil}
  end

  subject {DataLog.new(@path, false, FFaker::Time.date) {|row| nil}}
  it {should have_attr_reader :clean}
  it {should have_attr_reader :dirty}
  it {should have_attr_reader :filename}
  it {should have_attr_reader :recorded}
  it {should have_abstract_method :parse_row}

  context 'private:' do
    context '#read' do
      before :each do
        @read_result = @obj.send(:read, CSV.read(@path)) {|row| row.join('')}
      end

      it 'opens the CSV, maps a lambda over the CSV::Rows, and returns the result' do
        expect(@read_result).to eq ['12'] * 2
      end

      it "inits @dirty to []" do
        expect(@obj.dirty).to eq []
      end
    end
    
    context '#parse_csv' do
      context 'on ActionDispatch::Http::UploadedFile input' do
        before :all do
          @tempfile = Tempfile.new 'asf'
          @tempfile.write @headers.join(',') + "\n" + @headers.join(',')
        end
        
        before :each do
          @tempfile.rewind
          @file = ActionDispatch::Http::UploadedFile.new tempfile: @tempfile
        end

        it 'returns CSV::Table' do
          expect(@obj.send :parse_csv, @file, true).to be_instance_of CSV::Table
        end

        it 'it uses the headers' do
          expect(@obj.send(:parse_csv, @file, true).headers).to eq @headers
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
        
        it 'sets the @filename to arg.original_filename' do
          @obj.send :parse_csv, @file, false
          expect(@obj.filename).to eq @file.original_filename
        end
      end
      
      context 'on Pathname input' do
        before :each do
          @pathname = Pathname.new @path
        end

        it 'returns CSV::Table' do
          expect(@obj.send :parse_csv, @pathname, true).to be_instance_of CSV::Table
        end

        it 'it uses the headers' do
          expect(@obj.send(:parse_csv, @pathname, true).headers).to eq @headers
        end

        context 'when headers is false' do
          it 'returns a 2D array' do
            expect(@obj.send :parse_csv, @pathname, false).to be_instance_of Array
          end

          it 'it treats the first row as part of the content' do
            # It should match exactly the contents that was put into it
            expect(@obj.send(:parse_csv, @pathname, false)).to eq [@headers] * 2
          end
        end
        
        it 'sets the @filename to arg.to_path' do
          @obj.send :parse_csv, @pathname, false
          expect(@obj.filename).to eq @pathname.to_path
        end
      end
      
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
        expect(@obj.send :parse_timestamp_args, Date.today)
          .to be_instance_of PaperTrail
      end

      it "returns PaperTrail.create(insertion_date: arg.to_date) if its a DateTime" do
        expect(@obj.send :parse_timestamp_args, DateTime.now)
          .to be_instance_of PaperTrail
      end

      it "returns the arg if it's a PaperTrail instance" do
        paper_trail = create :paper_trail
        expect(@obj.send :parse_timestamp_args, paper_trail).to eq paper_trail
      end

      it 'raises a type error on anything else' do
        expect{@obj.send :parse_timestamp_args, 1}.to raise_error TypeError
      end
    end

    context '#get_filename_timestamp' do
      before :all do
        DataLog::FORMAT = /somethin_[0-9]+/
      end

      it 'raises ArgumentError if @filename doesnt match self.class::FORMAT' do
        @obj.instance_variable_set :@filename, '@'
        expect{@obj.send :get_filename_timestamp}.to raise_error ArgumentError
      end

      it 'uses TIMESTAMP to parse @filename for a Date' do
        DataLog::TIMESTAMP = /[0-9]+/
        @obj.instance_variable_set :@filename, 'somethin_20190101'
        expect(@obj.send :get_filename_timestamp).to eq Date.new(2019, 1, 1)
      end
    end

    context '#find_or_create_paper_trail' do
      it 'finds a PaperTrail before creating it if matches exactly' do
        already_exists = create :paper_trail, filename: @obj.filename
        expect(
          @obj.send(:find_or_create_paper_trail, already_exists.insertion_date)
        ).to eq already_exists
      end

      it 'creates the PaperTrail if it doesnt exist' do
        expect{@obj.send(:find_or_create_paper_trail, Date.today)}
          .to change{PaperTrail.count}.by 1
      end
    end
  end
end
