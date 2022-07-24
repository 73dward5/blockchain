# Powershell Blockchain

This was a very simple excersize to demonstrate the blockchain concepts using powershell. I also played around with converting the code to go as shown in the go-api-test directiory. 

Afer running the script the below lines will simulate transactions on the chain.

```powershell
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
```
