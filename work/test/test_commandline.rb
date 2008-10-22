require 'clio/commandline'
require 'test/unit'

class TC_Commandline < Test::Unit::TestCase

  def setup
    @cmd = Clio::Commandline.new("--force copy --file try.rb")
  end

  def test_flag_option
    assert(@cmd.force?)
  end

  def test_value_option
    assert_equal('try.rb', @cmd.file)
  end

  def test_argument
    assert_equal('copy', @cmd[0])
  end

end


class TC_Commandline_Aliases < Test::Unit::TestCase

  def setup
    @cmd = Clio::Commandline.new("--force copy --file try.rb")
    @cmd.force?(:f)
    @cmd.file(:o)
  end

  def test_flag_option
    assert(@cmd.f?)
  end

  def test_value_option
    assert_equal('try.rb', @cmd.o)
  end

  def test_argument
    assert_equal('copy', @cmd[0])
  end

end

=begin
class TC_Commandline_Subclass < Test::Unit::TestCase

  class SCommandline < Clio::Commandline
    attr :force?, :f?
    attr :file, :o
  end

  def setup
    @cmd = SCommandline.new("--force copy --file try.rb")
  end

  def test_predefined_options
    o = @cmd.object_class.predefined_options
    assert( o.include?( [:file, :o]) )
    assert( o.include?( [:force?, :f?]) )
  end

  def test_flag_option
    assert(@cmd.f?)
  end

  def test_value_option
    assert_equal('try.rb', @cmd.o)
  end

  def test_argument
    assert_equal('copy', @cmd[0])
  end

  def test_instance_options
    e = {:force=>true, :file=>'try.rb'}
    assert_equal(e, @cmd.instance_options)
  end

end
=end

