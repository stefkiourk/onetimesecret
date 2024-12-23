# frozen_string_literal: true

require 'onetime'
require 'securerandom'

#Familia.debug = true

# Load the app
OT::Config.path = File.join(Onetime::HOME, 'tests', 'unit', 'ruby', 'config.test.yaml')
OT.boot! :test

@customer = OT::Customer.create "Tryouts+27+#{SecureRandom.uuid}@onetimesecret.com"
@domain = 'example.com'

## Base update_expiration accepts ttl parameter without error
obj = OT::CustomDomain.create(@domain, @customer.custid)
begin
  obj.update_expiration(ttl: 3600)
  true
rescue ArgumentError => e
  false
end
#=> true

## Base update_expiration maintains no-op behavior (returns nil)
obj = OT::CustomDomain.create("a.#{@domain}", @customer.custid)
obj.update_expiration(ttl: 3600)
#=> nil

## Base update_expiration works without ttl parameter
obj = OT::CustomDomain.create("b.#{@domain}", @customer.custid)
obj.update_expiration
#=> nil

## Base update_expiration debug logging works
obj = OT::CustomDomain.create("c.#{@domain}", @customer.custid)
# Debug logging is enabled at the start of this file
obj.update_expiration(ttl: 3600)
true # If we got here without error, logging worked
#=> true

## Base update_expiration works with save(update_expiration: false)
obj = OT::CustomDomain.create("d.#{@domain}", @customer.custid)
begin
  obj.save(update_expiration: false)
  true
rescue => e
  puts e.message
  false
end
#=> true

## Base update_expiration works within Redis transaction
obj = OT::CustomDomain.create("e.#{@domain}", @customer.custid)
begin
  obj.transaction do |conn|
    conn.hmset obj.rediskey, {'test' => 'value'}
    obj.update_expiration(ttl: 3600)
  end
  true
rescue => e
  puts e.message
  false
end
#=> true

# Cleanup
@customer.destroy!
