ruleset twilio {
	meta {
		use module keys
	}

	global {
		send_sms = defaction(to, from, message, account_sid, auth_token) {
			base_url = <<https://#{account_sid}:#{auth_token}@api.twilio.com/2010-04-01/Accounts/#{account_sid}/>>
			http:post(base_url + "Messages.json", form = {"From":from, "To":to, "Body":message})
		}

    messages = function(account_sid, auth_token, page=0, page_size=50, to=null, from=null) {
      http:get(<<https://#{account_sid}:#{auth_token}@api.twilio.com/2010-04-01/Accounts/#{account_sid}/Messages.json?Page=#{(page == null) => 0 | page}&PageSize=#{(page_size == null) => 50 | page_size}>> + ((to == null) => "" | <<&To=#{to}>>) + ((from == null) => "" | <<&From=#{from}>>)).decode(){"messages"}
    }
	}

	rule test_send_sms {
		select when test new_message
		send_sms(event:attr("to"), event:attr("from"), event:attr("message"), keys:twilio{"account_sid"}, keys:twilio{"auth_token"})
	}

  rule get_messages {
    select when test get_messages
    send_directive("say", {"messages": messages(keys:twilio{"account_sid"}, keys:twilio{"auth_token"}, event:attr("page"), event:attr("page_size"), event:attr("to"), event:attr("from"))})
  }
}
