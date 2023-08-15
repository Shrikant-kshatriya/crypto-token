import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import HashMap "mo:base/HashMap";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";


actor Token {

  let owner : Principal = Principal.fromText("kqzxj-n3mnh-xrx75-uzfns-2qynw-sms7g-a47xe-33byy-eywnb-yn2bx-fqe");
  let totalSupply : Nat = 1000000000;
  let symbol : Text = "DBH";

  private stable var balanceEntries: [(Principal, Nat)] = [];

  private var balances = HashMap.HashMap<Principal, Nat>(1, Principal.equal, Principal.hash);
  if(balances.size() < 1){
      balances.put(owner, totalSupply);
  };

  public query func balanceOf(who: Principal) : async Nat {

    let balance : Nat = switch (balances.get(who)) {
      case null 0;
      case (?result) result;
    };
    return balance;
  };

  public query func getSymbol() : async Text {
    return symbol;
  };

  public shared(msg) func payOut() : async Text {
    if(balances.get(msg.caller) == null){

      let amt = 10000;
      let result = await transfer(msg.caller, amt);
      return result;
    } else {
      return "Already Claimed."
    }
  };

  public shared(msg) func transfer(to: Principal, amt: Nat) : async Text {
    let fromBalance = await balanceOf(msg.caller);
    if(fromBalance > amt) {

      let newFromBalance : Nat = fromBalance - amt;
      balances.put(msg.caller, newFromBalance);

      let toBalance = await balanceOf(to);
      let newToBalance = toBalance + amt;
      balances.put(to, newToBalance);

      return "Success";
    } else {
      return "Insufficient Funds";
    }
  };

  system func preupgrade() {
    balanceEntries := Iter.toArray(balances.entries());
  };
  system func postupgrade() {
    balances := HashMap.fromIter<Principal, Nat>(balanceEntries.vals(), 1, Principal.equal, Principal.hash);
    if(balances.size() < 1){
      balances.put(owner, totalSupply);
    }
  };
}