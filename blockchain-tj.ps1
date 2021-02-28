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
    [DateTime]$timestamp;
    [Transaction]$transaction;

    Block([DateTime]$timestamp, [Transaction]$transaction, [String]$hash_prev){
        $this.nonce = 0
        $this.hash = calculateHash
        $this.hash_prev = $hash_prev
        $this.timestamp = $timestamp
        $this.transaction = $transaction
    }
    [String] calculateHash(){
        $stream = $this.hash_prev + $this.timestamp.ToString() + $this.transaction.ToString()
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
    [Int32]$difficulty = 2
    [Array]$pendingTransactions = @()
    [Int32]$minningReward = 100
    
    BlockChain(){
        $this.chain = createGenesisBlock
    }

    [Block] createGenesisBlock() {
        return [Block]::new($(Get-Date), [Transaction]::new(), "0")
    }
        
    <#addBlock([Block]$newBlock) { 
        $this.chain.add($newBlock)
    }#>
    minePendingTransactions() {
        $block = [Block]::new($(Get-Date), $this.pendingTransactions)
        $block.mineBlock($this.difficulty)

        if ($?) { Write-Host "Block Successfully Mined!" }
        $this.chain.add($block)

        $this.pendingTransactions.Add([Transaction]::new($null, "FAKEminningRewardAddress", $this.minningReward))
    }
    [Block] getLatestBlock() {
        return $this.chain[$this.chain.length - 1]
    }
    [Bool] isChainValid(){
        $this.chain | ForEach-Object {
            $currentBlock = $this.chain[$this.chain.indexOf($_)]
            $previousBlock = $this.chain[$($this.chain.indexOf($_)) - 1]
            
            if ($currentBlock.hash -ne $currentBlock.calculateHash()) {
                return $False
            }
            if ($previousBlock.$hash_prev -ne $currentBlock.hash) {
                return $False
            } 
        }
        return $True
    }
}