class SftpFile
  attr_accessor :filename, :text

  def initialize(filename: nil, text: nil)
    @filename = filename
    @text = text
  end

  def ==(obj)
    return false unless obj.instance_of? SftpFile
    return @text == obj.text && @filename == obj.filename
  end
end
