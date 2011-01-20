require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'fileutils'

DIST = File.dirname(__FILE__)+'/dist'

describe "JBundle" do
  
  before do
    JBundle.config_from_file ::File.join(::File.dirname(__FILE__),'JFile')
  end
  
  it 'should have a version' do
    JBundle.config.version.to_s.should == '1.6.1'
  end
  
  it 'should have bundles' do
    JBundle.config.bundles[0].name.should == 'foo.js'
    JBundle.config.bundles[1].name.should == 'foo2.js'
  end
  
  context 'bundling' do
    
    it 'should build single bundles' do
      JBundle.build('foo.js').src.should == "var VERSION = '1.6.1';\nvar a1 = 1;\nvar a2 = 2;\n"
      JBundle.build('file4.js').min.should == "var a4=4;\n"
    end
    
    it 'should bundle bundles' do
      JBundle.output.size.should == 4
      JBundle.output[0].name.should == 'foo.js'
      JBundle.output[0].src.should == "var VERSION = '1.6.1';\nvar a1 = 1;\nvar a2 = 2;\n"
      JBundle.output[0].min.should == "var VERSION=\"1.6.1\",a1=1,a2=2;\n"
    end
    
    it 'should not minify licenses' do
      JBundle.build('foo2.js').src.should == "/* Version: 1.6.1\nThis is a license\n-----------------------*/\nvar a3 = 3;\nvar a4 = 4;\n"
      JBundle.build('foo2.js').min.should == "/* Version: 1.6.1\nThis is a license\n-----------------------*/\nvar a3=3,a4=4;\n"
    end
    
  end
  
  context 'writing' do
    
    before do
      FileUtils.rm_rf DIST
      @written_files = JBundle.write!
    end
    
    it 'should write files' do
      File.exist?(DIST + '/1.6.1/foo.js').should be_true
      File.exist?(DIST + '/1.6.1/foo.min.js').should be_true
      File.exist?(DIST + '/1.6.1/foo2.js').should be_true
      File.exist?(DIST + '/1.6.1/foo2.min.js').should be_true
      File.exist?(DIST + '/1.6.1/file4.js').should be_true
      File.exist?(DIST + '/1.6.1/file4.min.js').should be_true
      File.exist?(DIST + '/1.6.1/text.txt').should be_true
      File.exist?(DIST + '/1.6.1/text.min.txt').should be_false

      File.exist?(DIST + '/1.6/foo.js').should be_true
      File.exist?(DIST + '/1.6/foo.min.js').should be_true
      File.exist?(DIST + '/1.6/foo2.js').should be_true
      File.exist?(DIST + '/1.6/foo2.min.js').should be_true
      File.exist?(DIST + '/1.6/file4.js').should be_true
      File.exist?(DIST + '/1.6/file4.min.js').should be_true
      File.exist?(DIST + '/1.6/text.txt').should be_true
      File.exist?(DIST + '/1.6/text.min.txt').should be_false
    end
    
    it 'should have run after_write block' do
      File.exist?(DIST + '/1.6.1/foo.txt').should be_true
      File.exist?(DIST + '/1.6/foo.txt').should be_true
    end
    
    it 'should return a list of files written' do
      @written_files.should == [
        DIST + '/1.6.1/foo.js',
        DIST + '/1.6.1/foo.min.js',
        DIST + '/1.6/foo.js',
        DIST + '/1.6/foo.min.js',
        
        DIST + '/1.6.1/foo2.js',
        DIST + '/1.6.1/foo2.min.js',
        DIST + '/1.6/foo2.js',
        DIST + '/1.6/foo2.min.js',
        
        DIST + '/1.6.1/file4.js',
        DIST + '/1.6.1/file4.min.js',
        DIST + '/1.6/file4.js',
        DIST + '/1.6/file4.min.js',
        
        DIST + '/1.6.1/text.txt',
        DIST + '/1.6/text.txt'
      ]
    end
    
  end
  
end
