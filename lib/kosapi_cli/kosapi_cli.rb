#
module KOSapiCLI
  singleton_class.class_eval do
    include Authentication

    def method_missing(method, *args, &block)
      if proxy.respond_to?(method)
        proxy.send(method, *args, &block)
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      proxy.respond_to?(method_name, include_private)
    end

    def proxy
      @proxy ||= KOSapiClientProxy.new
    end

    private

    def configure_client(token, id, secret)
      KOSapiClient.configure do |c|
        if token
          c.client_token = token
        else
          c.client_id = id
          c.client_secret = secret
        end
      end
    end

    def token
      token_obj = KOSapiClient.http_client.get_access_token
      token_hash = { 'access_token' => token_obj.token,
                     'refresh_token' => token_obj.refresh_token,
                     'expires_at' => token_obj.expires_at }
      token_obj.params.merge(token_hash)
    end

    def loader
      @loader ||= KOSapiTokenLoader.new(config)
    end

    def creds
      @creds || KOSapiCredentialsLoader.new
    end

    def config
      @config ||= Configuration.new
    end
  end
end
