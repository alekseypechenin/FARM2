class Notifications < ActionMailer::Base
  default :from => "from@example.com"

  def forgot_password
    @greeting = "Hi"
    @subject    = "Your password is ..."
    @body['login']=login
    @body['pass']=pass
    @recipients = to
    @from       = 'support@yourdomain.com'
    @sent_on    = sent_at
    @headers    = {}
    mail :to => "to@example.org"
  end
  
end
