require_relative 'mail_parser'

class CyberAdaptMailParser
  include MailParser
  
  def initialize(email_string=nil)
    @string = email_string
  end

  def parse(str=@string)
    @string = str
    { # Order matters! This eats the string while parsing to make it one pass.
      alert_id: find_then_eat('#', ']'),
      alert: copy_message_payload,
      alert_timestamp: find_then_eat(nil, ' '),
      src_ip: find_then_eat("SRC=", ":"),
      src_port: find_then_eat(nil, ' '),
      dst_ip: find_then_eat("DST=", ":"),
      dst_port: find_then_eat(nil, ' '),
      msg: find_then_eat("msg:", ";"),
    }
  end

  private
  def copy_message_payload
    # This kills everything outside the payload because it's in a <pre> tag.
    # We also need to duplicate @string so we can continue killing off text during
    # our search process. As @string shortens, so does runtime
    @string = @string[ 0..(@string.rindex("</pre>") - 1) ]
    @string = @string[ (@string.index("<pre") + 1)..-1   ]
    @string = @string[ (@string.index('>') + 1)..-1      ]
    @string.dup
  end
end

# Because this code should end up being linear time and because it's literally a low level automata,
# coding it in an easily read way is difficult. If you view the email format I think it's
# easier to see what's going on here. Notice that the message payload is completely enclosed
# below in a <pre> tag.
#
# <meta http-equiv="Content-Type" content="text/html; charset=utf-8"><p>Greetings,</p>
# 
# <p>This message has been automatically generated in response to the
#   creation of a trouble ticket regarding <b>flexplan botcc 192.168.11.81 -&gt; 87.246.143.242</b>,
#   a summary of which appears below.</p>
# 
# <p>There is no need to reply to this message right now.  Your ticket has been
#   assigned an ID of <b>[cyberadapt.com #26038]</b>.</p>
# 
# <p>Please include the string <b>[cyberadapt.com #26038]</b>
#   in the subject line of all future correspondence about this issue. To do so,
#   you may reply to this message.</p>
# 
# <p>Thank you,<br>
# </p>
# 
# <hr>
# <pre style="white-space: pre-wrap; font-family: monospace;">2019-03-28T15:41:24.000Z | PROBE=Server Room stack | SEV=1.5 | botcc | SRC=192.168.11.81:52470 | DST=87.246.143.242:80 | alert ip $HOME_NET any -&gt; [87.246.143.242,87.254.167.37,89.108.85.65,89.223.26.52,89.252.186.142] any (msg:ET CNC Zeus Tracker Reported CnC Server group 21; reference:url,doc.emergingthreats.net/bin/view/Main/BotCC; reference:url,zeustracker.abuse.ch; threshold:type limit, track by_src, seconds 3600, count 1; flowbits:set,ET.Evil; flowbits:set,ET.BotccIP; classtype:trojan-activity; sid:2404170; rev:5318; metadata:affected_product Windows_XP_Vista_7_8_10_Server_32_64_Bit, attack_target Client_Endpoint, deployment Perimeter, tag Banking_Trojan, signature_severity Major, created_at 2013_10_15, updated_at 2019_03_26;)</pre>
