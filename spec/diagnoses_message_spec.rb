require 'spec_helper'

describe HealthSeven::Message do
  class DiagnosesMessage < HealthSeven::Message
    define_message do
      msh
      evn
      pid
      pv1?
      dg1s
    end
  end

  it "should pasre diagnoses message" do
    msg = DiagnosesMessage.parse(load_message('diagnoses'))

    msg.dg1s.count.should == 2
    msg.dg1s[0][4].should == 'DX HAIR LOSS 427.0 785.1'
    msg.dg1s[1][2].should == 'I9'
  end
end
