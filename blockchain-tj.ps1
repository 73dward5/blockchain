class Transaction {
    [String]$fromAddress;
    [String]$toAddress;
    #Add type: $Type;
    [Int32]$ammount;

    Transaction ([String]$fromAddress, [String]$toAddress, [Int32]$ammount) {
        $this.fromAddress = $fromAddress
        $this.toAddress = $toAddress
        $this.ammount = $ammount
    }
    # To give a string output to the class
    [String] ToString() {
        return "from = $($this.fromAddress), to = $($this.toAddress), ammount = $($this.ammount)"
    }
}

class Block {
    [Int32]$nonce;
    [String]$hash;
    [String]$hash_prev;
    [DateTime]$timestamp;
    [Transaction[]]$transactions;

    Block([DateTime]$timestamp, [Transaction[]]$transactions, [String]$hash_prev){
        $this.nonce = 0
        $this.transactions = $transactions
        $this.hash = $this.calculateHash()
        $this.hash_prev = $hash_prev
        $this.timestamp = $timestamp
        
    }
    # To give a string output to the class
    [String]ToString(){
        return "nonce: $($this.nonce), hash: $($this.hash), previousHash: $($this.hash_prev)"
    }
    [String] calculateHash(){
        # Input string to hash
        # Change transactions to array pull data and put in to a string
        # $((-join $this.transactions).ToString())
        $string = "$($this.nonce)$($this.hash_prev)$($this.timestamp.ToString())$((-join $this.transactions).ToString()))"
        #$string = "$($this.nonce)$($this.hash_prev)$($this.timestamp.ToString())$($this.transaction.ToString())"

        #Hash it up
        $hasher = [System.Security.Cryptography.HashAlgorithm]::Create('sha256')
        $string = $hasher.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($string))
        $hashString = [System.BitConverter]::ToString($string)
        return $hashString.Replace('-', '')
    }
    mineBlock([Int32]$difficulty) {
        while ($($this.hash.Substring(0, $difficulty)) -ne $(-join @(0) * $difficulty) ){
            $this.nonce++
            $this.hash = $(-join @(0) * $this.nonce) + $this.calculateHash()
        } 
    }
}

class BlockChain {
    [Block[]]$chain
    [Int32]$difficulty = 5
    [Transaction[]]$pendingTransactions
    [Int32]$minningReward = 100
    
    BlockChain(){
        $this.chain = $this.createGenesisBlock()
    }

    [Block] createGenesisBlock() {
        return $([Block]::new($(Get-Date), [Transaction[]]$([Transaction]::new("","",0)), "0"))
    }
        
    minePendingTransactions($minningRewardAddress) {

        Write-Host "Processing current transactions..."
        $block = [Block]::new($(Get-Date), $this.pendingTransactions, $($this.chain[$this.chain.lenth -1].hash))
        $block.mineBlock($this.difficulty)
        Write-Host "Block successfully mined: $($block.ToString())"
        if ($?) { Write-Host "*** $($this.pendingTransactions.length) Blocks Successfully Mined! ***" }
        $this.chain += $block

        #Clear the pending transactions because they are no longer pending
        $this.pendingTransactions = [Transaction]::new("rewardAddress", $minningRewardAddress, $this.minningReward)
    }

    createTransaction([String]$fromAddress, [String]$toAddress, [Int]$ammount){
        $this.pendingTransactions += $([Transaction]::new($fromAddress, $toAddress, $ammount))
    }

    [Block] getLatestBlock() {
        return $this.chain[$this.chain.length - 1]
    }

    [Int32] getBallanceOfAddress($address){
        [Int32]$ballance = 0

        foreach ($block in $this.chain) {
            foreach ($transaction in $block.transactions) { # This is the line with the error for the calculation
                # We need to make transactions an array or figure out some way to itterate through all the transactions
                if ($transaction.fromAddress -eq $address){ $ballance -= $($transaction.ammount) }
                elseif ($transaction.toAddress -eq $address) { $ballance += $($transaction.ammount) }
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
# Create the initial block chain with a blank genesis block
$blockChain = [BlockChain]::new()

# Create some fake transactions
$blockChain.createTransaction("rewardAddress","address1",100)
$blockChain.createTransaction("address1","address2",100)
$blockChain.createTransaction("address2","address1",50)

# Mine the transactions and show the output
$blockChain.minePendingTransactions("miner")
Write-Host "Ballance of address2: $($blockChain.getBallanceOfAddress("address2"))"
Write-Host "Ballance of address1: $($blockChain.getBallanceOfAddress("address1"))"

# Mine the transactions from when the miner mined the previous transactions
# The miner does not get his reward till his transaction has been processed
$blockChain.minePendingTransactions("miner")
Write-Host "Ballance of miner: $($blockChain.getBallanceOfAddress("miner"))"
Write-Host "Ballance of address2: $($blockChain.getBallanceOfAddress("address2"))"
Write-Host "Ballance of address1: $($blockChain.getBallanceOfAddress("address1"))"
Write-Host "Block Chain Validation: $($blockchain.isChainValid())"