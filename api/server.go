package main

import (
    //"encoding/json"
    "fmt"
    "strconv"
    "log"
    //"io/ioutil"
    "net/http"
    "github.com/gorilla/mux"
    "time"
)

type BlockChainInt interface {
    toString()
    //Block
    calculateHash()
    mineBlock()
    //BlockChain
    createGenesisBlock() //Create first block
    minePendingTransactions() //Do something on Transaction Array
    createTransaction() //Add to Transaction Array
    getLatestBlock() //return block
    getBallanceOfAddress() //return int
    isChainValid() //bool
}

type Transaction struct {
    fromAddress         string          `json:"fromAddress"`
    toAddress           string          `json:"toAddress"`
    ammount             int             `json:"ammount"`
}

type Block struct {
    nonce               int             `json:"nonce"`
    hash                string          `json:"hash"`
    hash_prev           string          `json:"hash_prev"`
    timestamp           time.Time          `json:"timestamp"`
    transactions        []Transaction   `json:"transactions"`
}

type BlockChain struct {
    chain               []Block         `json:"chain"`
    difficulty          int             `json:"difficulty"` //5
    pendingTransactions Transaction     `json:"pendingTransactions"`
    minningReward       int             `json:"minningReward` //100
}

var blockchain = BlockChain{}

func (block *Block) AddItem(transaction Transaction) []Transaction {
    block.transactions = append(block.transactions, transaction)
    return block.transactions
}

func toString(x Transaction) {

}
func (Block) toString() {
    
}
func calculateHash() {

}
func mineBlock(diffuculty int) {
    // accept difficulty
    /** while ($($this.hash.Substring(0, $difficulty)) -ne $(-join @(0) * $difficulty) ){
        $this.nonce++
        $this.hash = $(-join @(0) * $this.nonce) + $this.calculateHash()
    } **/
}
func createGenesisBlock(transaction Transaction) {
    blockchain.chain = append(blockchain.chain, Block{nonce: 0, hash: "calclulateHash()", hash_prev: "", timestamp: time.Now(), transactions: blockchain.chain[0].AddItem(transaction) })
    //accept block chain 
    //t = []Trasaction{fromAddress: "", toAddress: "", ammount: ""}
    //b = Block{nonce: "0", hash: calclulateHash(), hash_prev: 0, timestamp: (Get-Time), tranctions: t })
    //bc.chain.Add(b)
}
func minePendingTransactions(w http.ResponseWriter, r *http.Request) {
    //accept block chain to mine
    //for i, transaction := range x.pendingTransactions {
        //mineBlock()
    //}
}
func createTransaction(w http.ResponseWriter, r *http.Request) {
    pathParams := mux.Vars(r)
    w.Header().Set("Content-Type", "application/json")
    var err error

    from := pathParams["from"]

	to := pathParams["to"]

    ammount := -1
    if val, ok := pathParams["ammount"]; ok {
        ammount, err = strconv.Atoi(val)
            if err != nil {
                w.WriteHeader(http.StatusInternalServerError)
                w.Write([]byte(`{"message": "need a number"}`))
                return
            }
    }

    transaction := Transaction { toAddress: to, fromAddress: from, ammount: ammount }
   //if (blockchain.chain == nil) {
        createGenesisBlock(transaction)
   // }
    
    w.Write([]byte(fmt.Sprintf(`{"transaction.fromAddress": %s, "transaction.toAddress": %s, "transaction.ammount": "%d" }`, transaction.fromAddress, transaction.toAddress, transaction.ammount)))
    w.Write([]byte(fmt.Sprintf(`{"blockchain.chain[0]transactions[0]": "%s }`, blockchain.chain[0].transactions[0])))
}
func getLatestBlock() {
    //return Block
}
func getBallanceOfAddress(w http.ResponseWriter, r *http.Request) {
    //return int
}
func isChainValid(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(http.StatusOK)
    w.Write([]byte(`{"message": "Chain is valid"}`))
}

func params(w http.ResponseWriter, r *http.Request) {
    pathParams := mux.Vars(r)
    w.Header().Set("Content-Type", "application/json")

    userID := -1
    var err error
    if val, ok := pathParams["userID"]; ok {
        userID, err = strconv.Atoi(val)
        if err != nil {
            w.WriteHeader(http.StatusInternalServerError)
            w.Write([]byte(`{"message": "need a number"}`))
            return
        }
    }

    commentID := -1
    if val, ok := pathParams["commentID"]; ok {
        commentID, err = strconv.Atoi(val)
        if err != nil {
            w.WriteHeader(http.StatusInternalServerError)
            w.Write([]byte(`{"message": "need a number"}`))
            return
        }
    }

    query := r.URL.Query()
    location := query.Get("location")

    w.Write([]byte(fmt.Sprintf(`{"userID": %d, "commentID": %d, "location": "%s" }`, userID, commentID, location)))
}

func timeTrack(start time.Time, name string) {
	elapsed := time.Since(start)
	log.Printf("%s took %s", name, elapsed)
}

func init() {
	defer timeTrack(time.Now(), "file load")
	//books = &datastore.Books{}
	//books.Initialize()
}

func handleRequests() {
    r := mux.NewRouter()
    api := r.PathPrefix("/api/v1").Subrouter()

    api.HandleFunc("/user/{userID}/comment/{commentID}", params).Methods(http.MethodGet)

    api.HandleFunc("/chainvalid", isChainValid).Methods("GET")
    api.HandleFunc("/transaction/{from}/{to}/{ammount}", createTransaction).Methods("POST")
    api.HandleFunc("/mine", minePendingTransactions).Methods("POST")
    api.HandleFunc("/ballance/{id}", getBallanceOfAddress).Methods("GET")
    log.Fatal(http.ListenAndServe(":8080", r))
}

func main() {
    //createGenesisBlock("Hello")
    handleRequests()
}