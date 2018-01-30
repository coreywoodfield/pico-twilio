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
      base_url = <<https://#{account_sid}:#{auth_token}@api.twilio.com/2010-04-01/Accounts/#{account_sid}/Messages.json?Page=#{page}&PageSize=#{page_size}>>
      base_url += (to == null) => "" | <<&To=#{to}>>
      base_url += (from == null) => "" | <<&From=#{from}>>
      http:get(base_url){"messages"}
    }
	}

	rule test_send_sms {
		select when test new_message
		send_sms(event:attr("to"), event:attr("from"), event:attr("message"), keys:twilio{"account_sid"}, keys:twilio{"auth_token"})
	}
}
