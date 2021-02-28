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
        $this.hash = $this.calculateHash()
        $this.hash_prev = $hash_prev
        $this.timestamp = $timestamp
        $this.transaction = $transaction
    }
    [String] calculateHash(){
        $stream = "$($this.hash_prev) + $($this.timestamp.ToString()) + $($this.transaction.ToString())"
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
    
    BlockChain([Transaction]$transaction){
        $this.chain = $this.createGenesisBlock($transaction)
    }

    [Block] createGenesisBlock([Transaction]$tansaction) {
        return $([Block]::new($(Get-Date), $tansaction, "0"))
    }
        
    <#addBlock([Block]$newBlock) { 
        $this.chain.add($newBlock)
    }#>
    minePendingTransactions($minningRewardAddress) {
        $block = [Block]::new($(Get-Date), $this.pendingTransactions, $this.chain[$this.chain.lenth -1].hash)
        $block.mineBlock($this.difficulty)

        if ($?) { Write-Host "Block Successfully Mined!" }
        $this.chain.add($block)

        $this.pendingTransactions.Add([Transaction]::new($null, $minningRewardAddress, $this.minningReward))
    }

    createTransaction([Transaction]$transaction){
        if (!$this.pendingTransactions) { $this.pendingTransactions = $transaction }
        elseif($this.pendingTransactions) { $this.pendingTransactions.add($transaction) }
    }

    [Block] getLatestBlock() {
        return $this.chain[$this.chain.length - 1]
    }

    [Int32] getBallanceOfAddress($address){
        $ballance = 0

        foreach ($block in $this.chain) {
            foreach ($transaction in $block.transaction) {
                if ($transaction.fromAddress -eq $address){ $ballance -= $transaction.ammount }
                if ($transaction.toAddress -eq $address) { $ballance += $transaction.ammount }
            }
        }
        return $ballance
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

$blockChain = [BlockChain]::new($([Transaction]::new("address1","address2",100)))
#$blockChain.createTransaction([Transaction]::new("address1","address2",100))
#$blockChain.createTransaction($([Transaction]::new("address2","address1",50)))