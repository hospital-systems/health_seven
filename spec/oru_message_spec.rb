require 'spec_helper'

describe HealthSeven::Message do
  class OruMessage < HealthSeven::Message
    define_message do
      pid
      pv1?
      orc {
        obrs {
          ntes?
          obxs {
            ntes?
          }
        }
      }
    end
  end

  it "should pasre ORU message" do
    mrn = '111'
    account_number = '111'
    msg = OruMessage.parse(load_message('oru_r01'))
    msg.pid[5,1].should == 'SMITH'
    msg.pid[5,2].should == 'JOHN'

    msg.pv1.should be_nil

    msg.orc.obrs.length.should == 3
    msg.orc.obrs[0].obxs.length.should == 16
    msg.orc.obrs[1].obxs.length.should == 2
    msg.orc.obrs[2].obxs.length.should == 1

    msg.orc.obrs[0].ntes.should be_empty

    msg.orc.obrs[2].obxs[0].ntes[0][3].should =~ /Note:/
  end
end
