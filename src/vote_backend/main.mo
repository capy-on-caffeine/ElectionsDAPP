import RBTree "mo:base/RBTree";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Iter "mo:base/Iter";
import Int "mo:base/Int";
import Char "mo:base/Char";
import Nat32 "mo:base/Nat32";
import Option "mo:base/Option";


actor {
  let psk : Text = "theorywillonlytakeyousofar";

  var question : Text = "Who will sit on the throne?";
  var votes : RBTree.RBTree<Text, Nat> = RBTree.RBTree(Text.compare);

  func textToNat(t : Text) : Nat {
    var n : Nat = 0;
    for (c in t.chars()) {
      if (Char.isDigit(c)) {
        let charAsNat : Nat = Nat32.toNat(Char.toNat32(c) - 48);
        n := n * 10 + charAsNat;
      }
    };
    return n;
  };

  public query func getQuestion() : async Text {
    question;
  };

  public query func getVotes() : async [(Text, Nat)] {
    Iter.toArray(votes.entries());
  };

  public func addCandidate(entry : Text) : async [(Text, Nat)] {
    votes.put(entry, 0);
    Iter.toArray(votes.entries());
  };

  public func vote(entry : Text) : async [(Text, Nat)] {
    let votes_for_entry : ?Nat = votes.get(entry);

    let current_votes_for_entry : Int = switch votes_for_entry {
      case null -1;
      case (?Nat) Nat;
    };

    if (current_votes_for_entry != -1) {
      let current_votes_for_entry_nat : Nat = textToNat(Int.toText(current_votes_for_entry));
      votes.put(entry, current_votes_for_entry_nat + 1);
    };

    Iter.toArray(votes.entries());
  };

  public func resetVotes(passkey : Text) : async () {
    if (passkey == psk) votes := RBTree.RBTree(Text.compare);
  };

};
