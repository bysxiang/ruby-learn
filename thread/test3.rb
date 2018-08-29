class Account

  def initialize()
    @balance = 100
  end

  def set_balance(val)
    @balance = val
  end

  def atm(val)
    @balance -= val
  end

  def get_balance
    return @balance
  end
end

account = Account.new

def test(account)

  100.times do |i|
    Thread.new do 

      balance = account.atm(10)

      if i < 10
        sleep 5
      end

      account.set_balance(balance)
    end.join()
  end
  # user1 = 

  # user2 = Thread.new do 
  #   balance = account.atm(10)
  #   account.set_balance(balance)
  # end.join()

  # user3 = Thread.new do 
  #   balance = account.atm(10)
  #   account.set_balance(balance)
  # end.join()
end


puts "account.balance: #{account.get_balance}"