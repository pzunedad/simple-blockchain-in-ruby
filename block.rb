require 'digest'
require 'pp'

class Block
  attr_reader :index, :timestamp, :transactions, 
              :transactions_count, :previous_hash, 
              :nonce, :hash, :aux1, :aux2

  def initialize(index, transactions, previous_hash)
    @index               = index
    @timestamp           = Time.now
    @transactions        = transactions
    @transactions_count  = transactions.size
    @previous_hash       = previous_hash
    @nonce, @hash        = compute_hash_with_proof_of_work

    # Ahora que @nonce y @hash están inicializados, podemos calcular aux1 y aux2
    @aux1 = "#{@previous_hash}#{@hash}"  
    @aux2 = @nonce + @transactions_count
  end

  def compute_hash_with_proof_of_work(difficulty="00")
    nonce = 0
    loop do 
      hash = calc_hash_with_nonce(nonce)
      return [nonce, hash] if hash.start_with?(difficulty)
      nonce += 1
    end
  end

  def calc_hash_with_nonce(nonce=0)
    sha = Digest::SHA256.new
    sha.update(nonce.to_s + 
               @index.to_s + 
               @timestamp.to_s + 
               @transactions.to_s + 
               @transactions_count.to_s + 
               @previous_hash)
    sha.hexdigest
  end

  def self.first(*transactions) # Bloque génesis
    Block.new(0, transactions, "0")
  end

  def self.next(previous, *transactions)
    Block.new(previous.index + 1, transactions, previous.hash)
  end
end