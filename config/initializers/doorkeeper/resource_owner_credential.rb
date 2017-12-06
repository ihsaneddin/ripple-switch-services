class ResourceOwnerCredential

  attr_accessor :account, :request

  def initialize(request)
    self.request= request
  end

  def authenticate!
    safe_authentication
  end

  def safe_authentication
    account = Users::Models::Account.find_for_database_authentication(:login => request.params[:login])
    if account && account.valid_for_authentication? { account.valid_password?(request.params[:password]) }
      return account.confirmed?? account : nil
    end
  end

  class << self

    def authenticate!(request)
      new(request).authenticate!
    end

  end

end