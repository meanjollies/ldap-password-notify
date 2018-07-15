class Audit
  require 'time'
  require 'net/ldap'
  require_relative 'mailer'

  include Mailer

  attr_accessor :bind_user, :bind_pass, :basedn, :thresh, :blacklist, :sender, :hostname, :port

  def initialize(logger)
    @logger = logger
    @now_date = Time.now.utc.to_i / 86400
    @attrs = ["passwordExpirationTime", "mail", "uid", "givenname"]
    @filter = Net::LDAP::Filter.eq("uid", "*")
  end

  def connect
    @ldap = Net::LDAP.new :host => @hostname,
                         :port => @port,
                         :auth => {
                           :method   => :simple,
                           :username => @bind_user,
                           :password => @bind_pass
                         }

    if ! @ldap.bind
      @logger.fatal "LDAP connection failed: #{@ldap.get_operation_result.message}"
      exit 1
    end
  end

  def audit
    @ldap.search( :base => @basedn, :filter => @filter, :attributes => @attrs ) do |acct|
      begin
        @logger.info "===#{acct.uid.first}==="

        # Skip over blacklisted UIDs
        if @blacklist.include? acct.uid.first
          @logger.warn "#{acct.uid.first}: Blacklisted. Skipping..."
          next
        end

        # Get expiration and notification times for account passwords
        expire_days_unix = Time.parse(acct.passwordExpirationTime.first).to_i / 86400
        expire_days_left = expire_days_unix - @now_date
        notify_days_left = (expire_days_unix - @thresh.to_i) - @now_date

        # Send notification email for threatened passwords, otherwise return the current state
        if expire_days_left <= @thresh.to_i
          if expire_days_left > -3
            notify(@logger, acct.givenname.first, acct.uid.first, acct.mail.first, expire_days_left, @sender)
          else
            @logger.warn "#{acct.uid.first}: Already expired. Skipping."
          end
        else
          @logger.info "#{acct.uid.first}: Expiration: #{expire_days_left} days left"
          @logger.info "#{acct.uid.first}: Notification: #{notify_days_left} days left"
        end

      rescue => error
        @logger.error "#{acct.uid.first}: Audit failed: #{error.message}"
        next
      end
    end
  end
end

