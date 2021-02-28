class Transaction {
    [String]$fromAddress;
    [String]$toAddress;
    [Int32]$ammount;

    Transaction ([String]$fromAddress, [String]$toAddress, [Int32]$ammount) {
        $this.fromAddress = $fromAddress
        $this.toAddress = $fromAddress
        $this.ammount = $ammount
    }
}

class Block {
    [Int32]$nonce;
    [String]$hash;
    [String]$hash_prev;
    [Transaction]$transaction;

    Block([Transaction]$transaction, [String]$hash_prev){
        $this.nonce = 0
        $this.hash = calculateHash
        $this.hash_prev = $hash_prev
        $this.transaction = $transaction
    }
    [String] calculateHash(){
        $stream = $this.hash_prev + $this.transaction.ToString()
        return Get-FileHash -InputStream $([IO.MemoryStream]::new([byte[]][char[]]$stream)) -Algorithm SHA256
    }
    mineBlock([Int32]$difficulty) {
        while ($this.hash.Substring(0, $difficulty) -ne (([char[]]$difficulty).Length + 1) ){
            $this.nonce++
            $this.hash = $this.calculateHash()
        } 
    }
}

class BlockChain {
    $chain = @()
    
    BlockChain(){
        $this.chain = createGenesisBlock
    }

    [Block] createGenesisBlock() {
        return [Block]::new()
    }
        
    addBlock([Block]$newBlock) { 
        $this.chain.add($newBlock)
    }
    [Block] getLatestBlock() {
        return $this.chain[$this.chain.length - 1]
    }
}