class Transaction {
    [String]$fromAddress;
    [String]$toAddress;
    [Int32]$ammount;

    Transaction ([String]$fromAddress, [String]$toAddress, [Int32]$ammount) {
        $this.fromAddress = $fromAddress
        $this.toAddress = $toAddress
        $this.ammount = $ammount
    }

    [String] ToString() {
        return "$($this.fromAddress) + $($this.toAddress) + $($this.ammount)"
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
        $this.transaction = $transaction
        $this.hash = $this.calculateHash()
        $this.hash_prev = $hash_prev
        $this.timestamp = $timestamp
        
    }
    [String] calculateHash(){
        Write-Host "$($this.transaction.ToString())"
        $stream = "$($this.hash_prev) + $($this.timestamp.ToString()) + $($this.transaction.ToString())"
        return Get-FileHash -InputStream $([IO.MemoryStream]::new([byte[]][char[]]$stream)) -Algorithm SHA256
    }
    mineBlock([Int32]$difficulty) {
        while ($($this.hash.Substring(0, $difficulty)).length -ne (([char[]]$difficulty).Length + 1) ){
            $this.nonce++
            $this.hash = $this.calculateHash()
        } 
    }
}

class BlockChain {
    [Block[]]$chain = @()
    [Int32]$difficulty = 2
    [Transaction[]]$pendingTransactions = @()
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
        $block = $null

        foreach ( $transactions in $this.pendingTransactions ){ 
            $block = [Block]::new($(Get-Date), $transactions, $this.chain[$this.chain.lenth -1].hash)
        }
        $block.mineBlock($this.difficulty)

        if ($?) { Write-Host "Block Successfully Mined!" }
        $this.chain += $block

        $this.pendingTransactions += [Transaction]::new($null, $minningRewardAddress, $this.minningReward)
    }

    createTransaction([Transaction]$transaction){
        if ($this.pendingTransactions.length -eq 0) { $this.pendingTransactions = $transaction }
        elseif($this.pendingTransactions.length -gt 0) { $this.pendingTransactions += $transaction }
    }

    [Block] getLatestBlock() {
        return $this.chain[$this.chain.length - 1]
    }

    [Int32] getBallanceOfAddress($address){
        $ballance = 0

        foreach ($block in $($this.chain)) {
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

$blockChain = [BlockChain]::new($([Transaction]::new("","",0)))
$blockChain.createTransaction($([Transaction]::new("address1","address2",100)))
$blockChain.createTransaction($([Transaction]::new("address2","address1",50)))

$blockChain.minePendingTransactions("address3")

$blockChain.getBallanceOfAddress("address3")
$blockChain.minePendingTransactions("address3")

$blockChain.getBallanceOfAddress("address3")