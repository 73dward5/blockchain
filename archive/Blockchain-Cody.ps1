class Transaction { 
    [String]$fromAddress;
    [String]$toAddress;
    [Int32]$amount;

    Transaction ([String]$fromAddress, [String]$toAddress, [Int32]$amount) {
        $this.fromAddress =$fromAddress
        $this.toAddress = $fromAddress
        $this.amount = $amount
    }
}

class Block {
    [Int32] $nonce;
    [string] $hash;
    [string] $hash_prev;
    [Transaction] $transaction;

    Block([Transaction]$transaction, [String]$hash_prev) {
        $this.nonce = 0
        $this.hash = calculateHash
        $this.hash_prev = Hash_prev
        $this.transaction = $transaction
    }
    # [String] calculateHash(){
    #   return [String]::new("string")
    # }
}

class BlockChain {
     $chain =@() 

     Blockchain(){
         $this.chain = createGenesisBlock
     }

     [Block] createGenesisBlock(){
        return [BLock]::new()
     }
     
     addBlock ([Block]$newblock){
         $this.chain.add($newBlock)
     }
     [Block] getLatestBlock() {
         return $this.chain[$this.chain.length - 1]
     }
}