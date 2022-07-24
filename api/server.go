package main

import (
	//"encoding/json"
	"crypto/sha256"
	"encoding/base64"
	"fmt"
	"log"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/gorilla/mux"
)

func PadRight(str, pad string, lenght int) string {
	for {
		str += pad
		if len(str) > lenght {
			return str[0:lenght]
		}
	}
}
func PadLeft(str, pad string, lenght int) string {
	for {
		str = pad + str
		if len(str) > lenght {
			return str[0:lenght]
		}
	}
}

type BlockChainInt interface {
	toString()
	//Block
	calculateHash()
	mineBlock()
	//BlockChain
	createGenesisBlock()      //Create first block
	minePendingTransactions() //Do something on Transaction Array
	createTransaction()       //Add to Transaction Array
	getLatestBlock()          //return block
	getBallanceOfAddress()    //return int
	isChainValid()            //bool
}

var blockchain BlockChain = BlockChain{
	chain:               []Block{},
	difficulty:          10,
	pendingTransactions: []Transaction{},
	minningReward:       100,
	init:                0,
}

type Transaction struct {
	fromAddress string `json:"fromAddress"`
	toAddress   string `json:"toAddress"`
	amount      int    `json:"amount"`
}

type Block struct {
	nonce        int           `json:"nonce"`
	hash         string        `json:"hash"`
	hash_prev    string        `json:"hash_prev"`
	timestamp    time.Time     `json:"timestamp"`
	transactions []Transaction `json:"transactions"`
}

type BlockChain struct {
	chain               []Block       `json:"chain"`
	difficulty          int           `json:"difficulty"` //5
	pendingTransactions []Transaction `json:"pendingTransactions"`
	minningReward       int           `json:"minningReward` //100
	init                int
}

func (t Transaction) String() string {
	return fmt.Sprintf(`{"from": "%s", "to": "%s", "amount": "%d"}`, t.fromAddress, t.toAddress, t.amount)
}

func (block *Block) AddItem(transaction Transaction) []Transaction {
	block.transactions = append(block.transactions, transaction)
	return block.transactions
}
func (block Block) Byte() []byte {
	return []byte(block.String())
}
func (b Block) String() string {
	return fmt.Sprintf(`{"nonce": "%d", "hash": "%s", "hash_prev": "%s", "timestamp": "%s", "tranactions": "%s"}`, b.nonce, b.hash, b.hash_prev, b.timestamp.Format("2006-01-02 15:04:05"), b.transactions)
}
func (block *Block) calculateHash() string {
	//Get some stuff to hash
	var t_string []string
	for _, t := range block.transactions {
		t_string = append(t_string, t.String())
	}
	string := fmt.Sprintf("%s%s%s", strconv.Itoa(block.nonce), block.hash_prev, block.timestamp.Format("2006-01-02 15:04:05"), strings.Join(t_string, ""))

	//Hash it up
	bv := []byte(string)
	hasher := sha256.New()
	hasher.Write(bv)
	return base64.URLEncoding.EncodeToString(hasher.Sum(nil))
}

func (block *Block) mineBlock() {

	pad := PadLeft("", "0", blockchain.difficulty)

	for block.hash[:blockchain.difficulty] != pad {
		block.calculateHash()
		block.hash = PadLeft("", "0", block.nonce) + block.hash
		block.nonce++
	}
	//return b
}
func createGenesisBlock(w http.ResponseWriter, transaction Transaction) Block {
	block := Block{nonce: 0, hash: "", hash_prev: "", timestamp: time.Now(), transactions: []Transaction{}}
	block.hash = block.calculateHash()
	block.transactions = append(block.transactions, transaction)
	return block
}
func minePendingTransactions(w http.ResponseWriter, r *http.Request) {
	pathParams := mux.Vars(r)
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)

	minerAddress := pathParams["minerAddress"]
	if blockchain.pendingTransactions != nil {
		w.Write([]byte(`{"message": "Creating new block for the transactions"}`))
		block := Block{nonce: 0, hash: "", hash_prev: blockchain.chain[len(blockchain.chain)-1].hash, timestamp: time.Now(), transactions: blockchain.pendingTransactions}
		block.hash = block.calculateHash()
		block.mineBlock()
		w.Write([]byte(fmt.Sprintf(`{"message": "%s"}`, block.String())))
		blockchain.chain = append(blockchain.chain, block)
		blockchain.pendingTransactions = nil
		blockchain.pendingTransactions = []Transaction{}
		blockchain.pendingTransactions = append(blockchain.pendingTransactions, Transaction{fromAddress: "rewardAddress", toAddress: minerAddress, amount: blockchain.minningReward})
	} else {
		w.Write([]byte(`{"message": "No blocks to mine"}`))
	}
}
func createTransaction(w http.ResponseWriter, r *http.Request) {
	pathParams := mux.Vars(r)
	w.Header().Set("Content-Type", "application/json")
	var err error

	from := pathParams["from"]

	to := pathParams["to"]

	amount := -1
	if val, ok := pathParams["amount"]; ok {
		amount, err = strconv.Atoi(val)
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			w.Write([]byte(`{"message": "need a number"}`))
			return
		}
	}

	transaction := Transaction{toAddress: to, fromAddress: from, amount: amount}
	if blockchain.init == 0 {
		w.Write([]byte(`Genesis Block - `))
		block := createGenesisBlock(w, transaction)
		blockchain.chain = append(blockchain.chain, block)
		blockchain.init = 1
		//blockchain.pendingTransactions = append(blockchain.pendingTransactions, transaction)
	} else {
		blockchain.pendingTransactions = append(blockchain.pendingTransactions, transaction)
	}

	w.Write([]byte(transaction.String()))
}
func getLatestBlock(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)

	if blockchain.init == 0 {
		w.Write([]byte(`{"message": "No Blocks in BlockChain"}`))
	} else {
		transactions := blockchain.chain[len(blockchain.chain)-1].transactions
		for _, t := range transactions {
			w.Write([]byte(t.String()))
		}
	}
}
func getBallanceOfAddress(w http.ResponseWriter, r *http.Request) {
	//return int
}
func isChainValid(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)

	//for i, block := range blockchain.chain {
	for i := 0; i < len(blockchain.chain); i++ {
		block := blockchain.chain[i]
		var prev_block Block
		if len(blockchain.chain) > 1 {
			prev_block = blockchain.chain[i-1]
		}

		hash_check := block.calculateHash()

		w.Write(block.Byte())
		w.Write(prev_block.Byte())

		if block.hash != hash_check {
			w.Write([]byte(fmt.Sprintf(`{"message": "%s"}`, block.hash)))
			w.Write([]byte(fmt.Sprintf(`{"message": "%s"}`, hash_check)))
			w.Write([]byte(`{"message": "Chain is not valid"}`))
		}
		//else if () {

		//}
		//if blockchain.chain[i-1].hash_prev != block.hash {
		//return false
		//w.Write([]byte(`{"message": "Chain is not valid"}`))
		//}
		w.Write([]byte(`{"message": "Chain is valid"}`))
		i++
	}
}

func timeTrack(start time.Time, name string) {
	elapsed := time.Since(start)
	log.Printf("%s took %s", name, elapsed)
}

func init() {
	defer timeTrack(time.Now(), "file load")
}

func handleRequests() {
	r := mux.NewRouter()
	api := r.PathPrefix("/api/v1").Subrouter()

	api.HandleFunc("/chainvalid", isChainValid).Methods("GET")
	api.HandleFunc("/transaction/{from}/{to}/{amount}", createTransaction).Methods("POST")
	api.HandleFunc("/mine/{minerAddress}", minePendingTransactions).Methods("POST")
	api.HandleFunc("/ballance/{id}", getBallanceOfAddress).Methods("GET")
	api.HandleFunc("/lblock", getLatestBlock).Methods("GET")
	log.Fatal(http.ListenAndServe(":8080", r))
}

func main() {
	handleRequests()
}
