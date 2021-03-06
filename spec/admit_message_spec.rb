require 'spec_helper'

describe HealthSeven::Message do
  class AdmitMessage < HealthSeven::Message
    define_message do
      evn
      pid
      nk1
      pv1
      al1
      gt1
      in1s {
        in2
      }
      zbc
    end
  end

  it "should pasre admit message" do
    msg = AdmitMessage.parse(load_message('admit'))

    msg.evn[1].should == 'A04'

    msg.pid[5,1].should == 'SMITH'
    msg.pid[5,2].should == 'LIDA'

    msg.in1s.count.should == 2
    msg.in1s[0][4,1].should == 'MEDICARE I/P'
    msg.in1s[0].in2[2].should == '000000008'
  end

  it 'should not parse a corrupted message' do
    -> {
      msg = AdmitMessage.parse(load_message('corrupt_admit'))
    }.should raise_error do |error|
      error.should be_a(HealthSeven::BadGrammarException)
      error.message.should =~ 'IN2'
    end
  end

  it 'should not raise an exception in case of incorrect order of top level segments' do
    -> {
      msg = AdmitMessage.parse(load_message('disordered_admit'))
    }.should_not raise_error

  end
end
